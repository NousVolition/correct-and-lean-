"""Split the component computation from the monolithic archive import.

Both parts must pass Lean before claiming a bound on the archived component.
The computation alone refers to the explicit integer coefficient tree.
"""
from pathlib import Path
import argparse
parser=argparse.ArgumentParser();parser.add_argument('--directory',type=Path,required=True)
root=parser.parse_args().directory
p=(root/'FieldPilot.lean').read_text(encoding='utf-8')
p=p.replace('import FrozenArchive\n','')
p=p.replace('namespace FieldPilot','namespace FieldPilotCore').replace('end FieldPilot','end FieldPilotCore')
p=p.replace('abbrev D := denominator','def archiveDenominator : ℕ := 1208925819614629174706176\n'
    'theorem archiveDenominator_positive : 0 < archiveDenominator := by decide\n'
    'abbrev D := denominator')
p=p.replace('theorem archive_identity : flatten tree = FrozenArchive.event_1_left_c0 := by decide +kernel\n','')
p=p.replace('FrozenArchive.event_1_left_c0','(flatten tree)')
p=p.replace('FrozenArchive.denominator_positive','archiveDenominator_positive')
p=p.replace('FrozenArchive.denominator','archiveDenominator')
p=p.replace('  rw [← archive_identity]\n','')
p=p.replace('#print axioms archive_identity\n','')
(root/'FieldPilotCore.lean').write_text(p,encoding='utf-8',newline='\n')
link='''import FieldPilotCore
import FrozenArchive
set_option maxRecDepth 100000
namespace FieldPilotArchiveLink
open FieldPilotCore FrozenIntPolynomial FrozenFourierModel
theorem archive_identity : flatten tree = FrozenArchive.event_1_left_c0 := by decide +kernel
theorem archived_component_enclosure (x : ℝ) (hx : |x| ≤ 1) :
    |FrozenField.value FrozenArchive.event_1_left_c0 FrozenArchive.denominator (q x) -
      eval proposedPolynomial x / D| ≤ (1 / 10^18 : ℝ) := by
  rw [← archive_identity]
  exact continuous_field_enclosure x hx
#print axioms archive_identity
#print axioms archived_component_enclosure
end FieldPilotArchiveLink
'''
(root/'FieldPilotArchiveLink.lean').write_text(link,encoding='utf-8',newline='\n')
print({'computation_bytes':len(p.encode()),'archive_link_bytes':len(link.encode())})
