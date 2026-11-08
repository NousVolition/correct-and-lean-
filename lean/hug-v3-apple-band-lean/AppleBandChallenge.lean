import AppleBandDefinitions

namespace HugV3.Source.AppleBand
noncomputable section

theorem reference_band_contracts : ContractsOn referenceSkin equator north := by sorry

theorem continuous_map_carries_contraction (f : Vec → Vec) (hf : Continuous f)
    {S : Set Vec} {loop : Band → Vec} {p : Vec} (h : ContractsOn S loop p) :
    ContractsOn (f '' S) (fun b => f (loop b)) (f p) := by sorry

theorem moving_skin_carries_contraction (f : Slide → Vec → Vec)
    (hf : Continuous (fun y : Slide × Vec => f y.1 y.2)) : MovingContraction f := by sorry

theorem homeomorphic_transport_iff (e : Vec ≃ₜ Vec) (S : Set Vec) (loop : Band → Vec) (p : Vec) :
    ContractsOn (e '' S) (fun b => e (loop b)) (e p) ↔ ContractsOn S loop p := by sorry

theorem accepted_position_and_fabric_rates (G : Geometry) (t : ℝ) (s d : State) (p : Particle)
    (ok : rhs G t s=some d) : d.X p=materialVelocity s (s.X p) ∧
    d.F p=mm (particleGradient s p) (s.F p) := by sorry

theorem accepted_step_moves_every_particle {G : Geometry} {t h : ℝ} {s d pr k e : State}
    (ok : ChildAccount.FullStep G t h s d pr k e) (p : Particle) :
    e.X p=stepMap ⟨s,pr,h⟩ (s.X p) := by sorry

theorem accepted_boundary_keeps_material (n : ℕ) (x y : FullState) (ok : boundary n x=some y) :
    y.state.X=x.state.X ∧ y.state.F=x.state.F := by sorry

theorem accepted_chain_carries_band {stages : List Stages} {s e : State}
    (ok : AcceptedChain stages s e) :
    (∀ p, e.X p=transport stages (s.X p)) ∧
    ContractsOn (transport stages '' referenceSkin) (fun b => transport stages (equator b))
      (transport stages north) := by sorry

theorem full_segment_local_band (tr : Trace) (solves : Solves tr) (k : ℕ) (hk : k<5) (p : Particle) :
    MovingContraction (segmentCarrier tr k p) := by sorry

theorem stretch_expands_tips_and_preserves_contraction (t : ℝ) (ht : 0<t) :
    let f := fabricMap 0 (FrameTransition.stretch t)
    (11/25:ℝ)<f (equator east) 0-f (equator west) 0 ∧
    ContractsOn (f '' referenceSkin) (fun b => f (equator b)) (f north) := by sorry

theorem small_step_preserves_distinct_points (a : Stages) (A B : ℝ)
    (hA : 0≤A) (hB : 0≤B)
    (first : ∀ x y, ‖materialVelocity a.present x-materialVelocity a.present y‖≤A*‖x-y‖)
    (second : ∀ x y, ‖materialVelocity a.predictor x-materialVelocity a.predictor y‖≤B*‖x-y‖)
    (small : |a.h| / 2*(A+B*(1+|a.h| * A))<1) : Function.Injective (stepMap a) := by sorry

end
end HugV3.Source.AppleBand
