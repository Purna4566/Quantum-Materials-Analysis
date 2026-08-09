#!/bin/bash
set -e

PSEUDO_DIR="./mix-sssp-pbe-eff-lib-v2/library/"
CELL="
  5.263855455   0.000000000   0.000000000
  0.000000000   6.260989585   0.000000000
  0.000000000   0.000000000   3.895341692"
POSITIONS="
  Fe   0.0000000000   0.0000000000  -0.0000000000
  Fe   0.5000000000   0.5000000000   0.5000000000
  Te   0.2273530106   0.3614823865  -0.0000000000
  Te   0.7726469894   0.6385176135  -0.0000000000
  Te   0.7273530106   0.1385176135   0.5000000000
  Te   0.2726469894   0.8614823865   0.5000000000"

echo "=== Step 1: SCF at relaxed geometry ==="
cat > scf.in << EOF
&CONTROL
  calculation = 'scf'
  prefix      = 'FeTe2_r'
  outdir      = './out'
  pseudo_dir  = '$PSEUDO_DIR'
/
&SYSTEM
  ibrav = 0
  nat = 6
  ntyp = 2
  ecutwfc = 64
  ecutrho = 782
  occupations = 'fixed'
  nbnd = 40
/
&ELECTRONS
  conv_thr = 1.0d-8
  mixing_beta = 0.3
/
ATOMIC_SPECIES
  Fe  55.845  Fe.paw.pbe.z_16.ld1.psl.v0.2.1.upf
  Te  127.60  Te.us.pbe.z_6.ld1.psl.v1.0.0-low.upf
CELL_PARAMETERS angstrom
$CELL
ATOMIC_POSITIONS {crystal}
$POSITIONS
K_POINTS {automatic}
  8 8 10  0 0 0
EOF
pw.x < scf.in > scf.out 2>&1
echo "SCF done: $(grep '!' scf.out)"

echo "=== Step 2: Band structure along Gamma-X-Gamma-Y-Gamma-Z ==="
cat > bands.in << EOF
&CONTROL
  calculation = 'bands'
  prefix      = 'FeTe2_r'
  outdir      = './out'
  pseudo_dir  = '$PSEUDO_DIR'
/
&SYSTEM
  ibrav = 0
  nat = 6
  ntyp = 2
  ecutwfc = 64
  ecutrho = 782
  occupations = 'fixed'
  nbnd = 40
/
&ELECTRONS
  conv_thr = 1.0d-8
/
ATOMIC_SPECIES
  Fe  55.845  Fe.paw.pbe.z_16.ld1.psl.v0.2.1.upf
  Te  127.60  Te.us.pbe.z_6.ld1.psl.v1.0.0-low.upf
CELL_PARAMETERS angstrom
$CELL
ATOMIC_POSITIONS {crystal}
$POSITIONS
K_POINTS {crystal_b}
6
  0.0  0.0  0.0   30
  0.5  0.0  0.0   30
  0.0  0.0  0.0   30
  0.0  0.5  0.0   30
  0.0  0.0  0.0   30
  0.0  0.0  0.5    1
EOF
pw.x < bands.in > bands.out 2>&1
echo "Bands done."

echo "=== Step 3: Extract band gap ==="
cat > bands_pp.in << EOF
&BANDS
  prefix = 'FeTe2_r'
  outdir = './out'
  filband = 'FeTe2_r.bands.dat'
/
EOF
bands.x < bands_pp.in > bands_pp.out 2>&1

python3 << 'PYEOF'
with open('FeTe2_r.bands.dat') as f:
    lines = f.readlines()
nbnd = 40
kpoints, bands = [], []
i = 1
while i < len(lines):
    kpt = [float(x) for x in lines[i].split()]; i += 1
    energies = []
    while len(energies) < nbnd:
        energies.extend(float(x) for x in lines[i].split()); i += 1
    kpoints.append(kpt); bands.append(energies)
nocc = 28
vb = [row[nocc-1] for row in bands]
cb = [row[nocc] for row in bands]
vbm_i = vb.index(max(vb)); cbm_i = cb.index(min(cb))
with open('bandgap_result.txt', 'w') as out:
    out.write(f"VBM = {vb[vbm_i]:.4f} eV at {kpoints[vbm_i]}\n")
    out.write(f"CBM = {cb[cbm_i]:.4f} eV at {kpoints[cbm_i]}\n")
    out.write(f"Gap = {cb[cbm_i]-vb[vbm_i]:.4f} eV\n")
    out.write("Direct gap\n" if vbm_i==cbm_i else "Indirect gap\n")
print(open('bandgap_result.txt').read())
PYEOF

echo "=== Step 4: Dense NSCF for DOS ==="
cat > nscf.in << EOF
&CONTROL
  calculation = 'nscf'
  prefix      = 'FeTe2_r'
  outdir      = './out'
  pseudo_dir  = '$PSEUDO_DIR'
/
&SYSTEM
  ibrav = 0
  nat = 6
  ntyp = 2
  ecutwfc = 64
  ecutrho = 782
  occupations = 'tetrahedra'
  nbnd = 40
/
&ELECTRONS
  conv_thr = 1.0d-8
/
ATOMIC_SPECIES
  Fe  55.845  Fe.paw.pbe.z_16.ld1.psl.v0.2.1.upf
  Te  127.60  Te.us.pbe.z_6.ld1.psl.v1.0.0-low.upf
CELL_PARAMETERS angstrom
$CELL
ATOMIC_POSITIONS {crystal}
$POSITIONS
K_POINTS {automatic}
  12 12 16  0 0 0
EOF
pw.x < nscf.in > nscf.out 2>&1
echo "NSCF done."

echo "=== Step 5: DOS and PDOS ==="
cat > dos.in << EOF
&DOS
  prefix = 'FeTe2_r'
  outdir = './out'
  fildos = 'FeTe2_r.dos'
  Emin = -10
  Emax = 15
  DeltaE = 0.05
/
EOF
dos.x < dos.in > dos.out 2>&1

cat > pdos.in << EOF
&PROJWFC
  prefix = 'FeTe2_r'
  outdir = './out'
  filpdos = 'FeTe2_r.pdos'
  Emin = -10
  Emax = 15
  DeltaE = 0.05
/
EOF
projwfc.x < pdos.in > pdos.out 2>&1

echo "=== ALL DONE ==="
cat bandgap_result.txt
