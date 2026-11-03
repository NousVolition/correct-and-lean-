import ASModel
import V3EventSpecification
import Mathlib.Tactic


   
                                                                                                             

                                                                                      
                                                                                        

                                                                             
                                                                                       
                                                                                   
                                                                                                          
                                                                                             
                                                                                          
                                                                                         
                                                              
                                                                                                                    
                                                                                              
                                                                  
                                                                                                            
                                                                                                    
                                                                                              
                                                                                                   
                                                          
                                                                                                     
                                                                                                      
                
  

namespace HugV3Event.InterEventVerified
noncomputable section
open HugV3Event

                                                                              

                                                                                               
                                                                                               
theorem two_load_probe_recovers_rest_strain (k e q b : ℝ) (hk : k ≠ 0) :
    (inferredRestStrain k (e - q) b + inferredRestStrain k (e + q) b) / 2 = b := by sorry

def StrictWellMargin (a margin b : ℝ) : Prop :=
  0 < a ∧ 0 < margin ∧ margin * a < |b|

                                                                                            
                                                                                              
                                                                      
theorem sign_constant_on_margin_ball {a margin b₀ b : ℝ}
    (h₀ : StrictWellMargin a margin b₀)
    (hball : |b - b₀| < |b₀| - margin * a) :
    StrictWellMargin a margin b ∧ (0 < b ↔ 0 < b₀) := by sorry

def fabricEnergy (k wellHeight a e b : ℝ) : ℝ :=
  (1 / 2) * k * (e - b) ^ 2 + (wellHeight / 4) * ((b / a) ^ 2 - 1) ^ 2

                                                                               
def fabricGradient (k wellHeight a e b : ℝ) : ℝ :=
  k * (b - e) + wellHeight * b / (a ^ 2) * ((b / a) ^ 2 - 1)

                                                                                       
                           
theorem fabric_heat_nonneg {mobility k wellHeight a e b : ℝ} (hmob : 0 ≤ mobility) :
    0 ≤ mobility * (fabricGradient k wellHeight a e b) ^ 2 := by sorry

theorem traction_eq_neg_elastic_gradient (k wellHeight a e b : ℝ) :
    traction k e b =
      wellHeight * b / (a ^ 2) * ((b / a) ^ 2 - 1) - fabricGradient k wellHeight a e b := by sorry

def powerLimiterDen (powerFloor eta available rawpower : ℝ) : ℝ :=
  powerFloor + eta * available + rawpower

def powerLimiter (powerFloor eta available rawpower : ℝ) : ℝ :=
  (eta * available) / powerLimiterDen powerFloor eta available rawpower

                                                                                     
                                                                                             
theorem power_limiter_den_ge_floor {powerFloor eta available rawpower : ℝ}
    (heta : 0 ≤ eta) (havail : 0 ≤ available) (hraw : 0 ≤ rawpower) :
    powerFloor ≤ powerLimiterDen powerFloor eta available rawpower := by sorry

theorem power_limiter_den_pos {powerFloor eta available rawpower : ℝ}
    (hfloor : 0 < powerFloor) (heta : 0 ≤ eta) (havail : 0 ≤ available) (hraw : 0 ≤ rawpower) :
    0 < powerLimiterDen powerFloor eta available rawpower := by sorry

theorem power_limiter_in_unit_interval {powerFloor eta available rawpower : ℝ}
    (hfloor : 0 < powerFloor) (heta : 0 ≤ eta) (havail : 0 ≤ available) (hraw : 0 ≤ rawpower) :
    0 ≤ powerLimiter powerFloor eta available rawpower ∧
    powerLimiter powerFloor eta available rawpower ≤ 1 := by sorry

theorem three_image_shifted_squares_even (f : ℝ → ℝ) (delta : ℝ) :
    f ((delta - 1) ^ 2) + f (delta ^ 2) + f ((delta + 1) ^ 2) =
    f (((-delta) - 1) ^ 2) + f ((-delta) ^ 2) + f (((-delta) + 1) ^ 2) := by sorry


end
end HugV3Event.InterEventVerified

   
                                                                                                          

                                                                                      
                                                                                 

                                                                                         
                                     
                                                                                       
                                                                                          
                                                                        
                                                                            
                                                                                 
                                                    
                                                             
                                                                                         
                                                                                     
                                                                      
                                                                              
                                                                                        
                                                                                                  
                                                                                         
                                                                                      
                                                                         
  

