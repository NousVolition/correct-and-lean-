"""Render an explanation of published retention results; no solver is run.

Numbers: ../pair-origin-study/README.md and ../observer-follow-study/README.md.
Run with Python and matplotlib. Outputs are written beside this source.
AI-generated; dictated and directed by NousVolition.
"""

from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, Rectangle


OUT = Path(__file__).resolve().parent
plt.rcParams.update({"font.family": "DejaVu Sans", "svg.fonttype": "none",
                     "svg.hashsalt": "retention-map-2026-11-13"})
fig = plt.figure(figsize=(16, 12), facecolor="#f8fafc")
ax = fig.add_axes([0, 0, 1, 1])
ax.set_xlim(0, 1)
ax.set_ylim(0, 1)
ax.axis("off")
INK = "#182e40"
MUTED = "#42586a"
BLUE = "#2867a4"
TEAL = "#167b78"
PURPLE = "#7352a2"
AMBER = "#a66717"


def txt(x, y, s, size=14, color=INK, weight="normal", **kwargs):
    return ax.text(x, y, s, fontsize=size, color=color, weight=weight,
                   va="top", linespacing=1.45, **kwargs)


def box(x, y, w, h, face="white", edge="#d8e2e9"):
    ax.add_patch(FancyBboxPatch((x, y), w, h,
                 boxstyle="round,pad=0.009,rounding_size=0.008",
                 linewidth=1.2, facecolor=face, edgecolor=edge))


txt(.035, .969, "Does it leave with what it came with?", 30, weight="bold")
txt(.035, .922, "Three completed studies  |  threshold 0.015  |  after-write tick 41: model time 1.2 to 1.3", 14, MUTED)

meanings = [
    ("SAME IDENTITY", "540 leaves the pair's view.\n872 enters it.\nBoth labels stay identifiable."),
    ("SAME RECORD", "3 shared decoded records\nstay byte-for-byte unchanged.\nStored material still evolves."),
    ("SAME ORIGIN?", "44.65% of starting context\nis still inside; 55.35%\nis elsewhere in the domain."),
    ("SAME AMOUNT?", "100.46% of the starting\namount is inside at the end.\nThe mix has changed."),
]
for i, (heading, body) in enumerate(meanings):
    x = .035 + i * .237
    box(x, .733, .219, .139, face="#eef5fb", edge="#ccddea")
    txt(x + .009, .855, heading, 15, BLUE, "bold")
    txt(x + .009, .815, body, 13.1)

txt(.035, .697, "The follow-up questions we already tested", 19, weight="bold")
studies = [
    ("1  Pair 25: retention", "Three shared records survive.\nLocal readings change.\nA readout-boundary artifact is\ncorrected; the failure is preserved.", "40 historical Lean targets"),
    ("2  Pair 25: origins", "Wider view: 364 to 364 labels.\n872 arrives before 540 leaves;\nthe count briefly reaches 365.\nSame endpoint count, new member.", "77 historical Lean targets"),
    ("3  Follow 540 and 872", "Finest run at 1.3: original context\n540: 43.94% | 872: 42.95% still nearby.\nEach keeps its 8 starting material\nneighbors at recorded steps.", "134 historical Lean targets"),
]
for i, (heading, body, lean) in enumerate(studies):
    x = .035 + i * .318
    box(x, .471, .299, .177)
    txt(x + .012, .633, heading, 18, TEAL, "bold")
    txt(x + .012, .594, body, 13.5)
    txt(x + .012, .496, lean, 13, PURPLE, "bold")

txt(.035, .440, "Follow the origin as well as the total", 19, weight="bold")
txt(.035, .404, "Pair 25, primary radius-0.075 union; 48³ grid, step 0.00025; read at time 1.3", 12.5, MUTED)

# Exact displayed source numbers, all relative to starting inside context.
retained = 44.653936
elsewhere = 55.346064
outside = 47.155486
later = 8.649760
total = 100.459181
x0, scale, bar_h = .225, .00645, .029
legend = [(TEAL, "Starting origin, still inside"),
          ("#dbe4eb", "Starting origin, elsewhere"),
          (BLUE, "Outside origin, now inside"),
          (AMBER, "Later source, now inside")]


def bar(y, segments):
    x = x0
    for value, color, text_color in segments:
        width = value * scale
        ax.add_patch(Rectangle((x, y), width, bar_h, facecolor=color,
                               edgecolor="#f8fafc", linewidth=1))
        ax.text(x + width / 2, y + bar_h / 2, f"{value:.2f}%",
                fontsize=12.5, color=text_color, ha="center", va="center", weight="bold")
        x += width


txt(.035, .364, "Where the starting\ncontext is now", 13, weight="bold")
bar(.332, [(retained, TEAL, "white"), (elsewhere, "#dbe4eb", INK)])
txt(.905, .357, "100.00%", 13, weight="bold")
txt(.035, .305, "What is inside\nthe window now", 13, weight="bold")
bar(.274, [(retained, TEAL, "white"), (outside, BLUE, "white"), (later, AMBER, "white")])
txt(.905, .299, f"{total:.2f}%", 13, weight="bold")
for i, (color, label) in enumerate(legend):
    col, row = i % 2, i // 2
    lx, ly = .225 + .355 * col, .243 - .027 * row
    ax.add_patch(Rectangle((lx, ly - .012), .011, .011, color=color))
    txt(lx + .017, ly, label, 11.5, MUTED)
txt(.035, .178, "All percentages use the amount initially inside as denominator. Context C is a model scalar, not water mass.", 11.6, MUTED)

box(.035, .070, .45, .071, face="#edf6f5", edge="#cde2df")
box(.513, .070, .45, .071, face="#f3eff9", edge="#ded5ec")
txt(.047, .132, "NUMERICAL OBSERVATIONS", 12.5, TEAL, "bold")
txt(.047, .107, "Recorded steps and chosen windows; full physical contents\nand continuum convergence remain unresolved.", 11.8)
txt(.525, .132, "LEAN CHECKS", 12.5, PURPLE, "bold")
txt(.525, .107, "Finite rules, supplied numbers, memberships and bytes;\nthe fluid evolution is outside these proofs.", 11.8)
txt(.035, .040, "Leaving a view does not mean leaving the basin. Overlapping windows are not private holdings.", 11.5, MUTED)
txt(.965, .020, "AI-generated; dictated and directed by NousVolition.  Sources and scope in the accompanying page.", 10, MUTED, ha="right")

fig.savefig(OUT / "retention-map.png", dpi=150, facecolor=fig.get_facecolor(),
            metadata={"Software": "matplotlib", "Description": "Explanation of published threshold-0.015 retention results."})
fig.savefig(OUT / "retention-map.svg", facecolor=fig.get_facecolor(),
            metadata={"Date": None, "Title": "Does it leave with what it came with?",
                      "Description": "Historical numerical observations and separate finite Lean checks. No new simulation or theorem."})
plt.close(fig)
