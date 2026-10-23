#!/usr/bin/env python3
"""Plot the Gaussian pulse and its DC-free variant, time signal and spectrum.

Writes gauss_dcfree.svg next to this script for concepts/signals.rst. The
pulses are the formulas of Excitation::CalcGaussianPulse() in openEMS, so no
simulation is needed: python3 gauss_dcfree.py
"""
import os
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt


def gauss(t, f0, fc, dc_free):
    u = 2*np.pi*fc*t/3 - 3
    env = np.exp(-u**2)
    if not dc_free:
        return np.cos(2*np.pi*f0*(t - 9/(2*np.pi*fc)))*env
    if f0 > 0:
        return np.sin(2*np.pi*f0*(t - 9/(2*np.pi*fc)))*env
    return -u*env*np.sqrt(2*np.e)


COLOR = {False: '#2a78d6', True: '#eb6834'}
plt.rcParams.update({'font.size': 10, 'axes.spines.top': False, 'axes.spines.right': False,
                     'axes.edgecolor': '#888', 'xtick.color': '#555', 'ytick.color': '#555',
                     'svg.hashsalt': 'openEMS'})

cases = [(1.5e9, 1.5e9, 'dc_free (sine carrier)'), (0, 3e9, 'dc_free (monocycle)')]
fig, ax = plt.subplots(2, 2, figsize=(11, 7), gridspec_kw={'width_ratios': [1, 1.25]})
for r, (f0, fc, dc_label) in enumerate(cases):
    T = 2*9/(2*np.pi*fc)
    t = np.linspace(0, T, 2001)
    fmax = 2.2*max(f0+fc, 1.3*fc)
    f = np.linspace(0, fmax, 1500)
    for dc_free in (False, True):
        label = dc_label if dc_free else 'default (cosine carrier)'
        v = gauss(t, f0, fc, dc_free)
        S = abs(np.exp(-2j*np.pi*np.outer(f, t)) @ v)
        ax[r, 0].plot(t*1e9, v, color=COLOR[dc_free], lw=2, label=label)
        ax[r, 1].plot(f/1e9, 20*np.log10(S/S.max() + 1e-12), color=COLOR[dc_free], lw=2, label=label)

    a = ax[r, 0]
    a.set_xlim(0, T*1e9)
    a.axhline(0, color='#bbb', lw=0.8)
    a.set_ylabel('e(t)')
    a.set_title(f'f0 = {f0/1e9:g} GHz, fc = {fc/1e9:g} GHz: time signal', loc='left', fontsize=10.5)

    a = ax[r, 1]
    a.set_xlim(0, fmax/1e9)
    a.set_ylim(-60, 3)
    a.axhline(-20, color='#999', lw=0.8, ls='--')
    a.text(fmax/1e9*0.99, -19, '−20 dB', ha='right', va='bottom', color='#666', fontsize=9)
    for fe in (f0 - fc, f0 + fc):
        if fe > 0:
            a.axvline(fe/1e9, color='#ccc', lw=0.8, zorder=0)
    a.grid(axis='y', color='#eee')
    a.set_ylabel('|E(f)| / max  [dB]')
    a.set_title('spectrum (grey lines: f0 ± fc)', loc='left', fontsize=10.5)
    a.legend(frameon=False, loc='lower center' if f0 > 0 else 'upper right')

ax[1, 0].set_xlabel('t [ns]')
ax[1, 1].set_xlabel('f [GHz]')
fig.tight_layout()
fig.savefig(os.path.join(os.path.dirname(os.path.abspath(__file__)), 'gauss_dcfree.svg'),
            metadata={'Date': None})
