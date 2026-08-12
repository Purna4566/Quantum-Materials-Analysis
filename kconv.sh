#!/bin/bash
# kconv.sh — k-point convergence test for bcc Fe

rm -f kconv_results.dat

for k in 4 6 8 10 12 14; do
  cat > Iron_k${k}.in << EOF
&CONTROL
  calculation = 'scf'
  prefix      = 'Iron_k${k}'
  outdir      = './out'
  pseudo_dir  = './mix-sssp-pbe-eff-lib-v2/library/'
/
&SYSTEM
  ibrav      = 3
  celldm(1)  = 5.42
  nat        = 1
  ntyp       = 1
  ecutwfc    = 64
  ecutrho    = 782
  occupations = 'smearing'
  smearing    = 'marzari-vanderbilt'
  degauss     = 0.02
  nspin       = 2
  starting_magnetization(1) = 0.6
/
&ELECTRONS
  conv_thr = 1.0d-8
  mixing_beta = 0.3
/
ATOMIC_SPECIES
  Fe  55.845  Fe.paw.pbe.z_16.ld1.psl.v0.2.1.upf
ATOMIC_POSITIONS {crystal}
  Fe  0.0 0.0 0.0
K_POINTS {automatic}
  $k $k $k  0 0 0
EOF

  echo "Running k-mesh ${k}x${k}x${k}..."
  pw.x < Iron_k${k}.in > Iron_k${k}.out 2>&1

  E=$(grep '!' Iron_k${k}.out | awk '{print $5}')
  echo "${k}   ${E}" >> kconv_results.dat
  echo "  -> Energy: ${E} Ry"
done

echo ""
echo "=== k-mesh convergence summary ==="
echo "k-mesh   Energy (Ry)"
cat kconv_results.dat
