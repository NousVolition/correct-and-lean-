"""Render the audit's saved readings. Requires matplotlib; no solver is run."""
import argparse
import json
from pathlib import Path
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

HERE = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--preview", type=Path)
    args = parser.parse_args()
    data = json.loads((HERE / "results.json").read_text(encoding="utf-8"))["fluid"]
    native = data["native_spatial"]["by_time"]
    sparse = data["sparse_spatial"]["by_time"]
    plt.rcParams.update({"font.family":"DejaVu Sans","font.size":10,"svg.hashsalt":"tick-35-41-audit"})
    fig, axes = plt.subplots(2, 1, figsize=(10, 6.5), sharex=True, gridspec_kw={"height_ratios":[2,1.25]})
    fig.subplots_adjust(left=.105,right=.97,top=.86,bottom=.14,hspace=.22)
    fig.suptitle("The endpoints agree; the readings between them still differ",x=.105,y=.97,ha="left",fontsize=16,fontweight="bold")
    fig.text(.105,.915,"40³–48³ · same 25 material pairs · threshold 0.015 · breathing on",fontsize=11)
    times = [r["time"] for r in native]
    axes[0].plot(times,[r["maximum_difference"] for r in native],color="#A8452B",lw=1.2,marker=".",ms=4,label="201 native times, spacing 0.0005")
    axes[0].scatter([r["time"] for r in sparse],[r["maximum_difference"] for r in sparse],s=23,facecolors="white",edgecolors="#243B53",lw=.8,zorder=4,label="51 earlier times, spacing 0.002")
    axes[0].annotate("Pair 23 · 1.169\n0.102667",xy=(1.169,.1026668676),xytext=(1.144,.042),arrowprops={"arrowstyle":"->","color":"#A8452B"},color="#7E321E",fontsize=10)
    axes[0].set_ylabel("Largest gap difference\nall pairs and both windows")
    axes[0].set_ylim(.00008,.19)
    axes[0].legend(loc="upper left",frameon=False,fontsize=9)
    axes[1].plot(times,[r["outside_maximum_difference"] for r in native],color="#146B65",lw=1.2,marker=".",ms=4)
    axes[1].annotate("Pair 3 · 1.1955\n0.00118044",xy=(1.1955,.001180441966),xytext=(1.168,.00165),arrowprops={"arrowstyle":"->","color":"#146B65"},color="#10554F",fontsize=10)
    axes[1].set_ylim(.00008,.003)
    axes[1].set_ylabel("Largest gap difference\noutside fixed windows")
    axes[1].set_xlabel("Model time (separate from prime labels)")
    for ax in axes:
        ax.set_yscale("log")
        ax.axhline(.001,color="#737373",ls="--",lw=1)
        ax.axvline(1.1,color="#777777",lw=.6,alpha=.5)
        ax.axvline(1.2,color="#777777",lw=.6,alpha=.5)
        ax.grid(axis="y",alpha=.15)
        ax.spines[["top","right"]].set_visible(False)
        ax.set_xlim(1.099,1.201)
    axes[1].set_xticks([1.1,1.12,1.14,1.16,1.18,1.2], ["1.10\nTick 37","1.12","1.14","1.16","1.18","1.20\nTick 41, before write"])
    axes[1].get_xticklabels()[-1].set_ha("right")
    fig.text(.105,.025,"Dashed line: 0.001 target. Lines join saved readings; they do not bound unsampled times.",fontsize=9,color="#4A4A4A")
    fig.savefig(HERE / "sampling-comparison.svg",metadata={"Date":None})
    if args.preview:
        fig.savefig(args.preview,dpi=150,metadata={"Software":"Matplotlib"})
    plt.close(fig)


if __name__ == "__main__":
    main()
