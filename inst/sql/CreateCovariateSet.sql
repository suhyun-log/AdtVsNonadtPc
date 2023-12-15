 IF OBJECT_ID('cohort_pd', 'U') IS NOT NULL
 DROP TABLE @target_database_schema.cohort_pd;
 CREATE TABLE @target_database_schema.cohort_pd as(
		select a.person_id, b.pd_statin, c.pd_antiplatelet, d.pd_anticoagulant, e.pd_anticholinergic, f.pd_antidepressant, g.pd_antipsychotics, h.urin_anticholinergic, i.urin_antidepressant
		from @target_database_schema.COHORT a
		left join @target_database_schema.cohort_statin b
		on a.person_id = b.person_id
		left join @target_database_schema.cohort_antiplatelet c
		on a.person_id = c.person_id
		left join @target_database_schema.cohort_anticoagulant d
		on a.person_id = d.person_id
		left join @target_database_schema.cohort_anticholinergic e
		on a.person_id = e.person_id
		left join @target_database_schema.cohort_antidepressant f
		on a.person_id = f.person_id
		left join @target_database_schema.cohort_antipsychotics g
		on a.person_id = g.person_id
		left join @target_database_schema.cohort_urin_anticholinergic h
		on a.person_id = h.person_id
		left join @target_database_schema.cohort_urin_antidepressant i
		on a.person_id = i.person_id;


 IF OBJECT_ID('ADT_PC_PRE_COHORT', 'U') IS NOT NULL
 DROP TABLE @target_database_schema.ADT_PC_PRE_COHORT
 CREATE TABLE @target_database_schema.ADT_PC_PRE_COHORT AS(
	SELECT a.*, b.person_age, b.age_group, c.mh_hypertension, d.mh_diabetes, e.mh_dyslipidemia, f.mh_cardiovascular_disease, g.mh_peripheral_vascular_disease, h.mh_copd,
			i.mh_asthma, j.mh_liver_disease,
			k.cci_cerebrovascular_disease, k.cci_liver_disease_mild, k.cci_liver_disease_moderate_to_severe, k.cci_chronic_kidney_disease,
		    k.cci_congestive_heart_failure, k.cci_connective_tissue_disease, k.cci_peptic_ulcer_disease, k.cci_hemiplegia, k.cci_sum,
			CASE WHEN k.cci_sum >= 2 AND k.cci_sum <= 3 THEN 1
				 WHEN k.cci_sum >= 4 AND k.cci_sum <= 5 THEN 2
				 WHEN k.cci_sum >= 6 THEN 3
				 ELSE NULL END AS cci_group,
			l.pd_statin, l.pd_antiplatelet, l.pd_anticoagulant, l.pd_anticholinergic, l.pd_antidepressant, l.pd_antipsychotics,
			m.urine_anticholinergic, n.urine_antidepressant,
			o.mt_cancer
	FROM @target_database_schema.COHORT a
	LEFT JOIN @target_database_schema.COHORT_age b
	ON a.person_id = b.person_id
	LEFT JOIN @target_database_schema.COHORT_hypertension c
	ON a.person_id = c.person_id
	LEFT JOIN @target_database_schema.COHORT_diabetes d
	ON a.person_id = d.person_id
	LEFT JOIN @target_database_schema.COHORT_dyslipidemia e
	ON a.person_id = e.person_id
	LEFT JOIN @target_database_schema.COHORT_cardiovascular_disease f
	ON a.person_id = f.person_id
	LEFT JOIN @target_database_schema.COHORT_peripheral_vascular_disease g
	ON a.person_id = g.person_id
	LEFT JOIN @target_database_schema.COHORT_COPD h
	ON a.person_id = h.person_id 
	LEFT JOIN @target_database_schema.COHORT_asthma i
	ON a.person_id = i.person_id 
	LEFT JOIN @target_database_schema.COHORT_liver_disease j
	ON a.person_id = j.person_id
	LEFT JOIN @target_database_schema.COHORT_pd l
	ON a.person_id = l.person_id
	LEFT JOIN @target_database_schema.COHORT_urine_anticholinergic m
	ON a.person_id = m.person_id
	LEFT JOIN @target_database_schema.COHORT_urine_antidepressant n
	ON a.person_id = n.person_id
	LEFT JOIN @target_database_schema.COHORT_mt_cancer o
	ON a.person_id = o.person_id
	);

CREATE TABLE @target_database_schema.ADT_PC_CCI_COHORT AS
SELECT PERSON_ID, A1 + A2 + A3 + A4 + A5 + A6 + A7 + A8 + A9 + A10 + A11 + A12 + A13 + A14 + A15 + A16 + A17 AS CCI
FROM @target_database_schema.ADT_PC_cci4 
 