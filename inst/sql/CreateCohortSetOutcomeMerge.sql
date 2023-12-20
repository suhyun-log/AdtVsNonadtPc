 IF OBJECT_ID('AdtVsNonadtPc_COHORT_outcome', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.AdtVsNonadtPc_COHORT_outcome;
  CREATE TABLE @target_database_schema.AdtVsNonadtPc_COHORT_outcome as (
  	SELECT 	a.person_id, a.target, a.index_date, 
			b.outcome_dementia, 	  b.outcome_dementia_date, 	      b.outcome_dementia_time,
			c.outcome_dementia_AD, 	c.outcome_dementia_AD_date, 	c.outcome_dementia_AD_time, 
			d.outcome_dementia_VD, 	d.outcome_dementia_VD_date, 	d.outcome_dementia_VD_time, 
			e.outcome_dementia_other, 	e.outcome_dementia_other_date, 	e.outcome_dementia_other_time, 
			f.outcome_parkinson, 	f.outcome_parkinson_date, f.outcome_parkinson_time
	FROM @target_database_schema.AdtVsNonadtPc_COHORT_id a
	LEFT JOIN @target_database_schema.AdtVsNonadtPc_COHORT_dementia b
	ON a.person_id = b.person_id
		LEFT JOIN @target_database_schema.AdtVsNonadtPc_COHORT_dementia_AD c
	ON a.person_id = c.person_id
		LEFT JOIN @target_database_schema.AdtVsNonadtPc_COHORT_dementia_VD d
	ON a.person_id = d.person_id
		LEFT JOIN @target_database_schema.AdtVsNonadtPc_COHORT_dementia_other e
	ON a.person_id = e.person_id
		LEFT JOIN @target_database_schema.AdtVsNonadtPc_COHORT_parkinson f
	ON a.person_id = f.person_id
	);