import AppleExistenceDefinitions

namespace HugV3.Source.AppleExistence
noncomputable section
open Set Metric
open scoped NNReal

theorem initial_read_is_empty (G : Geometry) : readRecords (initial G)=some [] := by sorry

theorem source_power_floor (s : State) (p : Particle) : (1/100000:ℝ) ≤ powerDenominator sourceGeometry s p := by sorry

theorem initial_full_rate_defined (t : ℝ) :
    rhs sourceGeometry t initialFull.state = some (rhsFromRecords sourceGeometry t initialFull.state []) := by sorry

theorem full_coordinate_round_trip (s : State) (x : Coordinates) : unpack (pack s)=s ∧ pack (unpack x)=x := by sorry

theorem packed_derivative_iff (x : ℝ → State) (d : State) (I : Set ℝ) (t : ℝ) :
    HasDerivWithinAt (fun s => pack (x s)) (pack d) I t ↔ StateHasDerivWithinAt x d I t := by sorry

theorem tube_supplies_unique_full_segment {k : ℕ} (B : Tube k) (hB : Bounds B) (z : Coordinates)
    (hz : dist z (B.center (time k)) ≤ B.entryError) :
    ∃ x : ℝ → Coordinates, x (time k)=z ∧ PackedSegment k x ∧
      (∀ t ∈ Icc (time k) (time (k+1)), dist (x t) (B.center t) ≤ B.error t) ∧
      ∀ y : ℝ → Coordinates, y (time k)=z → PackedSegment k y →
        EqOn x y (Icc (time k) (time (k+1))) := by sorry

theorem material_carrier_unique_on_trace (tr : Trace) (h : Solves tr) (R : ℝ≥0) (φ ψ : Vec × ℝ → Vec)
    (f : AppleBand.MaterialFlowAcross tr R φ) (g : AppleBand.MaterialFlowAcross tr R ψ) :
    CarrierAgreement R φ ψ := by sorry

theorem full_apple_iff_source (R : ℝ≥0) (hR : 1≤R) : FullApple R ↔ FullExistenceUniqueness := by sorry

theorem certificate_gives_full_apple (cert : ScheduleCertificate) (R : ℝ≥0) (hR : 1≤R) : FullApple R := by sorry

theorem initial_ball_full_rate_defined (t : ℝ) (s : State)
    (near : dist (pack s) (pack initialFull.state) ≤ (1/100:ℝ)) :
    rhs sourceGeometry t s=some (rhsFromRecords sourceGeometry t s []) := by sorry

theorem rounding_seam_switches_fabric_bit (ε : ℝ) (hε : 0<ε) (small : ε<(1/10000:ℝ)) :
    quant (1/10000) (1/20000)=some 0 ∧ quant (1/10000) (1/20000+ε)=some 1 ∧
    bitsOfPayload (intBytes 1) 0-bitsOfPayload (intBytes 0) 0=(1/25:ℝ) := by sorry

theorem opposite_codes_preclude_one_domain_ball (c x y : Coordinates) (r : ℝ≥0) (l : Cell)
    (hx : x∈closedBall c (r:ℝ)) (hy : y∈closedBall c (r:ℝ))
    (negative : x (.cell l)<0) (positive : 0<y (.cell l)) :
    ∃ z∈closedBall c (r:ℝ), ∀ t, rhs sourceGeometry t (unpack z)=none := by sorry

theorem recorded_cell_precludes_one_domain_ball (c x y : Coordinates) (r : ℝ≥0)
    (hx : x∈closedBall c (r:ℝ)) (hy : y∈closedBall c (r:ℝ))
    (main : x (.cell 42320)=(-5756669002346905/288230376151711744:ℝ))
    (half : y (.cell 42320)=(5757349591092827/288230376151711744:ℝ)) :
    ∃ z∈closedBall c (r:ℝ), ∀ t, rhs sourceGeometry t (unpack z)=none := by sorry

end
end HugV3.Source.AppleExistence
