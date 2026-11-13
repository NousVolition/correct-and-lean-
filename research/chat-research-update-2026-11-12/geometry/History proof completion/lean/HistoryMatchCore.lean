import SIMSLatentReadout

/-!
Checked components of the history-matching argument.

Scope: finite-dimensional identities, an exact periodic-distance bound,
irrational nonreturn given the integer-turn law, and the observation theorem
given the two histories. This file does not formalize the parabolic existence,
parameter-continuity, implicit-function or fluid-witness construction in
Proof.md. In particular the final theorem is a conditional corollary, not an
unconditional Lean construction of two Navier--Stokes solutions.
-/
namespace HistoryMatchCore

theorem quarter_turn_kills_first_jet (v gx gy : ℝ)
    (hv : v = -v) (hx : gy = -gx) (hy : gx = gy) :
    v = 0 ∧ gx = 0 ∧ gy = 0 := by
  constructor
  · linarith
  constructor <;> linarith

theorem perturbation_keeps_first_jet (s sx sy f fx fy g gx gy b e : ℝ)
    (hf : f = 0) (hfx : fx = 0) (hfy : fy = 0)
    (hg : g = 0) (hgx : gx = 0) (hgy : gy = 0) :
    s + b * (f + e*g) = s ∧
    sx + b * (fx + e*gx) = sx ∧
    sy + b * (fy + e*gy) = sy := by
  simp [hf,hfx,hfy,hg,hgx,hgy]

theorem strip_image_square_bound (z : ℝ) (hz : -(1/8 : ℝ) ≤ z ∧ z ≤ 0)
    (n : ℤ) : (1/4 : ℝ)^2 ≤ (z - 1/4 - (n : ℝ))^2 := by
  by_cases h : 0 ≤ n
  · have hn : (0 : ℝ) ≤ n := by exact_mod_cast h
    have hd : z - 1/4 - (n : ℝ) ≤ -(1/4 : ℝ) := by linarith
    nlinarith [sq_nonneg (z - (n : ℝ))]
  · have hn : n ≤ -1 := by omega
    have hn' : (n : ℝ) ≤ -1 := by exact_mod_cast hn
    have hd : (1/4 : ℝ) ≤ z - 1/4 - (n : ℝ) := by linarith
    nlinarith [sq_nonneg (z - 1/2 - (n : ℝ))]

theorem global_closest_bound (x y z : ℝ)
    (hz : -(1/8 : ℝ) ≤ z ∧ z ≤ 0) (nx ny nz : ℤ) :
    (1/4 : ℝ)^2 ≤ (x-(nx : ℝ))^2 + (y-(ny : ℝ))^2 +
      (z-1/4-(nz : ℝ))^2 := by
  have h := strip_image_square_bound z hz nz
  nlinarith [sq_nonneg (x-(nx : ℝ)), sq_nonneg (y-(ny : ℝ))]

theorem drift_numerator_identity (s c d b : ℝ)
    (hcircle : s^2+c^2=1) (hlevel : s+b*c=b*d) :
    (2*c+b*s)*(c-b*s)+b*d*s = 2-(1+b^2)*s^2 := by
  calc
    (2*c+b*s)*(c-b*s)+b*d*s = 2*c^2+(1-b^2)*s^2 := by
      linear_combination -s * hlevel
    _ = 2-(1+b^2)*s^2 := by nlinarith [hcircle]

theorem drift_numerator_positive (s c : ℝ) (hcircle : s^2+c^2=1) :
    0 < 2-(1+(1/8 : ℝ)^2)*s^2 := by
  have hs : s^2 ≤ 1 := by nlinarith [sq_nonneg c]
  nlinarith

