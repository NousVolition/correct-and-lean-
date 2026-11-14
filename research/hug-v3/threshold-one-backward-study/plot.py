"""Plot the measured distance along the backward trace, from the retained arrays."""
import argparse
import json
from pathlib import Path

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np

HERE = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--output', type=Path, required=True, help='New figure directory')
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=False)
    rows = json.loads((HERE/'normal/measurements.json').read_text())
    plt.rcParams.update({'font.size': 11, 'svg.hashsalt': 'threshold-one-backward'})
    fig, axes = plt.subplots(3, 1, figsize=(11, 9), sharex=True, layout='constrained')
    with np.load(HERE/'normal/traces.npz') as lines:
        for event, ax in enumerate(axes, 1):
            for side, color, style in [('left', '#176387', '-'), ('right', '#bd7433', '--')]:
                row = next(r for r in rows if r['label'] == f'event-{event}-{side}')
                s, p = lines[row['label']+'_s'][::-1], lines[row['label']+'_p'][::-1]
                delta = p-row['B']
                d = np.linalg.norm(delta-np.rint(delta), axis=1)
                ax.plot(-s, d, style, color=color, lw=1.05, alpha=.85,
                        label=f'{side.capitalize()} bracket side')
                if side == 'left':
                    for length, marker, mcolor in [(3, 'o', '#9f2d45'), (6, 's', '#734da3'), (12, '*', '#202b35')]:
                        win = row['windows'][f'back_{length}_only']['winner']
                        ax.scatter(-win['s'], win['d'], marker=marker, color=mcolor,
                                   s=95 if length == 12 else 50, zorder=5,
                                   label=f'Best through {length}' if event == 1 else None)
                    win = row['windows']['back_12_only']['winner']
                    ax.annotate(f"L = {-win['s']:.6f}; gap = {win['d']:.6f}",
                                (-win['s'], win['d']), xytext=(8 if event < 3 else -235, 14),
                                textcoords='offset points', fontsize=10,
                                bbox={'facecolor': 'white', 'edgecolor': 'none', 'alpha': .9})
            ax.axvspan(0, 3, color='#e6edf2', alpha=.7, zorder=-2)
            for endpoint in (3, 6):
                ax.axvline(endpoint, color='#637383', lw=.8, ls=':')
            ax.set_title(f'Exchange {event}: frozen fields near t = {row["time"]:.9f}', loc='left', fontsize=12)
            ax.set_ylabel('Periodic gap to B')
            ax.grid(axis='y', alpha=.2)
            ax.set_ylim(bottom=.10 if event < 3 else .12)
            ax.spines[['top', 'right']].set_visible(False)
    axes[0].legend(loc='upper center', ncol=3, fontsize=9, framealpha=.95)
    axes[-1].set_xlabel('Backward distance from A, L = -s (cube lengths)')
    axes[-1].set_xlim(0, 12)
    axes[-1].set_xticks(range(13))
    fig.suptitle('Threshold 1: extending only the opposite direction from A\n'
                 'Numerical frozen-field traces; no certified continuous error bound', fontsize=15)
    fig.savefig(args.output/'backward-distance.png', dpi=180)
    fig.savefig(args.output/'backward-distance.svg', metadata={'Date': None})
    svg = args.output/'backward-distance.svg'
    svg.write_bytes(('\n'.join(line.rstrip() for line in svg.read_text(encoding='utf-8').splitlines())+'\n').encode('utf-8'))
    plt.close(fig)


if __name__ == '__main__':
    main()
