SELECT count( distinct co.person_id)
  FROM @cdm_database_schema.CONDITION_OCCURRENCE co
  inner join (
          select distinct concept_id 
          from @vocabulary_database_schema.CONCEPT 
          where concept_id in (4161028,4163261,200962)
          and c.invalid_reason is null

          UNION  

          select c.concept_id
          from @vocabulary_database_schema.CONCEPT c
          join @vocabulary_database_schema.CONCEPT_ANCESTOR ca 
          on c.concept_id = ca.descendant_concept_id
          and ca.ancestor_concept_id in (200962)
          and c.invalid_reason is null
          ) cn 
  on co.condition_concept_id = cn.concept_id
  where (co.condition_start_date >= DATEFROMPARTS(2013, 01, 01) and co.condition_start_date <= DATEFROMPARTS(2017, 9, 30))