theorem drift_derivative_formula (s c d v b k : ℝ)
    (hcircle : s^2+c^2=1) (hlevel : s+b*c=b*d)
    (hb : b ≠ 0) (hk : k ≠ 0) (hL : c-b*s ≠ 0) :
    ((v*(c*(c-d)-s^2))*(-b*s*v/(c-b*s))*(c-b*s) -
      (s*v*(c-d))*(b*v*c+(-s-b*c)*(-b*s*v/(c-b*s)))) /
      (k*(c-b*s)^2) =
    s^2*v^2*(2-(1+b^2)*s^2)/(k*(c-b*s)^3) := by
  have hcd : c-d = -s/b := (eq_div_iff hb).2 (by nlinarith [hlevel])
  have hcoeff : -s-b*c = -b*d := by linarith
  generalize hLdef : c-b*s = L at hL ⊢
  calc
    _ = s^2*v^2*((2*c+b*s)*L+b*d*s)/(k*L^3) := by
      rw [hcd,hcoeff]
      field_simp [hb, hk, hL]
      <;> ring
    _ = _ := by rw [← hLdef,drift_numerator_identity s c d b hcircle hlevel]

theorem irrational_turn_law_prevents_return (d : ℝ) (hd : Irrational d)
    (Z : ℝ → ℝ) (turns : ∀ n : ℤ, Z (n : ℝ) = (n : ℝ)*d) :
    ¬ ∃ r : ℝ, 0 < r ∧ ∃ n m : ℤ, r = (n : ℝ) ∧ Z r = (m : ℝ) := by
  rintro ⟨r,hr,n,m,hy,hz⟩
  have hn : (n : ℝ) ≠ 0 := by linarith
  rw [hy,turns] at hz
  have heq : d = (m : ℝ)/(n : ℝ) := (eq_div_iff hn).2 (by nlinarith [hz])
  exact hd.ne_rational m n heq

abbrev Point := Fin 3 → ℝ
abbrev Times (tag stop : ℝ) := {t : ℝ // tag ≤ t ∧ t ≤ stop}

def fullObservation {S O : Type} (tag stop : ℝ)
    (path swirl : S → ℝ → Point) (closest : S → O) (s : S) :
    (Times tag stop → Point) × (Times tag stop → Point) × O :=
  ((fun t => path s t.val), (fun t => swirl s t.val), closest s)

theorem observation_matches_on_whole_interval {S O : Type} (tag stop : ℝ)
    (path swirl : S → ℝ → Point) (closest : S → O) (a b : S)
    (hp : ∀ t, tag ≤ t → t ≤ stop → path a t = path b t)
    (hw : ∀ t, tag ≤ t → t ≤ stop → swirl a t = swirl b t)
    (hc : closest a = closest b) :
    fullObservation tag stop path swirl closest a =
      fullObservation tag stop path swirl closest b := by
  have hp' : (fun t : Times tag stop => path a t.val) =
      (fun t : Times tag stop => path b t.val) := by
    funext t
    exact hp t.val t.property.1 t.property.2
  have hw' : (fun t : Times tag stop => swirl a t.val) =
      (fun t : Times tag stop => swirl b t.val) := by
    funext t
    exact hw t.val t.property.1 t.property.2
  simp only [fullObservation,hp',hw',hc]

theorem no_exact_reader_with_history {S O : Type} (tag stop : ℝ)
    (path swirl : S → ℝ → Point) (closest : S → O) (closes : S → Bool) (a b : S)
    (hp : ∀ t, tag ≤ t → t ≤ stop → path a t = path b t)
    (hw : ∀ t, tag ≤ t → t ≤ stop → swirl a t = swirl b t)
    (hc : closest a = closest b) (hd : closes a ≠ closes b) :
    ¬ ∃ reader : ((Times tag stop → Point) × (Times tag stop → Point) × O) → Bool,
      ∀ s : S,
      reader (fullObservation tag stop path swirl closest s) = closes s := by
  exact SIMSLatentReadout.no_exact_reader_of_ambiguous_observation
    (fullObservation tag stop path swirl closest) closes a b
    (observation_matches_on_whole_interval tag stop path swirl closest a b hp hw hc) hd

#print axioms quarter_turn_kills_first_jet
#print axioms perturbation_keeps_first_jet
#print axioms strip_image_square_bound
#print axioms global_closest_bound
#print axioms drift_numerator_identity
#print axioms drift_numerator_positive
#print axioms drift_derivative_formula
#print axioms irrational_turn_law_prevents_return
#print axioms observation_matches_on_whole_interval
#print axioms no_exact_reader_with_history

end HistoryMatchCore
