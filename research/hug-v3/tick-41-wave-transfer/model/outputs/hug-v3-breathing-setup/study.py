"""Default to checking the proposed setup. The run subcommand is a separate, explicit action."""
import argparse
import csv
from fractions import Fraction
import hashlib
import json
from pathlib import Path
import sys
from types import SimpleNamespace


HERE = Path(__file__).resolve().parent
UPSTREAM = HERE/"upstream"
PARENT_SEAL = "b815846bd7afe1aa1a91430c40b658fc44a4d13add5432de0aed424530bedea0"
CASES = ("breathing_off","breathing_on")


def read(path):
    return json.loads(path.read_bytes())


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def approved_arm(name):
    if name not in CASES: raise ValueError("Unknown comparison arm")
    if digest(UPSTREAM/"source_seal.json")!=PARENT_SEAL: raise ValueError("Hug v3 parent seal changed")
    for root,seal in ((UPSTREAM,"source_seal.json"),(HERE,"comparison-seal.json")):
        for relative,expected in read(root/seal).items():
            if digest(root/relative)!=expected: raise ValueError("Provenance mismatch: "+relative)
    if str(UPSTREAM) not in sys.path: sys.path.insert(0,str(UPSTREAM))
    import preflight
    if Path(preflight.__file__).resolve().parent!=UPSTREAM: raise ValueError("Wrong native preflight module")
    parent = preflight.approve("main")
    gate = preflight.validator()
    path = HERE/"declarations"/(name+".json")
    manifest = read(path)
    if manifest["run_id"]!=name or manifest["claims_corpus_validation"]: raise ValueError("Wrong study declaration")
    bounds = gate.load_bounds(UPSTREAM/"parameter_bounds.json")
    additions = gate.load_bounds(HERE/"comparison-bounds.json")
    if bounds.keys() & additions.keys(): raise ValueError("An added fixture bound shadows a native bound")
    problems = gate.validate(manifest,gate.load_register(UPSTREAM/"equation_register.csv"),
                             gate.load_chain(HERE/"comparison-chain.csv"),bounds|additions)
    if problems: raise ValueError("Comparison declaration refused: "+"; ".join(problems))
    p = manifest["parameters"]
    if not 0<p["comparison_dt"]<=parent["config"]["dt"] or not 0<p["comparison_end"]<=parent["config"]["end"]:
        raise ValueError("Step or horizon exceeds the sealed fixture")
    experiment = dict(arm=name.removeprefix("breathing_"),peak=p["comparison_peak_acceleration"],
                      step=p["comparison_dt"],end=p["comparison_end"],period=p["comparison_period"],
                      manifest_sha256=digest(path))
    return parent,experiment


