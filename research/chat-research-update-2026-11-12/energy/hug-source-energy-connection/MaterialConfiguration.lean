import RecordEnergyConnection

/-! Link the saved material configuration to the directional energy term.
The source kinematics are F' = L F, d = F a, e = (|d|^2-1)/2.
No material stress or variable is inserted into the original A/S PDE.
-/
set_option autoImplicit false
noncomputable section
open scoped BigOperators
namespace HugSourceEnergy

abbrev Vec := Fin 3 → ℝ
abbrev Mat := Fin 3 → Fin 3 → ℝ

def materialDirection (F : Mat) (a : Vec) : Vec := fun i => ∑ j, F i j * a j
def directionalStrain (d : Vec) : ℝ := ((∑ i, (d i)^2)-1)/2
def directionalRate (d : Vec) (L : Mat) : ℝ := ∑ i, d i * ∑ j, L i j * d j

def directionalStressWork (G scale e m : ℝ) (d : Vec) (L : Mat) : ℝ :=
  ∑ i, ∑ j, (G * expression scale m * e * d i * d j) * L i j

theorem material_direction_derivative (F : ℝ → Mat) (a : Vec) (L : Mat) (t : ℝ)
    (hF : ∀ i j, HasDerivAt (fun s => F s i j) (∑ k, L i k * F t k j) t)
    (i : Fin 3) :
    HasDerivAt (fun s => materialDirection (F s) a i)
      (∑ j, L i j * materialDirection (F t) a j) t := by
  convert HasDerivAt.fun_sum (fun j _ => (hF i j).mul_const (a j)) using 1 <;> first
  | rfl
  | (simp [materialDirection, Fin.sum_univ_succ]; ring)

theorem directional_strain_derivative (d : ℝ → Vec) (L : Mat) (t : ℝ)
    (hd : ∀ i, HasDerivAt (fun s => d s i) (∑ j, L i j * d t j) t) :
    HasDerivAt (fun s => directionalStrain (d s)) (directionalRate (d t) L) t := by
  have h := ((HasDerivAt.fun_sum (u := Finset.univ) (fun i _ => (hd i).pow 2)).sub_const 1).div_const 2
  convert h using 1 <;> first
  | rfl
  | (simp [directionalRate, Fin.sum_univ_succ]; ring)

theorem symmetric_gradient_same_directional_rate (d : Vec) (L : Mat) :
    directionalRate d (fun i j => (L i j+L j i)/2) = directionalRate d L := by
  simp [directionalRate, Fin.sum_univ_succ]
  ring

theorem tensor_work_matches_strain_work (G scale e m : ℝ) (d : Vec) (L : Mat) :
    directionalStressWork G scale e m d L =
      recordStress G scale e m * directionalRate d L := by
  simp [directionalStressWork, recordStress, directionalRate, Fin.sum_univ_succ]
  ring

theorem configuration_record_energy_balance (G scale : ℝ)
    (F : ℝ → Mat) (a : Vec) (m : ℝ → ℝ) (L : Mat) (vm t : ℝ)
    (hs : scale ≠ 0)
    (hF : ∀ i j, HasDerivAt (fun s => F s i j) (∑ k, L i k * F t k j) t)
    (hm : HasDerivAt m vm t) :
    HasDerivAt
      (fun s => recordEnergy G scale (directionalStrain (materialDirection (F s) a)) (m s))
      (directionalStressWork G scale (directionalStrain (materialDirection (F t) a))
          (m t) (materialDirection (F t) a) L +
        writeConjugate G scale (directionalStrain (materialDirection (F t) a)) (m t)*vm) t := by
  rw [tensor_work_matches_strain_work]
  exact record_energy_balance G scale _ m _ vm t hs
    (directional_strain_derivative _ L t (material_direction_derivative F a L t hF)) hm

theorem zero_velocity_gradient_no_directional_strain_rate (d : Vec) :
    directionalRate d (fun _ _ => 0) = 0 := by
  simp [directionalRate]

end HugSourceEnergy