namespace SocialAS.Verified
noncomputable section
open MeasureTheory Set

                                                                 

theorem pos_nonneg (x : ℝ) : 0 ≤ pos x := by sorry

theorem self_le_pos (x : ℝ) : x ≤ pos x := by sorry

theorem pos_of_nonneg {x : ℝ} (hx : 0 ≤ x) : pos x = x := by sorry

theorem pos_of_nonpos {x : ℝ} (hx : x ≤ 0) : pos x = 0 := by sorry

theorem pos_eq_zero_of_nonpos {x : ℝ} (hx : x ≤ 0) : pos x = 0 := by sorry

theorem abs_pos_sub_pos_le (x y : ℝ) : |pos x - pos y| ≤ |x - y| := by sorry

theorem indicator_false : indicator false = 0 := by sorry

theorem indicator_true : indicator true = 1 := by sorry

theorem indicator_unit (b : Bool) : UnitInterval (indicator b) := by sorry

theorem saturation_nonneg {L scale : ℝ} (hL : 0 ≤ L) (hs : 0 < scale) :
    0 ≤ saturation L scale := by sorry

theorem one_sub_saturation {L scale : ℝ} (hne : L + scale ≠ 0) :
    1 - saturation L scale = scale / (L + scale) := by sorry

theorem saturation_le_one {L scale : ℝ} (hL : 0 ≤ L) (hs : 0 < scale) :
    saturation L scale ≤ 1 := by sorry

theorem saturation_unit {L scale : ℝ} (hL : 0 ≤ L) (hs : 0 < scale) :
    UnitInterval (saturation L scale) := by sorry

theorem effect_unit {gain L scale : ℝ} (hg : UnitInterval gain)
    (hL : 0 ≤ L) (hs : 0 < scale) :
    UnitInterval (effect gain L scale) := by sorry

theorem chiForward_unit {p : Parameters} {x : State}
    (hp : ParametersOK p) (hx : StateOK x) :
    UnitInterval (chiForward p x) := by sorry

theorem chiReverse_unit {p : Parameters} {x : State}
    (hp : ParametersOK p) (hx : StateOK x) :
    UnitInterval (chiReverse p x) := by sorry

theorem thetaForward_unit {p : Parameters} {x : State}
    (hp : ParametersOK p) (hx : StateOK x) :
    UnitInterval (thetaForward p x) := by sorry

theorem thetaReverse_unit {p : Parameters} {x : State}
    (hp : ParametersOK p) (hx : StateOK x) :
    UnitInterval (thetaReverse p x) := by sorry

theorem saturation_sub_identity {L₁ L₂ scale : ℝ}
    (h₁ : L₁ + scale ≠ 0) (h₂ : L₂ + scale ≠ 0) :
    saturation L₁ scale - saturation L₂ scale =
      scale * (L₁ - L₂) / ((L₁ + scale) * (L₂ + scale)) := by sorry

theorem saturation_lipschitz {L₁ L₂ scale : ℝ}
    (hL₁ : 0 ≤ L₁) (hL₂ : 0 ≤ L₂) (hs : 0 < scale) :
    |saturation L₁ scale - saturation L₂ scale| ≤ |L₁ - L₂| / scale := by sorry

theorem generalSDrift_zero (p : Parameters) (x : State) :
    generalSDrift p x 0 = smokeDrift p x := by sorry

theorem generalSDrift_one (p : Parameters) (x : State) :
    generalSDrift p x 1 = clayDrift p x := by sorry

theorem total_S_drift_balance (p : Parameters) (x : State)
    (hK : p.KSmoke + p.KClay = 1) :
    smokeDrift p x + clayDrift p x =
      exchange p.wSmokeClay (chiReverse p x) (x 2 - x 1) +
      exchange p.wClaySmoke (chiForward p x) (x 1 - x 2) +
      source p x - p.decay * (x 1 + x 2) := by sorry

theorem exchange_lipschitz_in_gap {w chi : ℝ} (hw : 0 ≤ w) (hchi : UnitInterval chi)
    (g₁ g₂ : ℝ) :
    |exchange w chi g₁ - exchange w chi g₂| ≤ w * |g₁ - g₂| := by sorry

theorem loadDrift_nonneg_at_zero {alpha exposure clear : ℝ} (h : Bool)
    (halpha : 0 ≤ alpha) (hexp : 0 ≤ exposure) :
    0 ≤ loadDrift alpha h exposure clear 0 := by sorry

