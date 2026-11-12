"""Draw the completed numerical records and explain their scope."""
import os
os.environ.setdefault("MPLCONFIGDIR",str(__import__("pathlib").Path(__file__).resolve().parent/"mpl-config"))
import csv,json
from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch
ROOT=Path(__file__).resolve().parents[2]
OUT=ROOT/"outputs/pair25-retention"
LEAN=ROOT/"outputs/pair25-retention-lean"
def rows(path):
    with path.open(newline="") as f:return list(csv.DictReader(f))
def main():
    analysis=json.loads((OUT/"analysis.json").read_text())
    correction=json.loads((OUT/"cell-aware-check.json").read_text())
    proof=json.loads((LEAN/"receipt.json").read_text())
    fig,axes=plt.subplots(2,2,figsize=(13,8.6),gridspec_kw={"height_ratios":[.85,1]},layout="constrained")
    fig.suptitle("Following pair 25 through the next window",fontsize=20,fontweight="bold")
    ax=axes[0,0];ax.set_axis_off();ax.set_title("Shared records stay readable",loc="left",fontsize=15,pad=10)
    for x,heading,body in [
        (.02,"ENTRY · 1.2","3 existing records"),
        (.365,"51 SAMPLES","Check complete contents"),
        (.71,"EXIT · 1.3","The same 3 records")]:
        ax.add_patch(FancyBboxPatch((x,.42),.265,.35,boxstyle="round,pad=.02",facecolor="#e1f2ec",edgecolor="#367a68",transform=ax.transAxes))
        ax.text(x+.1325,.66,heading,ha="center",fontsize=10.5,weight="bold",transform=ax.transAxes)
        ax.text(x+.1325,.53,body,ha="center",fontsize=9,transform=ax.transAxes)
    for x in [.297,.642]:ax.annotate("",xy=(x+.055,.59),xytext=(x,.59),xycoords="axes fraction",arrowprops={"arrowstyle":"->","color":"#367a68","lw":2})
    ax.text(.02,.27,"40³, 48³, and 48³ with the smaller time step",fontsize=11,transform=ax.transAxes)
    ax.text(.02,.15,"These are shared memory records.\nA and B have no separately stored private inventory.",fontsize=10,color="#555555",transform=ax.transAxes)
    primary=rows(OUT/"n48_dt0p00025/local-budgets.csv")
    ax=axes[0,1];ax.set_title("Local values change while the pair moves\n48³ grid · time step 0.00025",loc="left",fontsize=12.5)
    colors=["#1d78a8","#d27327","#346e46","#8857a5"]
    for color,(point,field) in zip(colors,[("A","C"),("B","C"),("A","theta"),("B","theta")]):
        selected=[r for r in primary if r["point"]==point and r["field"]==field]
        entry=float(selected[0]["entry"])
        ax.plot([float(r["time"]) for r in selected],
                [100*(float(r["current"])/entry-1) for r in selected],
                label=point+" · "+("context" if field=="C" else "excess heat"),color=color,lw=2)
    ax.axhline(0,color="#999999",lw=.7);ax.set_xlabel("Model time");ax.set_ylabel("Change from entry (%)")
    ax.legend(fontsize=9,ncol=2);ax.grid(alpha=.15)
    ax=axes[1,0];ax.set_title("The readout boundary matters",loc="left",fontsize=15)
    original=rows(OUT/"n40_dt0p0005/local-budgets.csv")
    corrected=rows(ROOT/"outputs/pair25-retention-cellaware/n40_dt0p0005/local-budgets.csv")
    for source,label,color in [(original,"Original accounting","#ba4a3b"),(corrected,"Split at cell crossings","#2b7f69")]:
        selected=[r for r in source if r["point"]=="A" and r["field"]=="C"]
        ax.plot([float(r["time"]) for r in selected],[float(r["residual"])*1e6 for r in selected],label=label,lw=2.2,color=color)
    ax.axvspan(1.274,1.276,color="#e9d9bd",alpha=.65)
    ax.axhline(-1,color="#777777",ls="--",lw=1,label="Precision limit")
    ax.axhline(1,color="#777777",ls="--",lw=1)
    ax.set_xlabel("Model time");ax.set_ylabel("Unaccounted difference (millionths)")
    ax.set_ylim(-4.3,1.8);ax.grid(alpha=.15);ax.legend(fontsize=9,loc="lower left")
    ax.text(.03,.94,"Same fluid states and observed values",transform=ax.transAxes,va="top",fontsize=10)
    ax=axes[1,1];ax.set_title("What this test establishes",loc="left",fontsize=15);ax.set_axis_off()
    statements=[
        ("Retained","The original shared record contents survive."),
        ("Changed","Heat and context at A and B evolve."),
        ("Corrected","Splitting the readout at cell crossings closes\nits account without changing the fluid."),
        ("Still open","Whether every original physical content\nstays with this particular pair."),
        ("Lean checked","Finite retention rules and recorded accounts;\nno fluid-evolution or complete-retention proof.")
    ]
    for y,(title,body) in zip([.9,.72,.54,.32,.1],statements):
        ax.text(.02,y,title,weight="bold",fontsize=10.5,color="#275b68",transform=ax.transAxes)
        ax.text(.23,y,body,fontsize=10.5,va="center",transform=ax.transAxes)
    fig.supxlabel("After-write tick 41 (time 1.2) → time 1.3 · threshold 0.015, breathing-on experiment · AI-generated; dictated and directed by NousVolition.",fontsize=9)
    fig.savefig(OUT/"pair-retention.png",dpi=180)
    fig.savefig(OUT/"pair-retention.svg")
    table=[]
    for result in analysis["runs"]:
        m=result["metrics"]
        table.append(f"| {result['run']} | {m['max_local_budget_residual']:.9g} | {'PASS' if result['criteria']['local_budget_target_met'] else 'FAIL'} | 3 of 3 |")
    table.append(f"| 40³, cell-aware readout repeat | {correction['corrected_max_residual']:.9g} | {'PASS' if correction['corrected_target_met'] else 'FAIL'} | 3 of 3 |")
    values=[]
    for r in analysis["runs"][-1]["endpoint"]:
        values.append(f"| {r['point']} | {'Context C' if r['field']=='C' else 'Excess heat theta'} | {float(r['entry']):.9g} | {float(r['current']):.9g} | {float(r['change']):+.9g} |")
    text=f"""# What leaves with the pair?

The original shared memory records survive this next window. The pair's local fluid values change. This establishes neither that every original physical content stays with the pair nor that a changed value means something was lost.

![Pair retention results](pair-retention.png)

## The test that ran

“Pair 25” means the 25th A/B pair, stored as ID 24. All three continuations start from their exact saved **after-write state at tick 41, model time 1.2**, and end at **1.3**. The original prime schedule stops at 41, so 1.3 is labelled by model time. This new interval does not reconstruct the missing entry inventory at 1.1 or imply that the pair physically leaves the domain.

The runs use 40³/dt0.0005, 48³/dt0.0005 and 48³/dt0.00025, with 51 common observation times. The historical threshold-0.015, breathing-on, 801-native-observer, 384-material-point settings and solver equations are preserved. This added-drive experiment does not redefine the author's intended unforced system. There is no new write, imposed path closure or reversal.

## What stayed and what changed

All three original event records remain readable at every saved sample in every run: **{analysis['record_payload_checks']} complete payload comparisons** passed, using the full bytes and identities, not just matching names or checksums. Their stored material evolves, but the decoded contents remain the same. No stored directional-memory value decreases beyond the declared roundoff allowance. These records belong to the shared system; they are not a private inventory assigned to A or B.

The finest-time-step run records these point values:

| Point | Readout | At 1.2 | At 1.3 | Change |
| --- | --- | ---: | ---: | ---: |
{chr(10).join(values)}

These are concentrations/readouts at moving points, not masses inside a tracked parcel. The [audit record](analysis.json) lists the five local fluid values at entry and exit and checks the inventory of all 17 native state arrays. Full entry and exit snapshots are saved alongside it. A balanced incoming and outgoing exchange could keep a total unchanged while replacing its original contents. Origin tracking of every physical content is still missing.

## The apparent loss at a readout boundary

The original 40³ accounting failed its predeclared **0.000001** accuracy limit. Its largest jump occurred over model time 1.274–1.276, where A crossed an interpolation-cell boundary.

A controlled repeat split the accounting integral at those crossings. **Every entry and exit state array, all 51 pair positions and all sampled local values remained byte-identical or exactly identical as recorded.** Only the calculation of the accounting integral changed. Its maximum residual fell from **{correction['original_max_residual']:.9g}** to **{correction['corrected_max_residual']:.9g}**. This identifies the original 40³ failure as a numerical readout-integration artifact in this controlled comparison, not physical loss. The original failed receipt is preserved.

| Run | Largest local account residual | Original 1e-6 target | Entry records retained |
| --- | ---: | --- | --- |
{chr(10).join(table)}

The whole-system context and energy ledgers pass their separate 1e-10 and 1e-6 bounds. Spatial and time-step differences of the new local readouts are recorded in [analysis.json](analysis.json); no new convergence threshold was declared for these quantities.

## What Lean checked

[Lean package](../pair25-retention-lean/README.md): **{proof['target_count']} statements checked**, with the exact proof inputs, target list and axiom dependencies in its [receipt](../pair25-retention-lean/receipt.json).

The general statements concern complete finite record contents, missing or changed records, chained preservation, and accounting with changing or replaced contents. The data statements check full recorded payloads and exact decimal account numbers, including the original failed 40³ verdict and the corrected readout verdict. **Lean does not prove the numerical fluid trajectory, complete ownership of contents by this pair, continuum convergence or “everything came through.”**

## Evidence and reproduction

[Declared plan](../../work/pair25-retention/PLAN.md) · [Controlled readout plan](../../work/pair25-retention/CELL-READOUT-CHECK.md) · [Independent recount](analysis.json) · [Controlled comparison](cell-aware-check.json) · [SVG diagram](pair-retention.svg)

The instrumented one-step state matched the original solver exactly. An analytic and finite-difference check validated the local interpolation gradient. A synthetic crossing check validated the corrected accounting integral. Four refusal tests detect changed or missing records, duplicate observations and omitted exchange terms. The independent audit checks saved full payloads, entry checkpoint equality, source fingerprints, endpoint interpolation by a separate method, row coverage and the field inventory. Runtime stage extrema were inspected while the simulation ran; the independent audit does not replay every stage.

Full entry and exit arrays remain local. Historical simulations, published receipts and GitHub's main branch are unchanged by this follow-up.

**AI-generated; dictated and directed by NousVolition.**
"""
    (OUT/"README.md").write_text(text,encoding="utf-8")
    print(json.dumps(dict(png=str(OUT/"pair-retention.png"),report=str(OUT/"README.md"),lean_targets=proof["target_count"])))
if __name__=="__main__":main()
