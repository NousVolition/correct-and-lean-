"""Pre-run declaration gate for corpus studies.

A run declares, before it executes, which rows of the 23 October 2026 equation
register it implements, every rule it adds that the register does not contain,
and every numerical parameter it uses together with the range it allows. The
gate checks the declaration against three fixed files:

    equation_register.csv   the corpus relations a run may claim to implement
    study_chain.csv         which earlier studies carry added rules
    parameter_bounds.json   the perimeter: corpus bounds, fixture parameters,
                            register choices for the laws, and the hard stops

The gate checks the declaration, not the physics: an accepted manifest means
the run says what it is, not that the run is correct.

Usage:
    python run_manifest.py path/to/run_manifest.json

Exit status 0 means accepted; 1 lists every refusal. Nothing is executed and
nothing is written. Import `validate` to call the same gate from a runner before
any model call, so a run with an undeclared rule or an out-of-perimeter value
stops before it starts.
"""
from pathlib import Path
import csv, json, math, re, sys

P = Path(__file__).resolve().parent
REGISTER = P / 'equation_register.csv'
CHAIN = P / 'study_chain.csv'
BOUNDS = P / 'parameter_bounds.json'
INHERITED = re.compile(r'historical|added|assumed|invented|analyst', re.I)
STATUSES = ('corpus', 'numerical fixture', 'added-rule historical')
DATE = re.compile(r'^\d{4}-\d{2}-\d{2}$')
REQUIRED = ('study', 'run_id', 'date', 'declared_by', 'register_rows', 'added_rules',
            'inherits', 'parameters', 'fixture_ranges', 'claims_corpus_validation')
OPTIONAL = ('notes',)
UNIT_TOLERANCE = 1e-9


def load_register(path=REGISTER):
    with open(path, encoding='utf-8', newline='') as f:
        rows = list(csv.DictReader(f))
    if not rows or any(k not in rows[0] for k in ('source', 'relation', 'equation')):
        raise ValueError('equation_register.csv must have source, relation and equation columns')
    return rows


def load_chain(path=CHAIN):
    with open(path, encoding='utf-8', newline='') as f:
        return {r['study']: r for r in csv.DictReader(f)}


def chain_status(study, chain):
    """Status the study chain assigns to a prior study, or None when it is not listed."""
    row = chain.get(study)
    if row is None:
        return None
    return 'added-rule historical' if INHERITED.search(row['scope']) else 'corpus'


def load_bounds(path=BOUNDS):
    data = json.loads(Path(path).read_text(encoding='utf-8'))
    params = data.get('parameters') if isinstance(data, dict) else None
    if not isinstance(params, dict) or not params:
        raise ValueError('parameter_bounds.json must have a non-empty "parameters" object')
    for name, spec in params.items():
        if spec.get('kind') not in ('integer', 'real', 'choice', 'unit_vector'):
            raise ValueError(f'parameter_bounds.json: {name} has an unknown kind')
        if spec.get('source') not in ('corpus', 'fixture'):
            raise ValueError(f'parameter_bounds.json: {name} must be sourced "corpus" or "fixture"')
    return params


def _text(value, limit=2000):
    return isinstance(value, str) and value.strip() != '' and len(value) <= limit


def _finite(value):
    return isinstance(value, (int, float)) and not isinstance(value, bool) and math.isfinite(value)


def _outside(value, spec):
    """Why the scalar value breaks the bound in spec, or None when it is inside."""
    lo, hi = spec.get('min'), spec.get('max')
    if lo is not None:
        if spec.get('exclusive_min') and value <= lo:
            return f'must be > {lo}'
        if not spec.get('exclusive_min') and value < lo:
            return f'must be >= {lo}'
    if hi is not None:
        if spec.get('exclusive_max') and value >= hi:
            return f'must be < {hi}'
        if not spec.get('exclusive_max') and value > hi:
            return f'must be <= {hi}'
    return None


