import PersonEnvironmentProofs

open PersonEnvironment

/- Finite algorithm diagnostics, not simulated human encounters. -/
#eval memoryFirst (fun _ : Unit => singleBitCheck true) (fun _ => [[true]]) () 1
#eval memoryFirst (fun _ : Unit => singleBitCheck true) (fun _ => [[false]]) () 1
#eval memoryFirst singleBitCheck (fun _ => [[true]]) false 1
#eval scan (fun _ : Certificate => false) (certificates 3)

#print axioms PersonEnvironment.Verified.memory_first_finds_iff
#print axioms PersonEnvironment.Verified.rejecting_fallback_exact_count
#print axioms PersonEnvironment.Verified.full_hug_current_context_checked
