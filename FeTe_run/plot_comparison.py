import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def read_dos(fname, col=1):
    E, D = [], []
    with open(fname) as f:
        for line in f:
            if line.startswith('#'):
                continue
            parts = line.split()
            E.append(float(parts[0]))
            D.append(float(parts[col]))
    return E, D

# FeTe2 (semiconductor) - shift by VBM-based midgap Fermi energy
E_fete2, D_fete2 = read_dos('../relaxed_analysis/FeTe2_r.dos')
EF_fete2 = 10.7858
E_fete2_shift = [e - EF_fete2 for e in E_fete2]

# FeTe (metal) - shift by its own Fermi energy
E_fete, D_fete = read_dos('FeTe_r.dos')
EF_fete = 9.2579
E_fete_shift = [e - EF_fete for e in E_fete]

fig, (ax1, ax2) = plt.subplots(2, 1, figsize=(8, 8), sharex=True)

ax1.plot(E_fete2_shift, D_fete2, color='#2a78d6', linewidth=1.3)
ax1.axvline(0, color='gray', linestyle='--', linewidth=0.8)
ax1.set_ylabel('DOS (states/eV)')
ax1.set_title('FeTe$_2$ (semiconductor) — zero DOS at E$_F$')
ax1.set_xlim(-4, 4)

ax2.plot(E_fete_shift, D_fete, color='#D85A30', linewidth=1.3)
ax2.axvline(0, color='gray', linestyle='--', linewidth=0.8)
ax2.set_xlabel('Energy relative to E$_F$ (eV)')
ax2.set_ylabel('DOS (states/eV)')
ax2.set_title('FeTe (metal) — finite DOS at E$_F$')
ax2.set_xlim(-4, 4)

plt.tight_layout()
plt.savefig('FeTe2_vs_FeTe_comparison.png', dpi=150)
print("Saved FeTe2_vs_FeTe_comparison.png")
