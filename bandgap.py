import numpy as np

with open('FeTe2.bands.dat') as f:
    lines = f.readlines()

nbnd = 40
kpoints = []
bands = []

i = 1
while i < len(lines):
    kpt = [float(x) for x in lines[i].split()]
    i += 1
    energies = []
    while len(energies) < nbnd:
        energies.extend(float(x) for x in lines[i].split())
        i += 1
    kpoints.append(kpt)
    bands.append(energies)

bands = np.array(bands)
kpoints = np.array(kpoints)

nocc = 28
vb = bands[:, nocc - 1]
cb = bands[:, nocc]

vbm_i = np.argmax(vb)
cbm_i = np.argmin(cb)

print(f"VBM = {vb[vbm_i]:.4f} eV  at k-point {kpoints[vbm_i]}  (point #{vbm_i})")
print(f"CBM = {cb[cbm_i]:.4f} eV  at k-point {kpoints[cbm_i]}  (point #{cbm_i})")
print(f"Gap = {cb[cbm_i] - vb[vbm_i]:.4f} eV")
print("Direct gap" if vbm_i == cbm_i else "Indirect gap")
