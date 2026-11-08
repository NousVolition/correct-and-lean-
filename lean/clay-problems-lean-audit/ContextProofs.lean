import ContextDefinitions

namespace ContextAudit.Verified
universe u v w z
variable {Person : Type u} {Surroundings : Type v} {City : Type w} {Result : Type z}

theorem city_only_iff_same_result
    (f : Person → Surroundings → City → Result)
    (p₀ : Person) (e₀ : Surroundings) :
    CityOnly f ↔ SameCityResult f := by
  constructor
  · intro h p q e d c
    cases h with
    | intro cityView agreement =>
      exact (agreement p e c).trans (agreement q d c).symm
  · intro invariant
    exact ⟨f p₀ e₀, fun p e c => invariant p p₀ e e₀ c⟩

theorem differing_people_prevent_city_only
    (f : Person → Surroundings → City → Result)
    (p q : Person) (e : Surroundings) (c : City)
    (different : f p e c ≠ f q e c) : ¬ CityOnly f := by
  intro h
  cases h with
  | intro cityView agreement =>
    exact different ((agreement p e c).trans (agreement q e c).symm)

theorem example_cannot_forget_person : ¬ CityOnly differentReports := by
  exact differing_people_prevent_city_only differentReports true false () () (by decide)

end ContextAudit.Verified
