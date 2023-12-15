 IF OBJECT_ID('COHORT_interval_added', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.COHORT_interval_added;
  CREATE TABLE @target_database_schema.COHORT_interval_added as (
  	SELECT a.*, DATEADD(year, -1, index_date) AS index_before_1yr, 
	    	DATEADD(year, 1, index_date) AS index_after_1yr,
	    	DATEADD(day, 180, index_date) AS index_after_180days
	FROM @target_database_schema.COHORT_id a
  );


 IF OBJECT_ID('COHORT_dementia', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.COHORT_dementia;
  CREATE TABLE @target_database_schema.COHORT_dementia as (
  	SELECT 	a.*, 
  			CASE WHEN b.cohort_start_date IS NOT NULL THEN 1 ELSE 0 END AS outcome_dementia, 
  			b.cohort_start_date AS outcome_dementia_date,
	   		DATEDIFF(DAY, b.cohort_start_date, a.index_date) AS outcome_dementia_time   
	FROM @target_database_schema.COHORT_interval_added a
	LEFT JOIN @target_database_schema.OUTCOME_dementia b
	ON a.person_id = b.subject_id
	WHERE a.index_after_180days <= b.cohort_start_date
	AND b.cohort_start_date	<= DATEFROMPARTS(2022, 09, 30)
	);

 IF OBJECT_ID('COHORT_parkinson', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.COHORT_parkinson;
  CREATE TABLE @target_database_schema.COHORT_parkinson as (
  	SELECT 	a.*, 
		  	CASE WHEN b.cohort_start_date IS NOT NULL THEN 1 ELSE 0 END AS outcome_parkinson, 
		  	b.cohort_start_date AS outcome_parkinson_date,
	   		DATEDIFF(DAY, b.cohort_start_date, a.index_date) AS outcome_parkinson_time   

	FROM @target_database_schema.COHORT_dementia a
	LEFT JOIN @target_database_schema.OUTCOME_parkinson b
	ON a.person_id = b.subject_id
	WHERE a.index_after_180days <= b.cohort_start_date
	AND b.cohort_start_date	<= '2022-09-30'
);

 IF OBJECT_ID('COHORT', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.COHORT;
  CREATE TABLE @target_database_schema.COHORT as (
  	SELECT 	person_id, target, index_date, 
			outcome_dementia, 	outcome_dementia_date, 	outcome_dementia_time, 
			outcome_parkinson, 	outcome_parkinson_date, outcome_parkinson_time,
			outcome_death, 		outcome_death_date, 	outcome_death_time
	FROM @target_database_schema.COHORT_death
	);
  
 IF OBJECT_ID('COHORT', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.COHORT;
  CREATE TABLE @target_database_schema.COHORT as (
  	SELECT 	person_id, target, index_date, 
			outcome_dementia, 	outcome_dementia_date, 	outcome_dementia_time, 
			outcome_parkinson, 	outcome_parkinson_date, outcome_parkinson_time,
			outcome_death, 		outcome_death_date, 	outcome_death_time
	FROM @target_database_schema.COHORT_death
	);