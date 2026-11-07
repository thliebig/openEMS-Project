#!/usr/bin/env python3
"""Draw the figures of development/engine_cpu.rst.

Writes engine_cpu_runs.svg, engine_cpu_blocking.svg and engine_cpu_tiles.svg
next to this script. The trapezoids are the phases of
Engine_BlockedPlan::Trapezoids() in openEMS (FDTD/engine_plan.cpp), the rest
is a sketch: python3 engine_cpu.py
"""
import os
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle, Patch

HERE = os.path.dirname(os.path.abspath(__file__))
plt.rcParams.update({'font.size': 10, 'svg.fonttype': 'path', 'svg.hashsalt': 'openEMS'})

INK = '#333333'
COLORS = {
    'ZERO':         '#5b5b5b',
    'LOSSLESS':     '#cfe3f5',
    'LOSSLESS2':    '#8fbde6',
    'LOSSY':        '#f0a04b',
    'UPML':         '#b9dfae',
    'UPML_PROFILE': '#6fb46a',
    'DISP':         '#b79ad6',
}


def save(fig, name):
    fig.savefig(os.path.join(HERE, name), bbox_inches='tight', metadata={'Date': None})
    plt.close(fig)


# ---------------------------------------------------------------------------
# 1) a cut through a model as cell classes, the runs along the fast axis
def runs_figure():
    NX, NY = 40, 14
    # a graded mesh: finer around the patch
    w = np.ones(NX)
    w[10:30] = 0.6
    w[13:27] = 0.4
    xs = np.concatenate([[0], np.cumsum(w)])
    cls = np.full((NY, NX), 'LOSSLESS', dtype=object)
    mat = np.zeros((NY, NX), dtype=int)   # equal class and mat: one run
    cls[:3, :] = 'UPML'
    cls[11:, :] = 'UPML'
    for r in list(range(3)) + list(range(11, NY)):
        mat[r, :] = 10 + r          # a PML layer: one set of coefficients per line
    cls[:, :4] = 'UPML_PROFILE'
    cls[:, 36:] = 'UPML_PROFILE'
    mat[:, :4] = 1
    mat[:, 36:] = 2
    cls[4:6, 8:32] = 'LOSSLESS2'    # the substrate
    mat[4:6, 8:32] = 3
    cls[3, 8:32] = 'ZERO'           # the ground
    mat[3, 8:32] = 4
    cls[6, 13:27] = 'ZERO'          # the patch
    mat[6, 13:27] = 4
    cls[4:6, 11] = 'LOSSY'          # the port's resistor
    mat[4:6, 11] = 5
    cls[8:10, 15:25] = 'DISP'       # a Debye block
    mat[8:10, 15:25] = 6

    fig, ax = plt.subplots(figsize=(9, 4.2))
    for r in range(NY):
        for c in range(NX):
            ax.add_patch(Rectangle((xs[c], r), w[c], 1, facecolor=COLORS[cls[r, c]],
                                   edgecolor='white', linewidth=0.6))
    # the run borders: where class or coefficients change along a line
    nruns = 0
    for r in range(NY):
        ax.plot([xs[0], xs[-1]], [r, r], color=INK, linewidth=0.4)
        nruns += 1
        for c in range(1, NX):
            if (cls[r, c], mat[r, c]) != (cls[r, c-1], mat[r, c-1]):
                ax.plot([xs[c], xs[c]], [r, r+1], color=INK, linewidth=2.0, solid_capstyle='butt')
                nruns += 1
    ax.plot([xs[0], xs[-1]], [NY, NY], color=INK, linewidth=0.4)
    for x in (xs[0], xs[-1]):
        ax.plot([x, x], [0, NY], color=INK, linewidth=2.0, solid_capstyle='butt')

    # one line picked out
    row = 5
    ax.add_patch(Rectangle((xs[0], row), xs[-1], 1, fill=False, edgecolor='#d62728', linewidth=1.8))
    nrow = 1 + sum((cls[row, c], mat[row, c]) != (cls[row, c-1], mat[row, c-1]) for c in range(1, NX))
    ax.annotate(f'{NX} cells, {nrow} runs', xy=(xs[-1], row+0.5), xytext=(xs[-1]+0.8, row+0.5),
                va='center', color='#d62728', fontsize=9.5,
                arrowprops=dict(arrowstyle='-', color='#d62728'))
    ax.annotate('', xy=(xs[-1]*0.62, -0.9), xytext=(xs[-1]*0.38, -0.9), annotation_clip=False,
                arrowprops=dict(arrowstyle='->', color=INK, linewidth=1.2))
    ax.text(xs[-1]*0.5, -1.5, 'fast axis: contiguous in memory', ha='center', va='top', color=INK)
    ax.text(xs[-1]+0.8, NY-0.5, f'whole cut:\n{NX*NY} cells\n{nruns} runs', va='top', fontsize=9.5, color=INK)

    labels = [('ZERO', 'ZERO: metal, set to 0'), ('LOSSLESS', 'LOSSLESS: air'),
              ('LOSSLESS2', 'LOSSLESS: substrate'), ('LOSSY', 'LOSSY: resistor'),
              ('UPML', 'UPML: constant along the line'), ('UPML_PROFILE', 'UPML_PROFILE: graded along it'),
              ('DISP', 'DISP: Debye material')]
    ax.legend(handles=[Patch(facecolor=COLORS[k], edgecolor=INK, linewidth=0.5, label=t) for k, t in labels],
              loc='upper center', bbox_to_anchor=(0.5, -0.17), ncol=4, frameon=False, fontsize=9,
              handlelength=1.2, columnspacing=1.2)
    ax.set_xlim(xs[0]-0.2, xs[-1]+0.2)
    ax.set_ylim(-0.2, NY+0.2)
    ax.set_aspect('equal')
    ax.axis('off')
    save(fig, 'engine_cpu_runs.svg')


