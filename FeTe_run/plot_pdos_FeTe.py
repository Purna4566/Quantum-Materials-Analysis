import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

def read_dos(fname, col=1):
    E, D = [], []
    with open(fname) as f:
        for line in f:
            if line.startswith('#'): continue
            p = line.split()
            E.append(float(p[0])); D.append(float(p[col]))
    return E, D

def read_pdos_sum(fnames):
    total, E = None, None
    for fn in fnames:
        e, d = [], []
        with open(fn) as f:
            for line in f:
                if line.startswith('#'): continue
                p = [float(x) for x in line.split()]
                e.append(p[0]); d.append(sum(p[2:]))
        if total is None: total, E = d, e
        else: total = [t+x for t,x in zip(total,d)]
    return E, total

EF = 9.2579
E_tot, D_tot = read_dos('FeTe_r.dos')
fe_files = ['FeTe_r.pdos.pdos_atm#1(Fe)_wfc#5(d)', 'FeTe_r.pdos.pdos_atm#2(Fe)_wfc#5(d)']
E_fe, D_fe = read_pdos_sum(fe_files)
te_files = [f'FeTe_r.pdos.pdos_atm#{i}(Te)_wfc#2(p)' for i in range(3,5)]
E_te, D_te = read_pdos_sum(te_files)

E_tot_s = [e-EF for e in E_tot]; E_fe_s = [e-EF for e in E_fe]; E_te_s = [e-EF for e in E_te]

fig, ax = plt.subplots(figsize=(8,5))
ax.plot(E_tot_s, D_tot, color='#2c2c2a', linewidth=1.3, label='Total DOS')
ax.fill_between(E_fe_s, D_fe, color='#D85A30', alpha=0.6, label='Fe 3d')
ax.fill_between(E_te_s, D_te, color='#378ADD', alpha=0.5, label='Te 5p')
ax.axvline(0, color='gray', linestyle='--', linewidth=0.8)
ax.set_xlim(-4,4)
ax.set_xlabel('Energy relative to E$_F$ (eV)')
ax.set_ylabel('DOS (states/eV)')
ax.set_title('FeTe total and projected density of states')
ax.legend()
plt.tight_layout()
plt.savefig('FeTe_dos_pdos.png', dpi=150)
print("Saved FeTe_dos_pdos.png")
