import HRDefinitions

namespace HugV3.Source.HearthReadout
noncomputable section
inductive Resolution | main | timeHalf
inductive Side | start | finish
inductive Reading | signedHeat | kineticWork | unsignedHeat
structure Stored where
  heat : ℝ
  response : ℝ
  work : ℝ
  unsigned : ℝ

def readStored (r : Reading) (s : Stored) : ℝ := match r with
  | .signedHeat => s.response
  | .kineticWork => s.work
  | .unsignedHeat => s.unsigned

/-- Exact values of the stored binary64 numbers at t=0.8+ and t=1.2-. -/
def stored : Resolution → Side → Stored
  | .main, .start => ⟨(54045276019953 : ℝ)/288230376151711744, (1091449845067951 : ℝ)/590295810358705651712, (365676439758935 : ℝ)/2361183241434822606848, (201253617051273 : ℝ)/9223372036854775808⟩
  | .main, .finish => ⟨(4359930283548761 : ℝ)/9223372036854775808, (50562328537299 : ℝ)/36893488147419103232, (55971475873029 : ℝ)/147573952589676412928, (420351990116807 : ℝ)/4611686018427387904⟩
  | .timeHalf, .start => ⟨(3458740760742655 : ℝ)/18446744073709551616, (1091401281448145 : ℝ)/590295810358705651712, (731272407328653 : ℝ)/4722366482869645213696, (1609885914813305 : ℝ)/73786976294838206464⟩
  | .timeHalf, .finish => ⟨(2179978456125287 : ℝ)/4611686018427387904, (101227986534753 : ℝ)/73786976294838206464, (447844017666087 : ℝ)/1180591620717411303424, (6725876896663915 : ℝ)/73786976294838206464⟩

end
end HugV3.Source.HearthReadout
