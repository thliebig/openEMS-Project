#!/usr/bin/env python3
"""Plot the Gaussian pulse and its DC-free variant, time signal and spectrum.

Writes gauss_pulse.svg and gauss_dcfree.svg next to this script for
concepts/signals.rst. The pulses are the formulas of
Excitation::CalcGaussianPulse() in openEMS, so no simulation is needed:
python3 gauss_pulse.py
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


def plot_row(ax_t, ax_f, f0, fc, pulses):
    """Time signal and spectrum of the (dc_free, label) pulses at f0, fc."""
    T = 2*9/(2*np.pi*fc)
    t = np.linspace(0, T, 2001)
    fmax = 2.2*max(f0+fc, 1.3*fc)
    f = np.linspace(0, fmax, 1500)
    for dc_free, label in pulses:
        v = gauss(t, f0, fc, dc_free)
        S = abs(np.exp(-2j*np.pi*np.outer(f, t)) @ v)
        ax_t.plot(t*1e9, v, color=COLOR[dc_free], lw=2, label=label)
        ax_f.plot(f/1e9, 20*np.log10(S/S.max() + 1e-12), color=COLOR[dc_free], lw=2, label=label)

    ax_t.set_xlim(0, T*1e9)
    ax_t.axhline(0, color='#bbb', lw=0.8)
    ax_t.set_ylabel('e(t)')
    ax_t.set_title(f'f0 = {f0/1e9:g} GHz, fc = {fc/1e9:g} GHz: time signal', loc='left', fontsize=10.5)

    ax_f.set_xlim(0, fmax/1e9)
    ax_f.set_ylim(-60, 3)
    ax_f.axhline(-20, color='#999', lw=0.8, ls='--')
    ax_f.text(fmax/1e9*0.99, -19, '−20 dB', ha='right', va='bottom', color='#666', fontsize=9)
    for fe in (f0 - fc, f0 + fc):
        if fe > 0:
            ax_f.axvline(fe/1e9, color='#ccc', lw=0.8, zorder=0)
    ax_f.grid(axis='y', color='#eee')
    ax_f.set_ylabel('|E(f)| / max  [dB]')
    ax_f.set_title('spectrum (grey lines: f0 ± fc)', loc='left', fontsize=10.5)
    if len(pulses) > 1:
        ax_f.legend(frameon=False, loc='lower center' if f0 > 0 else 'upper right')


def save(fig, name):
    fig.tight_layout()
    fig.savefig(os.path.join(os.path.dirname(os.path.abspath(__file__)), name),
                metadata={'Date': None})


COLOR = {False: '#2a78d6', True: '#eb6834'}
plt.rcParams.update({'font.size': 10, 'axes.spines.top': False, 'axes.spines.right': False,
                     'axes.edgecolor': '#888', 'xtick.color': '#555', 'ytick.color': '#555',
                     'svg.hashsalt': 'openEMS'})

# the default pulse, as in the usage example
fig, ax = plt.subplots(1, 2, figsize=(11, 3.6), gridspec_kw={'width_ratios': [1, 1.25]})
plot_row(ax[0], ax[1], 5e9, 5e9, [(False, 'default')])
ax[0].set_xlabel('t [ns]')
ax[1].set_xlabel('f [GHz]')
save(fig, 'gauss_pulse.svg')

# the default and the DC-free pulse
fig, ax = plt.subplots(2, 2, figsize=(11, 7), gridspec_kw={'width_ratios': [1, 1.25]})
plot_row(ax[0, 0], ax[0, 1], 1.5e9, 1.5e9,
         [(False, 'default (cosine carrier)'), (True, 'dc_free (sine carrier)')])
plot_row(ax[1, 0], ax[1, 1], 0, 3e9,
         [(False, 'default (cosine carrier)'), (True, 'dc_free (monocycle)')])
ax[1, 0].set_xlabel('t [ns]')
ax[1, 1].set_xlabel('f [GHz]')
save(fig, 'gauss_dcfree.svg')