theorem loadDrift_lipschitz_in_L (alpha : ℝ) (h : Bool) (exposure clear L₁ L₂ : ℝ) :
    loadDrift alpha h exposure clear L₁ - loadDrift alpha h exposure clear L₂ =
      -clear * (L₁ - L₂) := by sorry

theorem receivedMeaning_unit {theta z imposed : ℝ}
    (htheta : UnitInterval theta) (hz : UnitInterval z) (himp : UnitInterval imposed) :
    UnitInterval (receivedMeaning theta z imposed) := by sorry

theorem meaningRate_nonneg {w chi S scale : ℝ}
    (hw : 0 ≤ w) (hchi : UnitInterval chi) (hs : 0 < scale) :
    0 ≤ meaningRate w chi S scale := by sorry

theorem meaningDrift_nonneg_at_zero {rate received clarify reference : ℝ}
    (hrate : 0 ≤ rate) (hrec : UnitInterval received)
    (hclar : 0 ≤ clarify) (href : UnitInterval reference) :
    0 ≤ meaningDrift rate received 0 clarify reference := by sorry

theorem meaningDrift_nonpos_at_one {rate received clarify reference : ℝ}
    (hrate : 0 ≤ rate) (hrec : UnitInterval received)
    (hclar : 0 ≤ clarify) (href : UnitInterval reference) :
    meaningDrift rate received 1 clarify reference ≤ 0 := by sorry

theorem smokeMeaningDrift_nonneg_at_zero {p : Parameters} {i : Inputs} {x : State}
    (hp : ParametersOK p) (hi : InputsOK i) (hx : StateOK x) (hx5 : x 5 = 0) :
    0 ≤ smokeMeaningDrift p i x := by sorry

theorem smokeMeaningDrift_nonpos_at_one {p : Parameters} {i : Inputs} {x : State}
    (hp : ParametersOK p) (hi : InputsOK i) (hx : StateOK x) (hx5 : x 5 = 1) :
    smokeMeaningDrift p i x ≤ 0 := by sorry

theorem clayMeaningDrift_nonneg_at_zero {p : Parameters} {i : Inputs} {x : State}
    (hp : ParametersOK p) (hi : InputsOK i) (hx : StateOK x) (hx6 : x 6 = 0) :
    0 ≤ clayMeaningDrift p i x := by sorry

theorem clayMeaningDrift_nonpos_at_one {p : Parameters} {i : Inputs} {x : State}
    (hp : ParametersOK p) (hi : InputsOK i) (hx : StateOK x) (hx6 : x 6 = 1) :
    clayMeaningDrift p i x ≤ 0 := by sorry

theorem opening_unit {g p0 r rStar : ℝ}
    (hg : UnitInterval g) (hp0 : UnitInterval p0) (hr : 0 ≤ r) (hrStar : 0 < rStar) :
    UnitInterval (opening g p0 r rStar) := by sorry

theorem registration_unit {eta z challenge : ℝ}
    (heta : UnitInterval eta) (hz : UnitInterval z) (hch : UnitInterval challenge) :
    UnitInterval (registration eta z challenge) := by sorry

theorem conditionalRegistration_unit {eta z challenge : ℝ} (B : Bool)
    (heta : UnitInterval eta) (hz : UnitInterval z) (hch : UnitInterval challenge) :
    UnitInterval (conditionalRegistration eta z challenge B) := by sorry

theorem branches_nonneg {p q : ℝ} (hp : UnitInterval p) (hq : UnitInterval q) :
    ∀ k : Fin 3, 0 ≤ branches p q k := by sorry

theorem branches_sum_eq_one (p q : ℝ) :
    (∑ k : Fin 3, branches p q k) = 1 := by sorry

theorem update_false_eq_self (beta : ℝ) (H M : Meaning) :
    update beta false H M = H := by sorry

theorem update_preserves_simplex {beta : ℝ} (C : Bool) {H M : Meaning}
    (hbeta : UnitInterval beta) (hH : Simplex H) (hM : Simplex M) :
    Simplex (update beta C H M) := by sorry

theorem integralSolution_unique_A {p : Parameters} {i : ℝ → Inputs} {t0 T : ℝ}
    {initial : State} {x y : ℝ → State}
    (hx : IntegralSolution p i t0 T initial x)
    (hy : IntegralSolution p i t0 T initial y)
    {t : ℝ} (ht : t ∈ Icc t0 T) :
    x t 0 = y t 0 := by sorry

