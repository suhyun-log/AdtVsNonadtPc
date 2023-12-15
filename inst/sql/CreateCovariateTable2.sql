 IF OBJECT_ID('@pd', 'U') IS NOT NULL
  	drop 	table @target_database_schema.@pd;
 IF OBJECT_ID('cohort_mt_cancer', 'U') IS NOT NULL
  	drop 	table @target_database_schema.cohort_mt_cancer;
	create 	table @target_database_schema.@pd as(
			select a.*, b.drug_exposure_start_date, b.drug_concept_id
			from @target_database_schema.cohort_interval_added a
			left join ( select d.* 
			            from @cdm_database_schema.drug_exposure d
			            inner join @vocabulary_database_schema.concept_ancestor a
			            on d.drug_concept_id = c.descendant_concept_id
			            where d.person_id in (select person_id from @target_database_schema.cohort_interval_added)
					        and a.ancestor_concept_id in (  
					        select distinct concept_id
					        from concept
					        where concept_name in (@drug_list_concept_id))) b
			on a.person_id = b.person_id
			and a.index_before_1yr <= b.drug_exposure_start_date
			and b.drug_exposure_start_date <= a.index_date
			);
	create table @target_database_schema.@cohort_drug as(
			select distinct person_id, case when drug_exposure_start_date is not null then 1 else 0 end as @pd
			from @target_database_schema.@pd
			);
