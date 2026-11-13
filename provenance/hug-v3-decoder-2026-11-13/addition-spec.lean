/- New reference statements, frozen before their implementations. -/

theorem decoded_records_fixed_of_read_margin (s : ℝ → State) (a b : ℝ)
    (hc : ∀ l, ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hm : ∀ t ∈ Icc a b, ∀ l, (1/200:ℝ) ≤ |(s t).b l|) :
    ∀ t ∈ Icc a b, readRecords (s t) = readRecords (s a) := by sorry

theorem decoded_records_preserved_of_clay_buffer (s : ℝ → State) (a b : ℝ)
    (records : List (Fin 4 × Record))
    (hc : ∀ l, ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hb : ∀ t ∈ Icc a b, ClayBuffer (s t))
    (hr : readRecords (s a) = some records) :
    ∀ t ∈ Icc a b, readRecords (s t) = some records := by sorry

theorem decoded_records_preserved_on_segment (s : ℝ → State) (a b : ℝ)
    (records : List (Fin 4 × Record))
    (hc : ∀ l, ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hd : ∀ l, ∀ t ∈ Ico a b, HasDerivWithinAt (fun τ => (s τ).b l)
      (fabricRate (fabricStrain (s t).F l) ((s t).b l)) (Ici t) t)
    (hF : ∀ l, ∀ t ∈ Ico a b,
      (∑ i, ((s t).F (point l) i (axis l))^2) ≤ (2:ℝ))
    (ha : ClayBuffer (s a))
    (hr : readRecords (s a) = some records) :
    ∀ t ∈ Icc a b, readRecords (s t) = some records := by sorry

theorem initial_read_records (G : Geometry) :
    readRecords (initial G) = some [] := by sorry

theorem initial_segment_read_records (G : Geometry) (s : ℝ → State) (a b : ℝ)
    (hc : ∀ l, ContinuousOn (fun t => (s t).b l) (Icc a b))
    (hd : ∀ l, ∀ t ∈ Ico a b, HasDerivWithinAt (fun τ => (s τ).b l)
      (fabricRate (fabricStrain (s t).F l) ((s t).b l)) (Ici t) t)
    (hF : ∀ l, ∀ t ∈ Ico a b,
      (∑ i, ((s t).F (point l) i (axis l))^2) ≤ (2:ℝ))
    (hinit : s a = initial G) :
    ∀ t ∈ Icc a b, readRecords (s t) = some [] := by sorry