def check_parameters(parameters, fixture_ranges, bounds=None, register_rows=()):
    """Perimeter check: every value inside its corpus bound, every fixture value
    inside a range the run declared, every law one of the register's choices.

    Returns a list of refusals; an empty list means the perimeter holds.
    A value may be a list, meaning a sweep: each entry is checked.
    """
    bounds = load_bounds() if bounds is None else bounds
    errors = []
    if not isinstance(parameters, dict):
        return ['parameters must be an object of name: value (empty when the run has no numerical parameters)']
    if not isinstance(fixture_ranges, dict):
        return ['fixture_ranges must be an object of name: {"min": a, "max": b}']
    ranges = {}
    for name, rng in fixture_ranges.items():
        tag = f'fixture_ranges.{name}'
        spec = bounds.get(name)
        if spec is None:
            errors.append(f'{tag}: not in parameter_bounds.json; an unlisted parameter is an undeclared rule')
            continue
        if spec['kind'] in ('choice', 'unit_vector'):
            errors.append(f'{tag}: a {spec["kind"]} parameter has no numeric range; declare its value in parameters')
            continue
        if not isinstance(rng, dict) or not _finite(rng.get('min')) or not _finite(rng.get('max')) or rng['min'] > rng['max']:
            errors.append(f'{tag} must be {{"min": a, "max": b}} with finite a <= b')
            continue
        if spec['source'] == 'corpus':
            for end in ('min', 'max'):
                why = _outside(rng[end], spec)
                if why:
                    errors.append(f'{tag}.{end} = {rng[end]} widens the corpus bound ({why}); a corpus bound cannot be edited by a run manifest')
        ranges[name] = rng
    for name, value in parameters.items():
        tag = f'parameters.{name}'
        spec = bounds.get(name)
        if spec is None:
            errors.append(f'{tag}: not in parameter_bounds.json; add it there or declare it as an added rule (hard stop 1)')
            continue
        row = spec.get('register_row')
        if row and row not in register_rows:
            errors.append(f'{tag} belongs to register row {row!r}, which register_rows does not declare')
        kind = spec['kind']
        if kind == 'unit_vector':
            length = spec.get('length', 2)
            if not isinstance(value, list) or len(value) != length or not all(_finite(v) for v in value):
                errors.append(f'{tag} must be a list of {length} finite numbers')
                continue
            norm = math.sqrt(sum(v * v for v in value))
            if abs(norm - 1) > UNIT_TOLERANCE:
                errors.append(f'{tag} must be a unit vector (norm {norm:.6g})')
            continue
        values = value if isinstance(value, list) else [value]
        if not values:
            errors.append(f'{tag} is an empty sweep')
            continue
        if spec['source'] == 'fixture' and name not in ranges:
            errors.append(f'{tag} is a fixture parameter with no declared range in fixture_ranges; silence about a range is a silent assumption (hard stop 3)')
        for v in values:
            if kind == 'choice':
                if v not in spec['choices']:
                    errors.append(f'{tag} = {v!r} is not one of the register choices {spec["choices"]}; a new law is an added rule with its own name (hard stop 5)')
                continue
            if kind == 'integer' and (isinstance(v, bool) or not isinstance(v, int)):
                errors.append(f'{tag} = {v!r} must be an integer')
                continue
            if kind == 'real' and not _finite(v):
                errors.append(f'{tag} = {v!r} must be a finite number')
                continue
            why = _outside(v, spec)
            if why:
                errors.append(f'{tag} = {v} is outside the {spec["source"]} bound: {why} (hard stop 2)')
            rng = ranges.get(name)
            if rng is not None and not (rng['min'] <= v <= rng['max']):
                errors.append(f'{tag} = {v} is outside its declared range [{rng["min"]}, {rng["max"]}] (hard stop 4)')
    return errors


