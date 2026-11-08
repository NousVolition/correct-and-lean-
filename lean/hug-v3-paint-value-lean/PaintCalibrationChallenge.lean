import PaintCalibrationDefinitions

namespace HugV3.Source.PaintCalibrationVerified
noncomputable section
open StreetWhole PaintCalibration
open scoped BigOperators

theorem declared_start (G : Geometry) :
    (∀ x, (initial G).g x 3 = 0) ∧ (initial G).A = 0 ∧ (initial G).context = home := by sorry

theorem accepted_original_field_rate (G : Geometry) (s d : State) (t : ℝ)
    (ok : rhs G t s = some d) :
    ∃ rs, readRecords s = some rs ∧ d = rhsFromRecords G t s rs ∧
      d.A = 0.08 * (socialRates G t s rs).utility ∧
      ∀ x, d.g x 3 = contextTransport (fun y => s.g y 3) (velocity s) x
        + s.A * sourceKernel G t s rs x := by sorry

theorem private_context_comparison (G : Geometry) (s : State) (i : Actor)
    (h t : ℝ) (rs : List (Fin 4 × Record)) :
    (shiftPersonalContext s i h).g = s.g ∧
    observations G (shiftPersonalContext s i h) = observations G s ∧
    readRecords (shiftPersonalContext s i h) = readRecords s ∧
    ∀ x, (rhsFromRecords G t (shiftPersonalContext s i h) rs).g x 3 =
      (rhsFromRecords G t s rs).g x 3 := by sorry

theorem footprint_compares_full_inputs (y : FullState) (B : Scalar) (L : Footprint) (h : ℝ) :
    (fullLineInput y (profile B L h)).state.context = y.state.context ∧
    (fullLineInput y (profile B L h)).starts = y.starts ∧
    {(fullLineInput y (profile B L h)).state with g := y.state.g} = y.state ∧
    (∀ x k, k ≠ 3 → (fullLineInput y (profile B L h)).state.g x k = y.state.g x k) ∧
    ∀ x, (fullLineInput y (profile B L h)).state.g x 3 = B x + h * indicator L x := by sorry

theorem same_footprint_and_person_distinct_values (y : FullState) (B : Scalar)
    (L : Footprint) (x : Grid) (marked : L x = true) (h : ℝ) (pos : 0 < h) :
    (∀ z, (profile B L h z ≠ B z ↔ profile B L (2*h) z ≠ B z)) ∧
    (fullLineInput y (profile B L h)).state.context =
      (fullLineInput y (profile B L (2*h))).state.context ∧
    (fullLineInput y (profile B L h)).state.g x 3 ≠
      (fullLineInput y (profile B L (2*h))).state.g x 3 := by sorry

theorem unfixed_background_allows_any_contrast (B : Scalar) (L : Footprint) (h k : ℝ) :
    profile (fun x => B x + (h-k)*indicator L x) L k = profile B L h := by sorry

theorem independent_field_total_recovers_contrast (B : Scalar) (L : Footprint)
    (h : ℝ) (nonemptyVolume : total (indicator L) ≠ 0) :
    (total (profile B L h) - total B) / total (indicator L) = h := by sorry

theorem marked_cell_has_positive_volume (L : Footprint) (x : Grid) (marked : L x = true) :
    0 < total (indicator L) := by sorry

theorem original_transport_redistributes_field (C : Scalar) (u : Vector) :
    total (contextTransport C u) = 0 := by sorry

theorem spatial_total_rate_from_original_source (G : Geometry) (s d : State)
    (t : ℝ) (ok : rhs G t s = some d) :
    ∃ rs, readRecords s = some rs ∧
      total (fun x => d.g x 3) = s.A * total (sourceKernel G t s rs) := by sorry

theorem unit_kernel_rate (G : Geometry) (s d : State) (t : ℝ) (ok : rhs G t s = some d)
    (unit : ∀ rs, readRecords s = some rs → total (sourceKernel G t s rs) = 1) :
    total (fun x => d.g x 3) = s.A := by sorry

theorem positive_attachments_normalize_original_kernel (G : Geometry) (s : State)
    (t : ℝ) (rs : List (Fin 4 × Record)) (pos : ∀ i p, 0 < G.attach i p) :
    total (sourceKernel G t s rs) = 1 := by sorry

theorem positive_attachments_see_a_marked_cell (G : Geometry) (s : State)
    (i : Actor) (L : Footprint) (x : Grid) (marked : L x = true)
    (pos : ∀ p, 0 < G.attach i p) : 0 < PaintCalibration.sensitivity G s i L := by sorry

theorem original_readout_affine (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h : ℝ) :
    lineRead G s i (profile B L h) = lineRead G s i B + h * PaintCalibration.sensitivity G s i L := by sorry

theorem bounded_channel_for_profile (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h : ℝ) :
    sensor G s i (profile B L h) =
      tanh ((lineRead G s i B + h * PaintCalibration.sensitivity G s i L) / 0.08) := by sorry

theorem zero_sensitivity_erases_contrast (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h k : ℝ) (blind : PaintCalibration.sensitivity G s i L = 0) :
    sensor G s i (profile B L h) = sensor G s i (profile B L k) := by sorry

theorem calibrated_sensor_recovers_signed_contrast (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h o : ℝ) (sees : PaintCalibration.sensitivity G s i L ≠ 0)
    (reading : sensor G s i (profile B L h) = o) :
    (0.04 * Real.log ((1+o)/(1-o)) - lineRead G s i B) / PaintCalibration.sensitivity G s i L = h := by sorry

theorem one_exact_reading_identifies_height (G : Geometry) (s : State) (i : Actor)
    (B : Scalar) (L : Footprint) (h k : ℝ) (sees : PaintCalibration.sensitivity G s i L ≠ 0)
    (same : sensor G s i (profile B L h) = sensor G s i (profile B L k)) :
    h = k := by sorry

theorem opposite_fields_have_same_original_force (s : State) (f : Scalar) :
    forcing (withLineSignal s (fun x => -f x)) = forcing (withLineSignal s f) := by sorry

end
end HugV3.Source.PaintCalibrationVerified
