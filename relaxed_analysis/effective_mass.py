import numpy as np

# Relaxed cell (angstrom)
a, b, c = 5.263855455, 6.260989585, 3.895341692

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

kpoints = np.array(kpoints)
bands = np.array(bands)
nocc = 28

hbar = 1.054571817e-34   # J.s
me = 9.1093837015e-31    # kg
eV = 1.602176634e-19     # J
ang = 1e-10               # m

def real_k(kfrac):
    return np.array([kfrac[0]*2*np.pi/a, kfrac[1]*2*np.pi/b, kfrac[2]*2*np.pi/c]) / ang

def eff_mass_at(idx, band_idx, direction_axis):
    # central finite difference using neighboring points on the same path segment
    k0 = real_k(kpoints[idx])
    kp = real_k(kpoints[idx+1])
    km = real_k(kpoints[idx-1])
    dk = np.linalg.norm(kp - km) / 2   # 1/m, assumes uniform spacing locally
    E0 = bands[idx, band_idx] * eV
    Ep = bands[idx+1, band_idx] * eV
    Em = bands[idx-1, band_idx] * eV
    d2E_dk2 = (Ep - 2*E0 + Em) / (dk**2)
    if d2E_dk2 == 0:
        return None
    m_star = hbar**2 / d2E_dk2
    return m_star / me   # in units of free electron mass

vb = bands[:, nocc-1]
cb = bands[:, nocc]
vbm_i = int(np.argmax(vb))
cbm_i = int(np.argmin(cb))

print(f"VBM at point #{vbm_i}, k={kpoints[vbm_i]}, E={vb[vbm_i]:.4f} eV")
m_hole = eff_mass_at(vbm_i, nocc-1, 0)
print(f"  Hole effective mass along this direction: {m_hole:.4f} m0" if m_hole else "  (flat/undefined)")

print(f"CBM at point #{cbm_i}, k={kpoints[cbm_i]}, E={cb[cbm_i]:.4f} eV")
m_elec = eff_mass_at(cbm_i, nocc, 0)
print(f"  Electron effective mass along this direction: {m_elec:.4f} m0" if m_elec else "  (flat/undefined)")

with open('effective_mass_result.txt', 'w') as out:
    out.write(f"Hole effective mass (VBM, along Gamma-X): {m_hole:.4f} m0\n")
    out.write(f"Electron effective mass (CBM, along Gamma-Y): {m_elec:.4f} m0\n")
    out.write("Note: mass reported along the sampled k-path direction only, not the full anisotropic tensor.\n")
