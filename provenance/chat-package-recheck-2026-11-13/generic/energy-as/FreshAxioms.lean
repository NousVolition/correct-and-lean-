import ASCounterexample
import CarryingGravity
import ConnectionAudit
import EnergyAccounting
import FullCarrying
import FullCarryingAudit
import FullModel
import GradientStorage
import GradientStorageAudit
import GravityAudit
import HistoryAudit
import HistoryRequirement
import HistoryRequirementAudit
import MaterialConfiguration
import OriginalAS
import OriginalASBalance
import OriginalASEnergy
import OriginalASIntegrated
import PairContext
import PairContextAudit
import ProofAudit
import RecordEnergyConnection
import StorageAudit
import StorageRequirements
import TotalEnergyAudit
import UnwrappedWork
import ViscousHeat

#print axioms CarryingGravity.carriedHeight._proof_1
#print axioms CarryingGravity.carriedPosition.eq_1
#print axioms CarryingGravity.carried_height_cancels_original_work
#print axioms CarryingGravity.carried_height_derivative
#print axioms CarryingGravity.carried_potential_work
#print axioms CarryingGravity.exact_configuration_balance
#print axioms CarryingGravity.matched_potential_conserves
#print axioms CarryingGravity.no_periodic_potential_for_unit_force
#print axioms CarryingGravity.periodic_potential_constant_slope_zero
#print axioms CarryingGravity.position_follows_original_velocity
#print axioms CarryingGravity.receipt_and_reservoir_sign
#print axioms CarryingGravity.three_channel_account_constant
#print axioms CarryingGravity.three_channel_balance
#print axioms CarryingGravity.variable_strength_height_balance
#print axioms FullCarrying.carried_gradient_history
#print axioms FullCarrying.carried_gradient_rate
#print axioms FullCarrying.complete_existing_transfers
#print axioms FullCarrying.pullback.eq_1
#print axioms FullCarrying.pullback_rate_algebra
#print axioms FullCarrying.recover_spatial_gradient
#print axioms FullCarrying.recover_spatial_gradient._simp_1_2
#print axioms FullCarrying.recover_spatial_gradient._simp_1_3
#print axioms FullCarrying.required_transfer_split
#print axioms FullCarrying.required_transfer_split._simp_1_1
#print axioms GradientStorage.initial_minimum_cannot_pay
#print axioms GradientStorage.integrated_norm_budget
#print axioms GradientStorage.nonnegative_quadratic_cannot_pay
#print axioms GradientStorage.normStorage._proof_1
#print axioms GradientStorage.normStorage.eq_1
#print axioms GradientStorage.norm_storage_nonnegative
#print axioms GradientStorage.norm_storage_rate
#print axioms GradientStorage.norm_storage_transport_rate
#print axioms GradientStorage.norm_storage_zero
#print axioms HistoryRequirement.accumulated.eq_1
#print axioms HistoryRequirement.accumulated_rate
#print axioms HistoryRequirement.adding_increasing_potential_increases_debit
#print axioms HistoryRequirement.any_balancing_G_has_required_trace
#print axioms HugNavierSingle.FieldDifferentialAt._proof_1
#print axioms HugNavierSingle.FieldInputs.mk.inj
#print axioms HugNavierSingle.FieldInputs.mk.injEq
#print axioms HugNavierSingle.FieldInputs.mk.sizeOf_spec
#print axioms HugNavierSingle.Fields.mk.inj
#print axioms HugNavierSingle.Fields.mk.injEq
#print axioms HugNavierSingle.Fields.mk.sizeOf_spec
#print axioms HugNavierSingle.PulseRecipient.A.sizeOf_spec
#print axioms HugNavierSingle.PulseRecipient.B.sizeOf_spec
#print axioms HugNavierSingle.PulseRecipient.none.sizeOf_spec
#print axioms HugNavierSingle.fieldRates._proof_1
#print axioms HugNavierSingle.fieldRates._proof_2
#print axioms HugNavierSingle.fieldRates._proof_3
#print axioms HugNavierSingle.fieldRates._proof_4
#print axioms HugNavierSingle.fieldRates._proof_5
#print axioms HugNavierSingle.fieldRates._proof_6
#print axioms HugNavierSingle.sourceInitial._proof_1
#print axioms HugNavierSingle.sourceInitial._proof_2
#print axioms HugNavierSingle.stressXX._proof_1
#print axioms HugNavierSingle.viscosity._proof_1
#print axioms HugNavierSingle.viscosity._proof_2
#print axioms HugSourceEnergy.changing_records_can_change_response
#print axioms HugSourceEnergy.configuration_record_energy_balance
#print axioms HugSourceEnergy.directionalRate.eq_1
#print axioms HugSourceEnergy.directionalStrain._proof_1
#print axioms HugSourceEnergy.directionalStressWork.eq_1
#print axioms HugSourceEnergy.directional_strain_derivative
#print axioms HugSourceEnergy.expression_derivative
#print axioms HugSourceEnergy.fixed_strain_and_record_energy_rate_zero
#print axioms HugSourceEnergy.materialDirection.eq_1
#print axioms HugSourceEnergy.material_conservation_iff_zero_source_power
#print axioms HugSourceEnergy.material_direction_derivative
#print axioms HugSourceEnergy.material_total_residual
#print axioms HugSourceEnergy.no_viscous_power_no_writing
#print axioms HugSourceEnergy.recordEnergy._proof_1
#print axioms HugSourceEnergy.recordEnergy.eq_1
#print axioms HugSourceEnergy.recordStress.eq_1
#print axioms HugSourceEnergy.record_energy_balance
#print axioms HugSourceEnergy.record_energy_balance._simp_1_1
#print axioms HugSourceEnergy.record_energy_balance._simp_1_2
#print axioms HugSourceEnergy.record_energy_balance._simp_1_3
#print axioms HugSourceEnergy.record_energy_balance._simp_1_4
#print axioms HugSourceEnergy.record_energy_balance._simp_1_5
#print axioms HugSourceEnergy.record_energy_balance._simp_1_6
#print axioms HugSourceEnergy.record_energy_balance._simp_1_7
#print axioms HugSourceEnergy.recording_power_bound
#print axioms HugSourceEnergy.symmetric_gradient_same_directional_rate
#print axioms HugSourceEnergy.tensor_work_matches_strain_work
#print axioms HugSourceEnergy.unstrained_energy_zero
#print axioms HugSourceEnergy.unstrained_stress_zero
#print axioms HugSourceEnergy.unstrained_write_conjugate_zero
#print axioms HugSourceEnergy.writeConjugate.eq_1
#print axioms HugSourceEnergy.write_conjugate_nonnegative
#print axioms HugSourceEnergy.writingLimiter.eq_1
#print axioms HugSourceEnergy.zero_velocity_gradient_no_directional_strain_rate
#print axioms OriginalAS.Admissible.eq_1
#print axioms OriginalAS.Energy.Accounting.conservation_iff_exchange
#print axioms OriginalAS.Energy.Accounting.cumulative.eq_1
#print axioms OriginalAS.Energy.Accounting.cumulative_derivative
#print axioms OriginalAS.Energy.Accounting.exchangeLedger.eq_1
#print axioms OriginalAS.Energy.Accounting.exchange_ledger_derivative
#print axioms OriginalAS.Energy.Accounting.heat_alone_leaves_coupling
#print axioms OriginalAS.Energy.Accounting.heat_ledger_nonnegative
#print axioms OriginalAS.Energy.Accounting.history_account_constant
#print axioms OriginalAS.Energy.Accounting.history_account_derivative
#print axioms OriginalAS.Energy.Accounting.total_rate
#print axioms OriginalAS.Energy.Heat.bulk_heat_matches_kinetic_loss
#print axioms OriginalAS.Energy.Heat.source_heat_nonnegative
#print axioms OriginalAS.Energy.Heat.source_stress_decomposition
#print axioms OriginalAS.Energy.Heat.source_stress_decomposition._simp_1_1
#print axioms OriginalAS.Energy.Heat.source_stress_is_strain_heat
#print axioms OriginalAS.Energy.Heat.strainSquared._proof_1
#print axioms OriginalAS.Energy.Heat.strain_identity
#print axioms OriginalAS.Energy.Heat.strain_identity._simp_1_1
#print axioms OriginalAS.Energy.Witness.activation
#print axioms OriginalAS.Energy.Witness.any_AS_energy_constant
#print axioms OriginalAS.Energy.Witness.channelKinetic.eq_1
#print axioms OriginalAS.Energy.Witness.channel_energy_growth
#print axioms OriginalAS.Energy.Witness.channel_kinetic_value
#print axioms OriginalAS.Energy.Witness.coupling_power
#print axioms OriginalAS.Energy.Witness.exact_solution
#print axioms OriginalAS.Energy.Witness.incompressible
#print axioms OriginalAS.Energy.Witness.kinetic_flux_zero
#print axioms OriginalAS.Energy.Witness.kinetic_value
#print axioms OriginalAS.Energy.Witness.no_conserved_state_energy
#print axioms OriginalAS.Energy.Witness.no_wall_flow
#print axioms OriginalAS.Energy.Witness.original_force
#print axioms OriginalAS.Energy.Witness.original_rates
#print axioms OriginalAS.Energy.Witness.parameters_admissible
#print axioms OriginalAS.Energy.Witness.params.eq_1
#print axioms OriginalAS.Energy.Witness.scalar._proof_1
#print axioms OriginalAS.Energy.Witness.scalar.eq_1
#print axioms OriginalAS.Energy.Witness.scalar_advection
#print axioms OriginalAS.Energy.Witness.scalar_diffusive_flux_zero
#print axioms OriginalAS.Energy.Witness.scalar_laplacian
#print axioms OriginalAS.Energy.Witness.scalar_partial
#print axioms OriginalAS.Energy.Witness.source_stress_zero
#print axioms OriginalAS.Energy.Witness.state.eq_1
#print axioms OriginalAS.Energy.Witness.state_energy_cannot_cancel
#print axioms OriginalAS.Energy.Witness.stored_state_constant
#print axioms OriginalAS.Energy.Witness.velocity.eq_1
#print axioms OriginalAS.Energy.Witness.velocity_advection
#print axioms OriginalAS.Energy.Witness.velocity_laplacian
#print axioms OriginalAS.Energy.Witness.velocity_partial
#print axioms OriginalAS.Energy.Witness.viscous_loss_zero
#print axioms OriginalAS.Energy.diffusion_flux
#print axioms OriginalAS.Energy.diffusion_flux._simp_1_2
#print axioms OriginalAS.Energy.force_power
#print axioms OriginalAS.Energy.force_power._simp_1_3
#print axioms OriginalAS.Energy.force_power._simp_1_4
#print axioms OriginalAS.Energy.force_power._simp_1_5
#print axioms OriginalAS.Energy.force_power._simp_1_6
#print axioms OriginalAS.Energy.force_power._simp_1_7
#print axioms OriginalAS.Energy.force_power._simp_1_8
#print axioms OriginalAS.Energy.force_power._simp_1_9
#print axioms OriginalAS.Energy.gradSquared.eq_1
#print axioms OriginalAS.Energy.gradSquared_nonneg
#print axioms OriginalAS.Energy.halfSquare._proof_1
#print axioms OriginalAS.Energy.halfSquare.eq_1
#print axioms OriginalAS.Energy.halfSquare_advection
#print axioms OriginalAS.Energy.halfSquare_partial
#print axioms OriginalAS.Energy.halfSquare_regular
#print axioms OriginalAS.Energy.halfSquare_time_derivative
#print axioms OriginalAS.Energy.hugPower.eq_1
#print axioms OriginalAS.Energy.hugPower_nonpos
#print axioms OriginalAS.Energy.hugPower_pos
#print axioms OriginalAS.Energy.integrate_zero_flux_balance
#print axioms OriginalAS.Energy.kinetic.eq_1
#print axioms OriginalAS.Energy.kineticNetFlux.eq_1
#print axioms OriginalAS.Energy.kinetic_advection
#print axioms OriginalAS.Energy.kinetic_global_balance
#print axioms OriginalAS.Energy.kinetic_local_balance
#print axioms OriginalAS.Energy.kinetic_material_balance
#print axioms OriginalAS.Energy.kinetic_material_balance._simp_1_1
#print axioms OriginalAS.Energy.kinetic_material_balance._simp_1_2
#print axioms OriginalAS.Energy.kinetic_material_balance._simp_1_3
#print axioms OriginalAS.Energy.kinetic_material_balance._simp_1_4
#print axioms OriginalAS.Energy.kinetic_material_balance._simp_1_5
#print axioms OriginalAS.Energy.kinetic_material_balance._simp_1_6
#print axioms OriginalAS.Energy.kinetic_material_balance._simp_1_7
#print axioms OriginalAS.Energy.kinetic_material_balance._simp_1_8
#print axioms OriginalAS.Energy.kinetic_partial
#print axioms OriginalAS.Energy.kinetic_regular
#print axioms OriginalAS.Energy.kinetic_time_derivative
#print axioms OriginalAS.Energy.memory_at_baseline
#print axioms OriginalAS.Energy.memory_derivative
#print axioms OriginalAS.Energy.memory_square_balance
#print axioms OriginalAS.Energy.partial_mul
#print axioms OriginalAS.Energy.pressure_flux
#print axioms OriginalAS.Energy.pressure_flux._simp_1_2
#print axioms OriginalAS.Energy.scalarNetFlux.eq_1
#print axioms OriginalAS.Energy.scalar_local_balance
#print axioms OriginalAS.Energy.scalar_material_balance
#print axioms OriginalAS.Energy.sharp_power_off
#print axioms OriginalAS.Energy.sharp_power_positive
#print axioms OriginalAS.Energy.source_at_baseline
#print axioms OriginalAS.Energy.transport_flux
#print axioms OriginalAS.Energy.velocityGradSquared.eq_1
#print axioms OriginalAS.Energy.viscous_loss_nonneg
#print axioms OriginalAS.Fields.mk.inj
#print axioms OriginalAS.Fields.mk.injEq
#print axioms OriginalAS.Fields.mk.sizeOf_spec
#print axioms OriginalAS.FullDifferentialAt._proof_1
#print axioms OriginalAS.Parameters.mk.inj
#print axioms OriginalAS.Parameters.mk.injEq
#print axioms OriginalAS.Parameters.mk.sizeOf_spec
#print axioms OriginalAS.advect.eq_1
#print axioms OriginalAS.coordinatePartial.eq_1
#print axioms OriginalAS.divergence.eq_1
#print axioms OriginalAS.excess.eq_1
#print axioms OriginalAS.force.eq_1
#print axioms OriginalAS.gradMagnitude.eq_1
#print axioms OriginalAS.laplacian.eq_1
#print axioms OriginalAS.memory.eq_1
#print axioms OriginalAS.rates.eq_1
#print axioms OriginalAS.sharp.eq_1
#print axioms OriginalAS.sourceRate.eq_1
#print axioms OriginalAS.stress.eq_1
#print axioms OriginalAS.tanhResponse._proof_1
#print axioms PairContext.log_cosh_rate
#print axioms PairContext.moving_potential_rate
#print axioms PairContext.potential._proof_1
#print axioms PairContext.potential.eq_1
#print axioms PairContext.potential_nonnegative
#print axioms PairContext.potential_zero
#print axioms PairContext.zero_context_cannot_pay
#print axioms StorageRequirements.activation_height_residual
#print axioms StorageRequirements.force_match_determines_storage
#print axioms StorageRequirements.gradient_transport_contraction
#print axioms StorageRequirements.magnitude_rate
#print axioms StorageRequirements.magnitude_rate._simp_1_1
#print axioms StorageRequirements.magnitude_rate._simp_1_2
#print axioms StorageRequirements.magnitude_rate._simp_1_3
#print axioms StorageRequirements.magnitude_rate._simp_1_4
#print axioms StorageRequirements.magnitude_rate._simp_1_5
#print axioms StorageRequirements.magnitude_rate._simp_1_6
#print axioms StorageRequirements.magnitude_rate._simp_1_7
#print axioms StorageRequirements.no_storage_with_unpaid_independent_activation
#print axioms StorageRequirements.required_activation_conjugate
#print axioms UnwrappedWork.activationCorrection.eq_1
#print axioms UnwrappedWork.discrete_history_balance
#print axioms UnwrappedWork.history_energy_derivative
#print axioms UnwrappedWork.history_is_opposite_work_receipt
#print axioms UnwrappedWork.history_total_constant
#print axioms UnwrappedWork.one_step_work_split
#print axioms UnwrappedWork.pathWork._proof_1
#print axioms UnwrappedWork.pathWork.eq_1
#print axioms UnwrappedWork.returning_endpoints_leave_history
