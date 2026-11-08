import AppleExistenceDefinitions

namespace HugV3.Source.AppleExistence
noncomputable section
open Set Metric

theorem full_coordinate_round_trip (s : State) (x : Coordinates) : unpack (pack s)=s ∧ pack (unpack x)=x := by
  refine ⟨rfl,?_⟩
  funext i
  cases i <;> rfl

theorem packed_derivative_iff (x : ℝ → State) (d : State) (I : Set ℝ) (t : ℝ) :
    HasDerivWithinAt (fun s => pack (x s)) (pack d) I t ↔ StateHasDerivWithinAt x d I t := by
  rw [hasDerivWithinAt_pi]
  constructor
  · intro h
    exact ⟨fun x j => h (.grid x j),
      fun p i => h (.position p i),
      fun p i j => h (.fabric p i j),
      fun p k a => h (.directional p k a),
      fun l => h (.cell l),
      h .accumulator,
      fun k => h (.ledger k),
      h .writing,
      fun i k => h (.expression i k),
      fun i k => h (.context i k),
      fun i k => h (.center i k),
      fun i j => h (.radius i j),
      fun i j k => h (.relation i j k),
      fun i j k => h (.responses i j k),
      fun i j k => h (.association i j k)⟩
  · rintro ⟨hgrid,hposition,hfabric,hdirectional,hcell,haccumulator,hledger,hwriting,hexpression,hcontext,hcenter,hradius,hrelation,hresponses,hassociation⟩ i
    cases i with
    | grid x j => exact hgrid x j
    | position p i => exact hposition p i
    | fabric p i j => exact hfabric p i j
    | directional p k a => exact hdirectional p k a
    | cell l => exact hcell l
    | accumulator  => exact haccumulator
    | ledger k => exact hledger k
    | writing  => exact hwriting
    | expression i k => exact hexpression i k
    | context i k => exact hcontext i k
    | center i k => exact hcenter i k
    | radius i j => exact hradius i j
    | relation i j k => exact hrelation i j k
    | responses i j k => exact hresponses i j k
    | association i j k => exact hassociation i j k

theorem continuous_native_of_packed {x : ℝ → Coordinates} {I : Set ℝ} (h : ContinuousOn x I) :
    ContinuousStateOn (fun t => unpack (x t)) I := by
  have comp (i : Coordinate) := (continuous_apply i).comp_continuousOn h
  exact ⟨fun x j => comp (.grid x j),
    fun p i => comp (.position p i),
    fun p i j => comp (.fabric p i j),
    fun p k a => comp (.directional p k a),
    fun l => comp (.cell l),
    comp .accumulator,
    fun k => comp (.ledger k),
    comp .writing,
    fun i k => comp (.expression i k),
    fun i k => comp (.context i k),
    fun i k => comp (.center i k),
    fun i j => comp (.radius i j),
    fun i j k => comp (.relation i j k),
    fun i j k => comp (.responses i j k),
    fun i j k => comp (.association i j k)⟩

theorem rate_of_success {t : ℝ} {x : Coordinates} {d : State}
    (h : rhs sourceGeometry t (unpack x)=some d) : fullRate t x=pack d := by
  simp only [fullRate,h,Option.map_some,Option.getD_some]

end
end HugV3.Source.AppleExistence