def validate(manifest, register=None, chain=None, bounds=None):
    """Return a list of refusals; an empty list means the manifest is accepted."""
    register = load_register() if register is None else register
    chain = load_chain() if chain is None else chain
    bounds = load_bounds() if bounds is None else bounds
    relations = {r['relation'] for r in register}
    errors = []
    if not isinstance(manifest, dict):
        return ['manifest must be a JSON object']
    for key in REQUIRED:
        if key not in manifest:
            errors.append(f'missing field: {key}')
    for key in manifest:
        if key not in REQUIRED and key not in OPTIONAL:
            errors.append(f'unknown field: {key} (a manifest carries only the declared fields; put remarks in "notes")')
    if errors:
        return errors
    for key in ('study', 'run_id', 'declared_by'):
        if not _text(manifest[key], 200):
            errors.append(f'{key} must be a short non-empty string')
    if not isinstance(manifest['date'], str) or not DATE.match(manifest['date']):
        errors.append('date must be YYYY-MM-DD')
    rows = manifest['register_rows']
    if not isinstance(rows, list) or any(not isinstance(r, str) for r in rows):
        errors.append('register_rows must be a list of register relation names')
        rows = []
    for r in rows:
        if r not in relations:
            errors.append(f'register row not in equation_register.csv: {r!r} (exact relation name required)')
    if len(set(rows)) != len(rows):
        errors.append('register_rows repeats a row')
    added = manifest['added_rules']
    if not isinstance(added, list):
        errors.append('added_rules must be a list (empty when nothing is added)')
        added = []
    names = set()
    for i, rule in enumerate(added):
        tag = f'added_rules[{i}]'
        if not isinstance(rule, dict):
            errors.append(f'{tag} must be an object with name, statement and reason')
            continue
        for key in ('name', 'statement', 'reason'):
            if not _text(rule.get(key)):
                errors.append(f'{tag}.{key} is required and must be non-empty')
        name = rule.get('name')
        if isinstance(name, str):
            if name in relations:
                errors.append(f'{tag}.name {name!r} is a register relation; an added rule may not take a corpus name')
            if name in names:
                errors.append(f'{tag}.name {name!r} is declared twice')
            names.add(name)
        replaces = rule.get('replaces')
        if replaces is not None and replaces not in relations:
            errors.append(f'{tag}.replaces must name a register relation or be omitted')
    inherits = manifest['inherits']
    if not isinstance(inherits, list):
        errors.append('inherits must be a list (empty when nothing is inherited)')
        inherits = []
    inherited_added = False
    for i, item in enumerate(inherits):
        tag = f'inherits[{i}]'
        if not isinstance(item, dict) or not _text(item.get('study'), 200) or item.get('status') not in STATUSES:
            errors.append(f'{tag} must be {{"study": name, "status": one of {STATUSES}}}')
            continue
        expected = chain_status(item['study'], chain)
        if expected is None:
            errors.append(f'{tag}.study {item["study"]!r} is not in study_chain.csv; add it to the chain before inheriting from it')
        elif expected == 'added-rule historical' and item['status'] != expected:
            errors.append(f'{tag}.study {item["study"]!r} carries added rules in study_chain.csv; its status must be "added-rule historical"')
        if item['status'] == 'added-rule historical':
            inherited_added = True
    errors.extend(check_parameters(manifest['parameters'], manifest['fixture_ranges'], bounds, rows))
    if 'notes' in manifest and not isinstance(manifest['notes'], str):
        errors.append('notes must be a string')
    claim = manifest['claims_corpus_validation']
    if not isinstance(claim, bool):
        errors.append('claims_corpus_validation must be true or false')
    elif claim:
        if added:
            errors.append('claims_corpus_validation cannot be true when any rule is added (C01: added rules do not validate the corpus)')
        if inherited_added:
            errors.append('claims_corpus_validation cannot be true when an inherited study carries added rules (C01: no exact-corpus validation is inherited from them)')
        if not rows:
            errors.append('claims_corpus_validation cannot be true when no register row is implemented')
    if not rows and not added:
        errors.append('a run must implement at least one register row or declare at least one added rule')
    return errors


def main(argv):
    if len(argv) != 2:
        print(__doc__)
        return 2
    manifest = json.loads(Path(argv[1]).read_text(encoding='utf-8'))
    errors = validate(manifest)
    if errors:
        print('Run manifest refused:')
        for e in errors:
            print(f'  - {e}')
        return 1
    print(f"Run manifest accepted: {manifest['study']} / {manifest['run_id']} ({manifest['date']})")
    print(f"  register rows: {', '.join(manifest['register_rows']) or 'none'}")
    print(f"  added rules: {', '.join(r['name'] for r in manifest['added_rules']) or 'none'}")
    bounds = load_bounds()
    fixture = [k for k in manifest['parameters'] if bounds[k]['source'] == 'fixture']
    corpus = [k for k in manifest['parameters'] if bounds[k]['source'] == 'corpus']
    print(f"  parameters inside corpus bounds: {', '.join(corpus) or 'none'}")
    print(f"  fixture parameters with declared ranges: {', '.join(fixture) or 'none'}")
    print(f"  claims corpus validation: {manifest['claims_corpus_validation']}")
    return 0


if __name__ == '__main__':
    sys.exit(main(sys.argv))
