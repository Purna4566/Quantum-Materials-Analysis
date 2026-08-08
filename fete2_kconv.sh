#!/bin/bash
rm -f fete2_kconv_results.dat

declare -a KMESH=("4 4 6" "6 6 8" "8 8 10" "10 10 12" "12 12 14")

for k in "${KMESH[@]}"; do
  read ka kb kc <<< "$k"
  cat > FeTe2_k${ka}${kb}${kc}.in << EOI
&CONTROL
  calculation = 'scf'
  prefix      = 'FeTe2_k${ka}${kb}${kc}'
  outdir      = './out'
  pseudo_dir  = './mix-sssp-pbe-eff-lib-v2/library/'
/
&SYSTEM
  ibrav      = 0
  nat        = 6
  ntyp       = 2
  ecutwfc    = 64
  ecutrho    = 782
  occupations = 'fixed'
/
&ELECTRONS
  conv_thr = 1.0d-8
  mixing_beta = 0.3
/
ATOMIC_SPECIES
  Fe  55.845  Fe.paw.pbe.z_16.ld1.psl.v0.2.1.upf
  Te  127.60  Te.us.pbe.z_6.ld1.psl.v1.0.0-low.upf

CELL_PARAMETERS angstrom
  5.2845  0.0000  0.0000
  0.0000  6.2865  0.0000
  0.0000  0.0000  3.9058

ATOMIC_POSITIONS {crystal}
  Fe   0.0000000000   0.0000000000  -0.0000000000
  Fe   0.5000000000   0.5000000000   0.5000000000
  Te   0.2274903774   0.3616906451  -0.0000000000
  Te   0.7725096226   0.6383093549  -0.0000000000
  Te   0.7274903774   0.1383093549   0.5000000000
  Te   0.2725096226   0.8616906451   0.5000000000

K_POINTS {automatic}
  ${ka} ${kb} ${kc}  0 0 0
EOI

  echo "Running k-mesh ${ka} ${kb} ${kc}..."
  pw.x < FeTe2_k${ka}${kb}${kc}.in > FeTe2_k${ka}${kb}${kc}.out 2>&1

  E=$(grep '!' FeTe2_k${ka}${kb}${kc}.out | awk '{print $5}')
  echo "${ka}x${kb}x${kc}   ${E}" >> fete2_kconv_results.dat
  echo "  -> Energy: ${E} Ry"
done

echo ""
echo "=== FeTe2 k-mesh convergence summary ==="
cat fete2_kconv_results.dat
