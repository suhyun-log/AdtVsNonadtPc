 IF OBJECT_ID('@target_database_schema.AdtVsNonadtPc_COHORT', 'U') IS NOT NULL
 DROP TABLE @target_database_schema.AdtVsNonadtPc_COHORT
 CREATE TABLE @target_database_schema.AdtVsNonadtPc_COHORT AS(
	SELECT a.*, 
	b.person_age, b.age_group, k.cci, CASE  WHEN k.cci >= 2 AND k.cci <= 3 THEN 1
                                          WHEN k.cci >= 4 AND k.cci <= 5 THEN 2
                                          WHEN k.cci >= 6 THEN 3
                                          ELSE NULL END AS cci_group,
	c.hypertension, d.diabetes, e.dyslipidemia, f.cardiovascular_disease, g.peripheral_vascular_disease, h.copd, i.asthma, j.liver_disease,
  n.statin, o.antiplatelet, p.anticoagulant, q.anticholinergic, r.antidepressant, s.antipsychotics, t.urine_anticholinergic, u.urine_antidepressant,
	m.metastatic_cancer
	FROM @target_database_schema.AdtVsNonadtPc_COHORT_outcome a
	LEFT JOIN @target_database_schema.AdtVsNonadtPc_AGE b
	ON a.person_id = b.person_id
	LEFT JOIN @target_database_schema.AdtVsNonadtPc_Medical_History_hypertension c
	ON a.person_id = c.person_id
	LEFT JOIN @target_database_schema.AdtVsNonadtPc_Medical_History_diabetes d
	ON a.person_id = d.person_id
	LEFT JOIN @target_database_schema.AdtVsNonadtPc_Medical_History_dyslipidemia e
	ON a.person_id = e.person_id
	LEFT JOIN @target_database_schema.AdtVsNonadtPc_Medical_History_cardiovascular_disease f
	ON a.person_id = f.person_id
	LEFT JOIN @target_database_schema.AdtVsNonadtPc_Medical_History_peripheral_vascular_disease g
	ON a.person_id = g.person_id
	LEFT JOIN @target_database_schema.AdtVsNonadtPc_Medical_History_COPD h
	ON a.person_id = h.person_id 
	LEFT JOIN @target_database_schema.AdtVsNonadtPc_Medical_History_asthma i
	ON a.person_id = i.person_id 
	LEFT JOIN @target_database_schema.AdtVsNonadtPc_Medical_History_liver_disease j
	ON a.person_id = j.person_id
	LEFT JOIN @target_database_schema.AdtVsNonadtPc_CCI k
	ON a.person_id = k.person_id
	LEFT JOIN @target_database_schema.AdtVsNonadtPc_Medical_History_metastatic_cancer m
	ON a.person_id = m.person_id
	left join @target_database_schema.AdtVsNonadtPc_Drug_History_statin n
		on a.person_id = n.person_id
		left join @target_database_schema.AdtVsNonadtPc_Drug_History_antiplatelet o
		on a.person_id = o.person_id
		left join @target_database_schema.AdtVsNonadtPc_Drug_History_anticoagulant p
		on a.person_id = p.person_id
		left join @target_database_schema.AdtVsNonadtPc_Drug_History_anticholinergic q
		on a.person_id = q.person_id
		left join @target_database_schema.AdtVsNonadtPc_Drug_History_antidepressant r
		on a.person_id = r.person_id
		left join @target_database_schema.AdtVsNonadtPc_Drug_History_antipsychotics s
		on a.person_id = s.person_id
		left join @target_database_schema.AdtVsNonadtPc_Drug_Use_urin_anticholinergic t
		on a.person_id = t.person_id
		left join @target_database_schema.AdtVsNonadtPc_Drug_Use_urin_antidepressant u
		on a.person_id = u.person_id
	);