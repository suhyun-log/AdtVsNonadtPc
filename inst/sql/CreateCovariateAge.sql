 IF OBJECT_ID('AdtVsNonadtPc_age', 'U') IS NOT NULL
  	drop 	table @target_database_schema.AdtVsNonadtPc_age;
	create 	table @target_database_schema.AdtVsNonadtPc_age as(
			select 	a.person_id, a.person_age, case   
			when a.person_age >= 40 and a.person_age <= 49 then 1
	    when a.person_age >= 50 and a.person_age <= 59 then 2
	    when a.person_age >= 60 and a.person_age <= 69 then 3
	    when a.person_age >= 70 and a.person_age <= 79 then 4
	    else 0 end as age_group
	    from ( select 	c.person_id, YEAR(c.index_date) - p.year_of_birth as person_age
					    from @target_database_schema.AdtVsNonadtPc_cohort_date c 
		  	      left join @cdm_database_schema.person p
		  	      on c.person_id = p.person_id
					   ) a
			);
