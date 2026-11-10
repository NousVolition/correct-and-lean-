import FullModel

/- Pointwise transport identities for the two directional Hug–Navier guards. -/
namespace HugNavierSingle.GuardTransport
noncomputable section

def velocityAt (z : Fields) (r : Point) : Point := (z.ux r, z.uy r)

def sampleBlend (a : ℝ) (left right : Fields) (r : Point) : Point :=
  ((1 - a) * left.ux r + a * right.ux r,
   (1 - a) * left.uy r + a * right.uy r)

def transportAt (v : Point) (g : ScalarField) (r : Point) : ℝ :=
  v.1 * partialX g r + v.2 * partialY g r

def residual (v : Point) (z : Fields) (g : ScalarField) (r : Point) : ℝ :=
  (v.1 - z.ux r) * partialX g r + (v.2 - z.uy r) * partialY g r

/-- Both snapshots and the one test gradient are evaluated at the same point. -/
theorem transport_of_blend (a : ℝ) (left right : Fields) (g : ScalarField) (r : Point) :
    transportAt (sampleBlend a left right r) g r =
      (1 - a) * advection left g r + a * advection right g r := by
  unfold transportAt sampleBlend advection
  dsimp
  ring

/-- For a curve with velocity v, these are the material-rate expressions on
the two guard equations. Diffusion and each guard's own reaction are retained. -/
theorem directional_guard_rates (i : FieldInputs) (t : ℝ) (z : Fields)
    (p : ScalarField) (r v : Point) :
    (fieldRates i t z p).gAB r + transportAt v z.gAB r =
      (3/200) * laplacian z.gAB r + reactionAB z r + residual v z z.gAB r ∧
    (fieldRates i t z p).gBA r + transportAt v z.gBA r =
      (3/200) * laplacian z.gBA r + reactionBA z r + residual v z z.gBA r := by
  constructor <;>
    simp only [fieldRates, advection, transportAt, reactionAB, reactionBA, residual] <;> ring

/-- Split the two-history transport term used in the classical energy argument. -/
theorem advection_difference (z w : Fields) (f g : ScalarField) (r : Point) :
    advection z f r - advection w g r =
      z.ux r * (partialX f r - partialX g r) +
      z.uy r * (partialY f r - partialY g r) +
      residual (velocityAt z r) w g r := by
  unfold advection residual velocityAt
  dsimp
  ring

/-- Pointwise Young bound for the residual tested against a guard difference h.
A uniform gradient bound makes the right side a multiple of the difference energy. -/
theorem residual_energy_bound (v : Point) (z : Fields) (g : ScalarField)
    (r : Point) (h : ℝ) :
    |h * residual v z g r| ≤
      (((v.1 - z.ux r)^2 + (v.2 - z.uy r)^2) +
        h^2 * ((partialX g r)^2 + (partialY g r)^2)) / 2 := by
  let dx := v.1 - z.ux r
  let dy := v.2 - z.uy r
  let gx := partialX g r
  let gy := partialY g r
  change |h * (dx * gx + dy * gy)| ≤ ((dx^2 + dy^2) + h^2 * (gx^2 + gy^2)) / 2
  apply abs_le.mpr
  constructor
  · nlinarith only [sq_nonneg (dx + h * gx), sq_nonneg (dy + h * gy)]
  · nlinarith only [sq_nonneg (dx - h * gx), sq_nonneg (dy - h * gy)]

end
end HugNavierSingle.GuardTransport

#print axioms HugNavierSingle.GuardTransport.transport_of_blend
#print axioms HugNavierSingle.GuardTransport.directional_guard_rates
#print axioms HugNavierSingle.GuardTransport.advection_difference
#print axioms HugNavierSingle.GuardTransport.residual_energy_bound