# ---------------------------------------------------------------------------
# 2) space-time: the flat sweep against the trapezoids of temporal blocking
def trapezoid_phases(N, width, k):
    """ the phases of Engine_BlockedPlan::Trapezoids along the split axis:
        (kind, tile, volt, t, lo, hi), in their order """
    border = [0]
    while N - border[-1] >= 2*width:
        border.append(border[-1] + width)
    border.append(N)
    phases = []
    for i in range(len(border)-1):
        a, b = border[i], border[i+1]
        for t in range(k):
            lo = a+t if a > 0 else 0
            phases.append(('core', i, True,  t, lo, b-t if b < N else N))
            phases.append(('core', i, False, t, lo, b-t-1 if b < N else N-1))
    for i in range(1, len(border)-1):
        a = border[i]
        for t in range(k):
            phases.append(('wedge', i, True,  t, a-t, a+t))
            phases.append(('wedge', i, False, t, a-t-1, a+t))
    return [p for p in phases if p[4] < p[5]], border


def blocking_figure():
    N, W, k = 36, 12, 4
    phases, border = trapezoid_phases(N, W, k)
    core_c = ['#4c78a8', '#6b98c9', '#93b8e0']
    wedge_c = ['#f58518', '#f7a65a']

    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(10, 3.9), sharey=True,
                                   gridspec_kw={'width_ratios': [1, 1], 'wspace': 0.08})
    rows = 2*k

    def row_of(volt, t):
        return 2*t + (0 if volt else 1)

    def cells(ax, lo, hi, r, color, edge='white'):
        for j in range(lo, hi):
            ax.add_patch(Rectangle((j, r+0.08), 1, 0.84, facecolor=color, edgecolor=edge, linewidth=0.5))

    # the flat sweep: every half step the whole domain
    for r in range(rows):
        cells(ax0, 0, N, r, '#bdbdbd')
        ax0.text(N/2, r+0.5, f'{r+1}', ha='center', va='center', fontsize=8.5, color=INK)
    ax0.set_title('flat sweep: every half step\nstreams the whole model from memory', fontsize=10)

    # the blocked plan
    order = {}
    for p in phases:
        kind, tile = p[0], p[1]
        key = (kind, tile)
        if key not in order:
            order[key] = len(order)+1
        color = core_c[tile % 3] if kind == 'core' else wedge_c[tile % 2]
        cells(ax1, p[4], p[5], row_of(p[2], p[3]), color)
    for (kind, tile), n in order.items():
        if kind == 'core':
            a, b = border[tile], border[tile+1]
            ax1.text((a+b)/2, 1.4, f'{n}', ha='center', va='center', fontsize=12, color='white', weight='bold')
        else:
            a = border[tile]
            ax1.text(a, rows-1.4, f'{n}', ha='center', va='center', fontsize=12, color='white', weight='bold')
    for a in border[1:-1]:
        ax1.plot([a, a], [-0.3, rows+0.3], color=INK, linewidth=0.8, linestyle=':')
    ax1.set_title(f'temporal blocking, {k} timesteps per block:\ntiles (blue) first, then the wedges (orange)',
                  fontsize=10)

    for ax in (ax0, ax1):
        ax.set_xlim(-0.5, N+0.5)
        ax.set_ylim(-0.3, rows+0.3)
        ax.set_xlabel('mesh lines along the split axis')
        for s in ('top', 'right'):
            ax.spines[s].set_visible(False)
    ax0.set_yticks([r+0.5 for r in range(rows)])
    ax0.set_yticklabels([('E' if r % 2 == 0 else 'H') + f' step {r//2+1}' for r in range(rows)])
    ax1.tick_params(axis='y', length=0)
    save(fig, 'engine_cpu_blocking.svg')


