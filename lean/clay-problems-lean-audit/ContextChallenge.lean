import ContextDefinitions
/- Frozen reference statements only; not imported by the proof module. -/
namespace ContextAudit.Verified
universe u v w z
variable {Person : Type u} {Surroundings : Type v} {City : Type w} {Result : Type z}

theorem city_only_iff_same_result
    (f : Person → Surroundings → City → Result)
    (p₀ : Person) (e₀ : Surroundings) :
    CityOnly f ↔ SameCityResult f := by
  sorry

theorem differing_people_prevent_city_only
    (f : Person → Surroundings → City → Result)
    (p q : Person) (e : Surroundings) (c : City)
    (different : f p e c ≠ f q e c) : ¬ CityOnly f := by
  sorry

theorem example_cannot_forget_person : ¬ CityOnly differentReports := by
  sorry

end ContextAudit.Verified
