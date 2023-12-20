IF OBJECT_ID('AdtVsNonadtPc_COHORT_id', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.AdtVsNonadtPc_COHORT_id;
  CREATE TABLE @target_database_schema.AdtVsNonadtPc_COHORT_id as (
    SELECT a.subject_id AS person_id, a.index_date, a.target
    FROM @target_database_schema.AdtVsNonadtPc_TARGET a
    UNION ALL
    SELECT b.subject_id AS person_id, b.index_date, b.target
    FROM @target_database_schema.AdtVsNonadtPc_COMPARATOR b
  );
IF OBJECT_ID('@AdtVsNonadtPc_COHORT_date', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.@AdtVsNonadtPc_COHORT_date;
  CREATE TABLE @target_database_schema.@AdtVsNonadtPc_COHORT_date as (
  	SELECT a.*, DATEADD(year, (-1), a.index_date) AS index_before_1yr, 
	    	DATEADD(year, 1, a.index_date) AS index_after_1yr,
	    	DATEADD(day, 180, a.index_date) AS index_after_180days
	FROM @target_database_schema.AdtVsNonadtPc_COHORT_id a
  );