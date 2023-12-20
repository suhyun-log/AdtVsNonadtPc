 IF OBJECT_ID('AdtVsNonadtPc_COHORT_@CreateCohortTable', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.AdtVsNonadtPc_COHORT_@CreateCohortTable;
  CREATE TABLE @target_database_schema.AdtVsNonadtPc_COHORT_@CreateCohortTable as (
  	SELECT 	a.*, 
  			CASE WHEN b.cohort_start_date IS NOT NULL THEN 1 ELSE 0 END AS outcome_@CreateCohortTable, 
  			b.cohort_start_date AS outcome_@CreateCohortTable_date,
	   		DATEDIFF(DAY, a.index_date, b.cohort_start_date) AS outcome_@CreateCohortTable_time   
	FROM @target_database_schema.@AdtVsNonadtPc_COHORT_date a
	LEFT JOIN @target_database_schema.AdtVsNonadtPc b
	ON a.person_id = b.subject_id
	WHERE cohort_definition_id = @cohortId
	AND a.index_after_180days <= b.cohort_start_date
	AND b.cohort_start_date	<= DATEFROMPARTS(2022, 09, 30)
	);