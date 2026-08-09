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

def read_pdos_sum(fnames):
    total = None
    E = None
    for fn in fnames:
        e, d = [], []
        with open(fn) as f:
            for line in f:
                if line.startswith('#'):
                    continue
                parts = [float(x) for x in line.split()]
                e.append(parts[0])
                # sum all pdos columns after E and ldos (col 0, 1)
                d.append(sum(parts[2:]))
        if total is None:
            total = d
            E = e
        else:
            total = [t + d_i for t, d_i in zip(total, d)]
    return E, total

EF = 10.7858

E_tot, D_tot = read_dos('FeTe2_r.dos')

fe_files = ['FeTe2_r.pdos.pdos_atm#1(Fe)_wfc#5(d)',
            'FeTe2_r.pdos.pdos_atm#2(Fe)_wfc#5(d)']
E_fe, D_fe = read_pdos_sum(fe_files)

te_files = [f'FeTe2_r.pdos.pdos_atm#{i}(Te)_wfc#2(p)' for i in range(3, 7)]
E_te, D_te = read_pdos_sum(te_files)

E_tot_shift = [e - EF for e in E_tot]
E_fe_shift  = [e - EF for e in E_fe]
E_te_shift  = [e - EF for e in E_te]

fig, ax = plt.subplots(figsize=(8, 5))
ax.plot(E_tot_shift, D_tot, color='#2c2c2a', linewidth=1.3, label='Total DOS')
ax.fill_between(E_fe_shift, D_fe, color='#D85A30', alpha=0.6, label='Fe 3d')
ax.fill_between(E_te_shift, D_te, color='#378ADD', alpha=0.5, label='Te 5p')
ax.axvline(0, color='gray', linestyle='--', linewidth=0.8)
ax.set_xlim(-8, 15)
ax.set_xlabel('Energy relative to VBM (eV)')
ax.set_ylabel('DOS (states/eV)')
ax.set_title('FeTe2 total and projected density of states')
ax.legend()
plt.tight_layout()
plt.savefig('FeTe2_dos_pdos.png', dpi=150)
print("Saved FeTe2_dos_pdos.png")