# ---------------------------------------------------------------------------
# 3) the work of the threads: slabs of the flat sweep, strips of one tile
def tiles_figure():
    NS, NM, T = 36, 24, 8
    W = 12
    thr = plt.get_cmap('tab10')

    fig, (ax0, ax1) = plt.subplots(1, 2, figsize=(10, 3.9), gridspec_kw={'wspace': 0.12})
    # flat: the split axis cut into a slab per thread
    edges = np.linspace(0, NS, T+1)
    for n in range(T):
        ax0.add_patch(Rectangle((edges[n], 0), edges[n+1]-edges[n], NM, facecolor=thr(n), alpha=0.55,
                                edgecolor='white', linewidth=1.0))
        ax0.text((edges[n]+edges[n+1])/2, NM/2, f'T{n+1}', ha='center', va='center', fontsize=9, color=INK)
    ax0.set_title('flat sweep: a slab per thread,\nthe whole model per half step', fontsize=10)

    # blocked: all threads on one tile, cut along the other slow axis
    tiles = [(0, W), (W, 2*W), (2*W, NS)]
    ax1.add_patch(Rectangle((0, 0), W, NM, facecolor='#d9d9d9', edgecolor='white', linewidth=1.0))
    ax1.text(W/2, NM/2, 'done:\nk timesteps\nahead', ha='center', va='center', fontsize=9, color=INK)
    a, b = tiles[1]
    medges = np.linspace(0, NM, T+1)
    for n in range(T):
        ax1.add_patch(Rectangle((a, medges[n]), b-a, medges[n+1]-medges[n], facecolor=thr(n), alpha=0.55,
                                edgecolor='white', linewidth=1.0))
        ax1.text((a+b)/2, (medges[n]+medges[n+1])/2, f'T{n+1}', ha='center', va='center', fontsize=8.5,
                 color=INK)
    ax1.add_patch(Rectangle((a, 0), b-a, NM, fill=False, edgecolor=INK, linewidth=1.8))
    ax1.add_patch(Rectangle((2*W, 0), NS-2*W, NM, facecolor='#f2f2f2', edgecolor='white', linewidth=1.0))
    ax1.text((2*W+NS)/2, NM/2, 'next', ha='center', va='center', fontsize=9, color=INK)
    ax1.set_title('temporal blocking: all threads on one tile,\nwhich stays in the cache for k timesteps',
                  fontsize=10)

    for ax in (ax0, ax1):
        ax.set_xlim(-0.3, NS+0.3)
        ax.set_ylim(-0.3, NM+0.3)
        ax.set_aspect('equal')
        ax.set_xlabel('split axis')
        ax.set_ylabel('other slow axis')
        ax.set_xticks([])
        ax.set_yticks([])
        for s in ('top', 'right'):
            ax.spines[s].set_visible(False)
    fig.text(0.5, 0.05, 'the fast axis points into the page: each point of these planes is a line of cells, contiguous in memory',
             ha='center', fontsize=9, color=INK)
    save(fig, 'engine_cpu_tiles.svg')


if __name__ == '__main__':
    runs_figure()
    blocking_figure()
    tiles_figure()
