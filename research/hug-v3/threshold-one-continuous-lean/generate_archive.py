"""Export exact binary coefficients; Lean independently proves all exported bounds.

This Python program is part of the input transcription boundary, not a theorem
prover. Re-running it must reproduce the committed Lean input bytes.
"""
import argparse,hashlib,json
from pathlib import Path
import numpy as np

def digest(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def generate(study,output):
    labels=[f'event-{i}-{side}' for i in (1,2,3) for side in ('left','right')]
    rows=json.loads((study/'snapshots.json').read_text())
    mapping={r['label']:r for r in rows}
    with np.load(study/'snapshots.npz',allow_pickle=False) as z:
        fields=[z['omega'][mapping[label]['index']].copy() for label in labels]
        seeds=[z['pairs'][mapping[label]['index']].copy() for label in labels]
    exponent=max(float(v).as_integer_ratio()[1].bit_length()-1 for field in fields
        for v in np.r_[field.real.ravel(),field.imag.ravel()])
    denominator=2**exponent
    def integer(value):
        p,q=float(value).as_integer_ratio()
        assert denominator%q==0
        return p*(denominator//q)
    lines=['import FrozenField','set_option maxRecDepth 100000',
        'set_option maxHeartbeats 40000000','namespace FrozenArchive',
        'open FrozenField',f'def denominator : ℕ := {denominator}']
    names=[];bounds=[]
    for label,field in zip(labels,fields):
        for component in range(3):
            name=label.replace('-','_')+f'_c{component}'
            names.append(name)
            lines.append(f'def {name} : List Wave := [')
            entries=[];mass=weighted=0
            for i,j,k in np.ndindex((11,11,11)):
                c=field[i,j,k,component];re,im=integer(c.real),integer(c.imag)
                entries.append(f'  ⟨{i-5}, {j-5}, {k-5}, {re}, {im}⟩')
                mass+=abs(re)+abs(im)
                weighted+=(abs(re)+abs(im))*(abs(i-5)+abs(j-5)+abs(k-5))
            lines.append(',\n'.join(entries)+']')
            bounds.append({'label':label,'component':component,'mass_numerator':str(mass),
                'weighted_mass_numerator':str(weighted)})
    lines+=['def components : List (List Wave) := ['+', '.join(names)+']',
        'theorem denominator_positive : 0 < denominator := by decide',
        'theorem component_count : components.length = 18 := by decide',
        'theorem all_component_bounds : components.all (fun ws => decide',
        '    (mass ws ≤ denominator ∧ weightedMass ws ≤ 4 * denominator)) = true := by decide',
        '/-- Continuous bounds on the unnormalized archived Fourier field. These',
        'are not lower bounds, normalized-flow bounds, or trajectory certificates. -/',
        'theorem continuous_component_bounds (ws : List Wave) (hws : ws ∈ components)',
        '    (x y : Point) : |value ws denominator x| ≤ 1 ∧',
        '    |value ws denominator x - value ws denominator y| ≤ 32 * ‖x - y‖ := by',
        '  have hb : mass ws ≤ denominator ∧ weightedMass ws ≤ 4 * denominator :=',
        '    of_decide_eq_true (List.all_eq_true.mp all_component_bounds ws hws)',
        '  have hd : (0 : ℝ) < denominator := by exact_mod_cast denominator_positive',
        '  have hm : (mass ws : ℝ) ≤ denominator := by exact_mod_cast hb.1',
        '  have hw : (weightedMass ws : ℝ) ≤ 4 * denominator := by exact_mod_cast hb.2',
        '  constructor',
        '  · exact le_trans (field_bound ws denominator_positive x) ((div_le_one hd).mpr hm)',
        '  · apply le_trans (field_difference_bound ws denominator_positive x y)',
        '    apply mul_le_mul_of_nonneg_right _ (norm_nonneg _)',
        '    apply (div_le_iff₀ hd).mpr',
        '    linarith',
        'end FrozenArchive']
    output.mkdir(parents=True,exist_ok=True)
    path=output/'FrozenArchive.lean'
    path.write_text('\n'.join(lines)+'\n',encoding='utf-8',newline='\n')
    metadata={'status':'INPUT_TRANSCRIPTION_ONLY','source_files':{
        name:digest(study/name) for name in ('snapshots.npz','snapshots.json')},
        'definition':'Real part of the archived Fourier sum with true mathematical pi; exact binary coefficients.',
        'denominator':str(denominator),'binary_exponent':exponent,
        'labels':[{'label':label,'index':mapping[label]['index'],'record':mapping[label],
            'seed_and_target_hex':[[float(v).hex() for v in p] for p in pair]}
            for label,pair in zip(labels,seeds)],
        'proposed_integer_totals':bounds,'generated_lean_sha256':digest(path)}
    (output/'archive-inputs.json').write_text(json.dumps(metadata,indent=2)+'\n',encoding='utf-8',newline='\n')
    print(json.dumps({'output':str(path),'bytes':path.stat().st_size,'components':18,'denominator_exponent':exponent}))

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--study-dir',type=Path,required=True);p.add_argument('--out-dir',type=Path,required=True)
    a=p.parse_args();generate(a.study_dir,a.out_dir)
