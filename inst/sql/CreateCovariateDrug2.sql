 IF OBJECT_ID('AdtVsNonadtPc_@list', 'U') IS NOT NULL
  	drop 	table @target_database_schema.AdtVsNonadtPc_@list;	
  	create table @target_database_schema.AdtVsNonadtPc_@list as(
			select c.person_id, d.drug_exposure_start_date, d.drug_concept_id
			from @target_database_schema.AdtVsNonadtPc_COHORT_date c
			left join @cdm_database_schema.drug_exposure d
			on c.person_id = d.person_id
			inner join @vocabulary_database_schema.concept_ancestor a
			on d.drug_concept_id = a.descendant_concept_id
			where a.ancestor_concept_id in ( 
				select distinct v.concept_id 
				from @vocabulary_database_schema.concept v
				where v.concept_name in (@concept_id))
			and c.index_date <= d.drug_exposure_start_date
			and d.drug_exposure_start_date <= c.index_after_180days
			);
 IF OBJECT_ID('AdtVsNonadtPc_Drug_Use_@list', 'U') IS NOT NULL
  	drop 	table @target_database_schema.AdtVsNonadtPc_Drug_Use_@list;
	create 	table @target_database_schema.AdtVsNonadtPc_Drug_Use_@list as(
			select distinct d.person_id, case when d.drug_exposure_start_date is not null then 1 else 0 end as @list
			from @target_database_schema.AdtVsNonadtPc_@list d
			);