def check_setup():
    """Read files and check geometry, interpolation and clocks. No model state or time step."""
    import numpy as np
    parent,off=approved_arm("breathing_off")
    other,on=approved_arm("breathing_on")
    assert parent==other and off["peak"]==0 and on["peak"]==.5
    for key in ("step","end","period"): assert off[key]==on[key]
    cfg=parent["config"];assert cfg["n"]==16 and cfg["end"]==1.6 and cfg["dt"]==.005
    assert cfg["read_feedback"]==1 and cfg["social_source"]==1 and cfg["social_distribution"]==1
    assert cfg["G0"]>0 and cfg["Gm"]>0 and cfg["initial_heat"]>0 and cfg["fabric_mobility"]>0
    assert cfg["write_rate"]>0 and cfg["capacity"]==4 and cfg["disabled_mode"]==-1
    left,right=[read(HERE/"declarations"/(name+".json")) for name in CASES]
    for obj in (left,right):
        obj.pop("run_id");obj["parameters"].pop("comparison_peak_acceleration")
        obj["fixture_ranges"].pop("comparison_peak_acceleration")
    assert left==right
    from breathing import Trail,fluid_velocity,sample_grid,unit_breath,wrap
    with (HERE/"marker-seeds.csv").open(newline="") as f: trail=Trail(list(csv.DictReader(f)))
    pts=trail.seeds
    assert np.all(pts[:,2]==0) and np.all((pts>=-.5)&(pts<.5))
    np.testing.assert_array_equal(pts[-1],[0.,0.,0.])
    np.testing.assert_allclose(pts[0],[-291/1300,-56/540,0.],rtol=0,atol=2e-15)
    q=np.array([v[:2] for v in trail.info])
    np.testing.assert_allclose(q[:,1],q[:,0]/2,atol=0,rtol=0)
    assert np.all(np.diff(q[:,1])>0)
    # If the coordinate representation crosses a cube face, no water gap is invented.
    _,none=trail.refine(wrap(pts+[.49,0.,.49]),0.)
    assert none==[]
    split=pts.copy();split[0,2]+=.005
    grown,births=trail.refine(split,0.)
    assert len(grown)==802 and births[0][1:4]==[801,0,1] and np.array_equal(grown[:801],split)

    n=cfg["n"];x=np.arange(n)/n-.5
    xyz=np.stack(np.meshgrid(x,x,x,indexing="ij"),-1)
    b=unit_breath(xyz)*on["peak"]
    freq=np.fft.fftfreq(n)*n
    k=2*np.pi*np.stack(np.meshgrid(freq,freq,freq,indexing="ij"),-1)
    khat=np.fft.fftn(b,axes=(0,1,2));mask=np.all(abs(k/(2*np.pi))<n/3,axis=-1)
    div_error=float(np.max(abs(np.fft.ifftn(1j*np.sum(k*khat,axis=-1)))))
    above_cutoff=float(np.max(abs(khat[~mask]))/n**3)
    assert div_error<2e-13 and above_cutoff<1e-14 and np.max(abs(b.mean(axis=(0,1,2))))<1e-13
    assert float(np.max(abs(b)))==.5 and np.all(b[...,1]==0)
    shifts=np.eye(3)
    for shift in shifts: np.testing.assert_allclose(unit_breath(pts+shift),unit_breath(pts),atol=2e-14,rtol=0)
    depths=np.tile(pts[0],(3,1));depths[:,2]=[-.25,0.,.25]
    drive=on["peak"]*unit_breath(depths)
    assert drive[0,0]<0 and drive[1,0]<0 and drive[2,0]>0
    spectral=SimpleNamespace(n=n,freq=freq,hat=lambda a:np.fft.fftn(a,axes=(0,1,2)))
    # An analytic test field, never an evolved Hug velocity.
    np.testing.assert_allclose(fluid_velocity(spectral,b,pts),on["peak"]*unit_breath(pts),atol=5e-14,rtol=0)
    np.testing.assert_allclose(sample_grid(b,xyz[2,3]),b[2,3],atol=3e-15)
    np.testing.assert_allclose(sample_grid(b,pts+[1,0,0]),sample_grid(b,pts),atol=3e-15)
    with (HERE/"prime-times.csv").open(newline="") as f: schedule=list(csv.DictReader(f))
    expected=[2,3,5,7,11,13,17,19,23,29,31,37,41]
    assert [int(r["prime"]) for r in schedule]==expected
    event_ends={Fraction(str(e["end"])):e["event_id"] for e in parent["events"]}
    views=0
    for i,r in enumerate(schedule):
        t=Fraction(r["model_time"]);assert t==Fraction(i,10)
        assert t*320==int(r["old_marker_step"]) and t*250==int(r["old_comparison_step"])
        assert t/Fraction(str(on["step"]))==int(r["comparison_step"])
        sides=r["read_sides"].split("|")
        assert sides==(["before_write","after_write"] if t in event_ends else ["at"])
        if t in event_ends: assert int(r["event_ending"])==event_ends[t]
        views+=len(sides)
    assert views==16 and round(on["end"]/on["step"])==600
    return dict(status="Prepared; no Hug arm constructed or advanced by this check.",
                upstream_files_verified=len(read(UPSTREAM/"source_seal.json")),named_declarations_verified=list(CASES),
                native_grid=[n]*3,prime_count=len(schedule),read_sides_per_arm=views,
                primary_rows_per_arm=801*len(schedule),rows_including_pre_write_per_arm=801*views,
                observations_with_both_sides=[11,23,41],periodic_force_max_component=.5,
                spectral_divergence_max=div_error,force_above_cutoff_max_coefficient=above_cutoff,
                drive_x_at_three_probe_depths=drive[:,0].tolist(),
                checks=["both arms inherit identical complete Hug configuration and event script",
                        "only peak acceleration differs in the new declarations",
                        "all three spatial seams, normalized amplitude, solenoidal band-limited force",
                        "801 original IDs and seam-safe neighbour lengths",
                        "analytic Fourier-velocity test and periodic scalar/tensor sampler",
                        "all 13 historical clock labels and three before/after write pairs"])


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    sub=parser.add_subparsers(dest="action")
    sub.add_parser("check")
    sim=sub.add_parser("run")
    sim.add_argument("arm",choices=["off","on"])
    sub.add_parser("compare")
    args=parser.parse_args()
    if args.action in (None,"check"):
        print(json.dumps(check_setup(),indent=2))
    elif args.action=="compare":
        approved_arm("breathing_off"); approved_arm("breathing_on")
        from compare_arms import compare
        print(compare(HERE/"results"))
    else:
        name="breathing_"+args.arm
        approved_arm(name)
        from breathing import run_arm
        print(json.dumps(run_arm(name),indent=2))


if __name__=="__main__": main()
