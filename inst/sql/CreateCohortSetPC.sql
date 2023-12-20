IF OBJECT_ID('AdtVsNonadtPc_@CreateCohortTable', 'U') IS NOT NULL
  DROP TABLE @target_database_schema.AdtVsNonadtPc_@CreateCohortTable;
CREATE TABLE @target_database_schema.AdtVsNonadtPc_@CreateCohortTable as (
SELECT a.*, DATEADD(day, @medianDate, a.cohort_start_date) as index_date, @target as target 
FROM @target_database_schema.@target_cohort_table  a 
where a.cohort_definition_id = @target_cohort_id
  );