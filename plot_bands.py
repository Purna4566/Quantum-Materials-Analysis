import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

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

nocc = 28
n = len(kpoints)

x = [0.0]
for j in range(1, n):
    dx = kpoints[j][0]-kpoints[j-1][0]
    dy = kpoints[j][1]-kpoints[j-1][1]
    dz = kpoints[j][2]-kpoints[j-1][2]
    dist = (dx*dx+dy*dy+dz*dz) ** 0.5
    x.append(x[-1] + dist)

highsym = {'G': (0,0,0), 'X': (0.5,0,0), 'Y': (0,0.5,0), 'Z': (0,0,0.5)}
tick_pos, tick_lab = [], []
for j, k in enumerate(kpoints):
    for label, coord in highsym.items():
        if all(abs(k[c]-coord[c]) < 1e-4 for c in range(3)):
            tick_pos.append(x[j])
            tick_lab.append(label if label != 'G' else '\u0393')
            break

vb = [row[nocc-1] for row in bands]
cb = [row[nocc] for row in bands]
vbm_i = vb.index(max(vb))
cbm_i = cb.index(min(cb))
efermi = max(vb)

fig, ax = plt.subplots(figsize=(8,6))
for b in range(nbnd):
    ys = [bands[j][b]-efermi for j in range(n)]
    color = '#2a78d6' if b < nocc else '#eb6834'
    ax.plot(x, ys, color=color, linewidth=1.2)

ax.axhline(0, color='gray', linestyle='--', linewidth=0.8)
ax.scatter([x[vbm_i]], [vb[vbm_i]-efermi], color='#2a78d6', zorder=5, s=40, label='VBM')
ax.scatter([x[cbm_i]], [cb[cbm_i]-efermi], color='#eb6834', zorder=5, s=40, label='CBM')

for tp in tick_pos:
    ax.axvline(tp, color='gray', linewidth=0.5)

seen = set()
final_pos, final_lab = [], []
for p, l in zip(tick_pos, tick_lab):
    key = round(p, 3)
    if key not in seen:
        seen.add(key)
        final_pos.append(p)
        final_lab.append(l)

ax.set_xticks(final_pos)
ax.set_xticklabels(final_lab)
ax.set_xlim(x[0], x[-1])
ax.set_ylim(-3, 3)
ax.set_ylabel('Energy (eV, relative to VBM)')
ax.set_title('FeTe2 band structure (PBE)')
ax.legend()
plt.tight_layout()
plt.savefig('FeTe2_bandstructure.png', dpi=150)
print("Saved FeTe2_bandstructure.png")
