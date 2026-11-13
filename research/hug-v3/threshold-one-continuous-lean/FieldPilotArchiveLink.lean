import FieldPilotCore
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