theorem integralSolution_sub_eq {p : Parameters} {i : ℝ → Inputs} {t0 T : ℝ}
    {initial : State} {x y : ℝ → State}
    (hx : IntegralSolution p i t0 T initial x)
    (hy : IntegralSolution p i t0 T initial y)
    (j : Fin 7) {t : ℝ} (ht : t ∈ Icc t0 T) :
    x t j - y t j =
      ∫ s in t0..t, (evolution p (i s) (x s) j - evolution p (i s) (y s) j) := by sorry

theorem integralSolution_coord_unique_of_drift_eq {p : Parameters} {i : ℝ → Inputs} {t0 T : ℝ}
    {initial : State} {x y : ℝ → State}
    (hx : IntegralSolution p i t0 T initial x)
    (hy : IntegralSolution p i t0 T initial y)
    (j : Fin 7)
    (hdrift : ∀ s, evolution p (i s) (x s) j = evolution p (i s) (y s) j)
    {t : ℝ} (ht : t ∈ Icc t0 T) :
    x t j = y t j := by sorry


end
end SocialAS.Verified

   
                                                                                                       

                                                                                   
                            

                                                                                           
                                                                                             
                                                                                        
                                                                                      
                                                                                                  
                                                                                          
                                                                                                
                                                                                  
                                                                                         

                                                     

                                                                                               
                                                                                           
                                             
                                                                                          
                                                                                            
                            
                                                                                       
                                                                                            
                                                                                          
                                                                                           
                   
                                                                                           
                                                                                           
                                                                                              
                                                                         
                                                                                       
                                                                                           
                                                                                                   
        
                                                                                             
                     
                                                                                    
                                       
                                                                                            
                                                                                         
                                                                                     
                                                               
  

namespace CombinedASHug
noncomputable section
open Filter Set MeasureTheory
open scoped Topology
open SocialAS HugV3Event

                                                              

                                
                                                                                             
                                                                               
                                                                                
structure CombinedState where
  asState : SocialAS.State
  meaningDist : SocialAS.Meaning
  fabricCoord : ℝ

                                                                                        
def CombinedState.toProd (s : CombinedState) :
    SocialAS.State × SocialAS.Meaning × ℝ :=
  (s.asState, s.meaningDist, s.fabricCoord)

instance : TopologicalSpace CombinedState :=
  TopologicalSpace.induced CombinedState.toProd inferInstance

theorem continuous_toProd : Continuous CombinedState.toProd := by sorry

theorem continuous_asState : Continuous CombinedState.asState := by sorry

theorem continuous_meaningDist : Continuous CombinedState.meaningDist := by sorry

theorem continuous_fabricCoord : Continuous CombinedState.fabricCoord := by sorry

def CombinedValid (a margin : ℝ) (s : CombinedState) : Prop :=
  SocialAS.StateOK s.asState ∧
  SocialAS.Simplex s.meaningDist ∧
  0 < a ∧ 0 < margin ∧ margin * a ≤ |s.fabricCoord|

                                                        
                                                                                        
                                                                        
                                                                                  
def applyEncounterEvent (beta : ℝ) (C : Bool) (M : SocialAS.Meaning)
    (a : ℝ) (bit : Bool) (s : CombinedState) : CombinedState where
  asState := s.asState
  meaningDist := SocialAS.update beta C s.meaningDist M
  fabricCoord := HugV3Event.writtenBit a bit

                                                                               

theorem combined_probe_recovers_rest_strain (k load b : ℝ) (hk : k ≠ 0) :
    inferredRestStrain k load b = b := by sorry

theorem combined_probe_recovers_written_bit (k load a : ℝ) (bit : Bool) (hk : k ≠ 0) :
    inferredRestStrain k load (writtenBit a bit) = writtenBit a bit := by sorry

theorem abs_writtenBit_eq {a : ℝ} (ha : 0 < a) (bit : Bool) :
    |writtenBit a bit| = a := by sorry

theorem written_bit_satisfies_well_margin {a margin : ℝ}
    (ha : 0 < a) (hmargin : margin ≤ 1) (bit : Bool) :
    margin * a ≤ |writtenBit a bit| := by sorry

theorem pos_nonneg (x : ℝ) : 0 ≤ pos x := by sorry

theorem indicator_unit (b : Bool) : UnitInterval (indicator b) := by sorry

theorem clay_opportunity_nonneg {p : Parameters} (hp : ParametersOK p) (x : SocialAS.State) :
    0 ≤ opportunityActivation p.g (activation (x 2) p.threshold) := by sorry

