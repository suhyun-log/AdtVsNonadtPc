 IF OBJECT_ID('AdtVsNonadtPc_@list', 'U') IS NOT NULL
	  drop 	table @target_database_schema.AdtVsNonadtPc_@list;
	create table @target_database_schema.AdtVsNonadtPc_@list as(
		select 	a.*, b.condition_start_date, b.@kcd_code_column
		from 	@target_database_schema.AdtVsNonadtPc_cohort_date a
		left 	join @cdm_database_schema.condition_occurrence b
		on 		a.person_id = b.person_id
		where	substr(LOWER(b.@kcd_code_column), 1, 3) in (@concept_id)
		and 	a.index_before_1yr <= b.condition_start_date
		and 	b.condition_start_date <= a.index_date
		);
 IF OBJECT_ID('AdtVsNonadtPc_Medical_History_@list', 'U') IS NOT NULL
  	drop 	table @target_database_schema.AdtVsNonadtPc_Medical_History_@list;
	create table @target_database_schema.AdtVsNonadtPc_Medical_History_@list as(
		select distinct a.person_id, case when a.condition_start_date is not null then 1 else 0 end as @list
		from @target_database_schema.AdtVsNonadtPc_@list a
		);