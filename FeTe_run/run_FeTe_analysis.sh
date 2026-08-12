#!/bin/bash
set -e

PSEUDO_DIR="./mix-sssp-pbe-eff-lib-v2/library/"
CELL="
  3.619323004   0.000000000   0.000000000
  0.000000000   3.619323004   0.000000000
  0.000000000   0.000000000   6.860397297"
POSITIONS="
  Fe   0.7500000000   0.2500000000   0.0000000000
  Fe   0.2500000000   0.7500000000   0.0000000000
  Te   0.2500000000   0.2500000000   0.2722383488
  Te   0.7500000000   0.7500000000  -0.2722383488"

echo "=== Step 1: SCF at relaxed geometry ==="
cat > scf.in << EOF
&CONTROL
  calculation = 'scf'
  prefix      = 'FeTe_r'
  outdir      = './out'
  pseudo_dir  = '$PSEUDO_DIR'
/
&SYSTEM
  ibrav = 0
  nat = 4
  ntyp = 2
  ecutwfc = 64
  ecutrho = 782
  occupations = 'smearing'
  smearing = 'marzari-vanderbilt'
  degauss = 0.02
  nspin = 2
  starting_magnetization(1) = 0.5
  nbnd = 30
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
  8 8 6  0 0 0
EOF
pw.x < scf.in > scf.out 2>&1
echo "SCF done: $(grep '!' scf.out)"
echo "Magnetization: $(grep 'total magnetization' scf.out | tail -1)"

echo "=== Step 2: Dense NSCF for DOS ==="
cat > nscf.in << EOF
&CONTROL
  calculation = 'nscf'
  prefix      = 'FeTe_r'
  outdir      = './out'
  pseudo_dir  = '$PSEUDO_DIR'
/
&SYSTEM
  ibrav = 0
  nat = 4
  ntyp = 2
  ecutwfc = 64
  ecutrho = 782
  occupations = 'tetrahedra'
  nspin = 2
  starting_magnetization(1) = 0.5
  nbnd = 30
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
  12 12 8  0 0 0
EOF
pw.x < nscf.in > nscf.out 2>&1
echo "NSCF done."

echo "=== Step 3: DOS and PDOS ==="
cat > dos.in << EOF
&DOS
  prefix = 'FeTe_r'
  outdir = './out'
  fildos = 'FeTe_r.dos'
  Emin = -10
  Emax = 15
  DeltaE = 0.05
/
EOF
dos.x < dos.in > dos.out 2>&1

cat > pdos.in << EOF
&PROJWFC
  prefix = 'FeTe_r'
  outdir = './out'
  filpdos = 'FeTe_r.pdos'
  Emin = -10
  Emax = 15
  DeltaE = 0.05
/
EOF
projwfc.x < pdos.in > pdos.out 2>&1

echo "=== ALL DONE ==="
grep "the Fermi energy is" nscf.out