theorem clay_opening_unit {p : Parameters} (hp : ParametersOK p) (x : SocialAS.State) :
    UnitInterval (opening p.g p.p0
      (opportunityActivation p.g (activation (x 2) p.threshold)) p.rStar) := by sorry

theorem smoke_conditionalRegistration_unit {p : Parameters} {x : SocialAS.State}
    {challenge : ℝ} (B : Bool)
    (hp : ParametersOK p) (hx : StateOK x) (hch : UnitInterval challenge) :
    UnitInterval (conditionalRegistration p.eta (x 5) challenge B) := by sorry

theorem clay_encounter_branches_simplex {p : Parameters} {x : SocialAS.State}
    {challenge : ℝ} (B : Bool)
    (hp : ParametersOK p) (hx : StateOK x) (hch : UnitInterval challenge) :
    let p_open := opening p.g p.p0
      (opportunityActivation p.g (activation (x 2) p.threshold)) p.rStar
    let q_reg := conditionalRegistration p.eta (x 5) challenge B
    (∀ k : Fin 3, 0 ≤ branches p_open q_reg k) ∧
    (∑ k : Fin 3, branches p_open q_reg k) = 1 := by sorry

theorem update_preserves_simplex {beta : ℝ} (C : Bool) {H M : SocialAS.Meaning}
    (hbeta : UnitInterval beta) (hH : Simplex H) (hM : Simplex M) :
    Simplex (update beta C H M) := by sorry

theorem combined_event_preserves_valid_and_jumps
    {p : Parameters} {s : CombinedState} {M : SocialAS.Meaning}
    {a margin : ℝ} (C : Bool)
    (hp : ParametersOK p)
    (hstate : StateOK s.asState)
    (hH : Simplex s.meaningDist)
    (hM : Simplex M)
    (hempty : ValidEmptyCoordinate a margin s.fabricCoord)
    (hmargin_le : margin ≤ 1) :
    let s_post := applyEncounterEvent p.beta C M a true s
    CombinedValid a margin s_post ∧ s_post.fabricCoord ≠ s.fabricCoord := by sorry

theorem combined_trajectory_continuous_AS_but_discontinuous_full
    (p : Parameters) (i : ℝ → Inputs) (t0 T : ℝ) (initial : SocialAS.State)
    (path : ℝ → CombinedState)
    (hint : IntegralSolution p i t0 T initial (CombinedState.asState ∘ path))
    (eventTime before a : ℝ)
    (hwitness : EventWitness (CombinedState.fabricCoord ∘ path) eventTime before a) :
    ContinuousOn (CombinedState.asState ∘ path) (Icc t0 T) ∧
    ¬ ContinuousAt path eventTime := by sorry

theorem combined_hybrid_uniqueness_transfer
    {p : Parameters} {i : ℝ → Inputs} {t0 T : ℝ} {initial : SocialAS.State}
    {path₁ path₂ : ℝ → CombinedState}
    (h₁ : IntegralSolution p i t0 T initial (CombinedState.asState ∘ path₁))
    (h₂ : IntegralSolution p i t0 T initial (CombinedState.asState ∘ path₂))
    {eventTime : ℝ} (ht : eventTime ∈ Icc t0 T)
    (hpre_eq : path₁ eventTime = path₂ eventTime)
    (C : Bool) (M : SocialAS.Meaning) (a k load : ℝ) (bit : Bool) (hk : k ≠ 0) :
    (path₁ eventTime).asState 0 = (path₂ eventTime).asState 0 ∧
    applyEncounterEvent p.beta C M a bit (path₁ eventTime) =
      applyEncounterEvent p.beta C M a bit (path₂ eventTime) ∧
    inferredRestStrain k load
      (applyEncounterEvent p.beta C M a bit (path₁ eventTime)).fabricCoord =
      writtenBit a bit := by sorry


end
end CombinedASHug

   
                                                                               

                                                                                              
                                                                       

                                                                                 
                                                                                         
                                                               
                                                              
                                                                                           
                                                                                        
                                                                           
                               

                                            

                                                                    
                                                                                                  
                                                                                                
                                                                                             
                                                                                                
                                                                                         
                                                                                  
                                                                          
                                                                                        
                                                                                  
                                                                                                        
                                                                                        
                                                                                             
                                                                                                 
                                                 
                                                                       
                                                                                         
                                                                                              
                                                                                  
  

