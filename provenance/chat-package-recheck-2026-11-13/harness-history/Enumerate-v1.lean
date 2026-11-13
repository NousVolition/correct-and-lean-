import Lean
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

open Lean Elab Command
run_cmd do
  let env ← getEnv
  let modules : Array Name := #[`ASCounterexample, `CarryingGravity, `ConnectionAudit, `EnergyAccounting, `FullCarrying, `FullCarryingAudit, `FullModel, `GradientStorage, `GradientStorageAudit, `GravityAudit, `HistoryAudit, `HistoryRequirement, `HistoryRequirementAudit, `MaterialConfiguration, `OriginalAS, `OriginalASBalance, `OriginalASEnergy, `OriginalASIntegrated, `PairContext, `PairContextAudit, `ProofAudit, `RecordEnergyConnection, `StorageAudit, `StorageRequirements, `TotalEnergyAudit, `UnwrappedWork, `ViscousHeat]
  for (name, info) in env.constants.toList do
    if let .thmInfo _ := info then
      if let some idx := env.getModuleIdxFor? name then
        if modules.contains env.header.moduleNames[idx]! && !name.toString.startsWith "_" then
          logInfo m!"FRESH_THEOREM {name}"
