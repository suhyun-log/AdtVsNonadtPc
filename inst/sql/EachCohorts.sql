  IF OBJECT_ID('TARGET', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.TARGET;
  CREATE TABLE @target_database_schema.TARGET as (
SELECT *, cohort_start_date as index_date FROM @target_database_schema.AdtVsNonadt  WHERE cohort_definition_id = 1
  );


  IF OBJECT_ID('COMPARATOR', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.COMPARATOR;
  CREATE TABLE @target_database_schema.COMPARATOR as (
SELECT *, DATEADD(day, @medianDate, cohort_start_date) as index_date FROM @target_database_schema.AdtVsNonadt  WHERE cohort_definition_id = 2
  );

  IF OBJECT_ID('OUTCOME_dementia', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.OUTCOME_dementia;
  CREATE TABLE @target_database_schema.OUTCOME_dementia as (
SELECT * FROM @target_database_schema.AdtVsNonadt WHERE cohort_definition_id = 3
  );


  IF OBJECT_ID('outcome_dementia_AD', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.outcome_dementia_AD;
  CREATE TABLE @target_database_schema.outcome_dementia_AD as (
SELECT * FROM @target_database_schema.AdtVsNonadt WHERE cohort_definition_id = 4
  );

  IF OBJECT_ID('outcome_dementia_VD', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.outcome_dementia_VD;
  CREATE TABLE @target_database_schema.outcome_dementia_VD as (
SELECT * FROM @target_database_schema.AdtVsNonadt WHERE cohort_definition_id = 5
  );

  IF OBJECT_ID('outcome_dementia_other', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.outcome_dementia_other;
  CREATE TABLE @target_database_schema.outcome_dementia_other as (
SELECT * FROM @target_database_schema.AdtVsNonadt WHERE cohort_definition_id = 6
  );


  IF OBJECT_ID('OUTCOME_parkinson', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.OUTCOME_parkinson;
  CREATE TABLE @target_database_schema.OUTCOME_parkinson as (
SELECT * FROM @target_database_schema.AdtVsNonadt WHERE cohort_definition_id = 7
  );


  IF OBJECT_ID('COHORT_id', 'U') IS NOT NULL
  	DROP TABLE @target_database_schema.COHORT_id;
  	CREATE TABLE @target_database_schema.COHORT_id as (
		SELECT subject_id AS person_id, index_date, target
		FROM @target_database_schema.TARGET 
		UNION ALL
		SELECT subject_id AS person_id, index_date, target
		FROM @target_database_schema.COMPARATOR
  );