namespace DelayedReflexAS
noncomputable section
open Set MeasureTheory
open SocialAS HugV3Event

                                                                        

                                                                 
                                                                                 
                                                                                       
def effectiveStiffness (k0 kBrace brace : ℝ) : ℝ :=
  k0 + kBrace * brace

                                                                              
                                                
def impactTraction (k0 kBrace brace load b : ℝ) : ℝ :=
  effectiveStiffness k0 kBrace brace * (load - b)

                                                                           
                                                                                   
def fastPhysicalDrift (k0 kBrace damping : ℝ)
    (hazardAtPresent : ℝ) (braceFromPast : ℝ) (F_now b_now : ℝ) : ℝ :=
  -effectiveStiffness k0 kBrace braceFromPast * (F_now - b_now)
  - damping * F_now + hazardAtPresent

                                                                                             
                                                            
                                                                                          
def DelayedIntegralSolution (p : Parameters) (i : ℝ → Inputs) (t0 tau : ℝ)
    (history : ℝ → State) (trajectory : ℝ → State) : Prop :=
  0 < tau ∧
  ContinuousOn trajectory (Icc t0 (t0 + tau)) ∧
  (∀ s ∈ Icc (t0 - tau) t0, trajectory s = history s) ∧
  (∀ j t, t ∈ Icc t0 (t0 + tau) →
    IntervalIntegrable (fun s => evolution p (i s) (trajectory (s - tau)) j) volume t0 t) ∧
  (∀ j t, t ∈ Icc t0 (t0 + tau) →
    trajectory t j = history t0 j +
      ∫ s in t0..t, evolution p (i s) (trajectory (s - tau)) j)

                                                                     

                                                                                          
                                                        
theorem sub_tau_mem_history_window {t0 tau t s : ℝ}
    (ht : t ∈ Icc t0 (t0 + tau)) (hs : s ∈ uIcc t0 t) :
    s - tau ∈ Icc (t0 - tau) t0 := by sorry

theorem delayedSolution_unique_on_step
    {p : Parameters} {i : ℝ → Inputs} {t0 tau : ℝ}
    {history : ℝ → State} {x y : ℝ → State}
    (hx : DelayedIntegralSolution p i t0 tau history x)
    (hy : DelayedIntegralSolution p i t0 tau history y)
    (j : Fin 7) {t : ℝ} (ht : t ∈ Icc t0 (t0 + tau)) :
    x t j = y t j := by sorry

theorem reflex_acts_before_conscious_registration
    {t_haz tau_spinal tau_lag t : ℝ}
    (h_spinal_pos : 0 < tau_spinal)
    (h_faster : tau_spinal < tau_lag)
    (ht : t ∈ Ico (t_haz + tau_spinal) (t_haz + tau_lag)) :
    t_haz < t_haz + tau_spinal ∧
    t_haz + tau_spinal ≤ t ∧
    t - tau_lag < t_haz := by sorry

theorem faster_reflex_prevents_cut
    {v_hazard tau_new tau_old d_cut : ℝ}
    (hv : 0 < v_hazard)
    (h_speedup : tau_new < tau_old)
    (h_safe : v_hazard * tau_new < d_cut)
    (h_old_cut : d_cut ≤ v_hazard * tau_old) :
    v_hazard * tau_new < d_cut ∧ v_hazard * tau_new < v_hazard * tau_old := by sorry

theorem unbraced_peak_stress_lt_braced
    {k0 kBrace brace load b : ℝ}
    (hkBrace : 0 < kBrace) (hbrace : 0 < brace) (hstrain : b < load) :
    impactTraction k0 kBrace 0 load b < impactTraction k0 kBrace brace load b := by sorry

theorem unbraced_survives_crash_window
    {k0 kBrace brace load b stress_crit : ℝ}
    (h_unbraced : k0 * (load - b) < stress_crit)
    (h_braced : stress_crit ≤ (k0 + kBrace * brace) * (load - b)) :
    impactTraction k0 kBrace 0 load b < stress_crit ∧
    stress_crit ≤ impactTraction k0 kBrace brace load b := by sorry

theorem mirror_write_is_many_to_one {a margin : ℝ} (ha : 0 < a) (hm : 0 < margin) :
    let b₁ := -(margin * a)
    let b₂ := -(2 * margin * a)
    ValidEmptyCoordinate a margin b₁ ∧
    ValidEmptyCoordinate a margin b₂ ∧
    b₁ ≠ b₂ ∧
    writtenBit a true = a := by sorry


end
end DelayedReflexAS