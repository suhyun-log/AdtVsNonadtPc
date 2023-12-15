 IF OBJECT_ID('cohort_age', 'U') IS NOT NULL
  	drop 	table @target_database_schema.cohort_age;
	create 	table @target_database_schema.cohort_age as(
			select 	person_id, 
				DATEDIFF(YEAR, YEAR(c.index_date), p.year_of_birth) as person_age, 
				case   when YEAR(c.index_date) - p.year_of_birth >= 40 and YEAR(c.index_date) - p.year_of_birth <= 49 then 1
					   when YEAR(c.index_date) - p.year_of_birth >= 50 and YEAR(c.index_date) - p.year_of_birth <= 59 then 2
					   when YEAR(c.index_date) - p.year_of_birth >= 60 and YEAR(c.index_date) - p.year_of_birth <= 69 then 3
					   when YEAR(c.index_date) - p.year_of_birth >= 70 and YEAR(c.index_date) - p.year_of_birth <= 79 then 4
					   else 0 end as age_group
			from @target_database_schema.cohort c 
		  	left join @cdm_database_schema.person p
		  	on c.person_id = p.person_id);

 IF OBJECT_ID('mh_hypertension', 'U') IS NOT NULL
  	drop 	table @target_database_schema.mh_hypertension;
 IF OBJECT_ID('cohort_hypertension', 'U') IS NOT NULL
  	drop 	table @target_database_schema.cohort_hypertension;
	create table @target_database_schema.mh_hypertension as(
		select 	a.*, b.condition_start_date, b.@kcd_code_column
		from 	@target_database_schema.cohort_interval_added a
		left 	join @cdm_database_schema.condition_occurrence b
		on 		a.person_id = b.person_id
		where	LOWER(@kcd_code_column) LIKE '(i10|i11|i12|i13|i14|i15)%'
		and 	a.index_before_1yr <= b.condition_start_date
		and 	b.condition_start_date <= a.index_date
		);
	create table @target_database_schema.cohort_hypertension as(
		select distinct person_id, case when condition_start_date is not null then 1 else 0 end as mh_hypertension
		from mh_hypertension
		);

 IF OBJECT_ID('mh_diabetes_mellitus', 'U') IS NOT NULL
  	drop 	table @target_database_schema.mh_diabetes_mellitus;
 IF OBJECT_ID('cohort_diabetes', 'U') IS NOT NULL
  	drop 	table @target_database_schema.cohort_diabetes;
	create table @target_database_schema.mh_diabetes_mellitus as(
		select 	a.*, b.condition_start_date, b.@kcd_code_column
		from 	@target_database_schema.cohort_interval_added a
		left 	join @cdm_database_schema.condition_occurrence b
		on 		a.person_id = b.person_id
		where	LOWER(@kcd_code_column) LIKE '(e10|e11|e12|e13|e14)%'
		and 	a.index_before_1yr <= b.condition_start_date
		and 	b.condition_start_date <= a.index_date
		);
	create table @target_database_schema.cohort_diabetes as(
		select distinct person_id, case when condition_start_date is not null then 1 else 0 end as mh_diabetes_mellitus
		from mh_diabetes_mellitus
		);

 IF OBJECT_ID('mh_dyslipidemia', 'U') IS NOT NULL
  	drop 	table @target_database_schema.mh_dyslipidemia;
 IF OBJECT_ID('cohort_dyslipidemia', 'U') IS NOT NULL
  	drop 	table @target_database_schema.cohort_dyslipidemia;
	create table @target_database_schema.mh_dyslipidemia as(
		select 	a.*, b.condition_start_date, b.@kcd_code_column
		from 	@target_database_schema.cohort_interval_added a
		left 	join @cdm_database_schema.condition_occurrence b
		on 		a.person_id = b.person_id
		where	LOWER(@kcd_code_column) LIKE '(e78)%'
		and 	a.index_before_1yr <= b.condition_start_date
		and 	b.condition_start_date <= a.index_date
		);
	create table @target_database_schema.cohort_dyslipidemia as(
		select distinct person_id, case when condition_start_date is not null then 1 else 0 end as mh_dyslipidemia
		from mh_dyslipidemia
		);

 IF OBJECT_ID('mh_cardiovascular_disease', 'U') IS NOT NULL
  	drop 	table @target_database_schema.mh_cardiovascular_disease;
 IF OBJECT_ID('cohort_cardiovascular_disease', 'U') IS NOT NULL
  	drop 	table @target_database_schema.cohort_cardiovascular_disease;
	create table @target_database_schema.mh_cardiovascular_disease as(
		select 	a.*, b.condition_start_date, b.@kcd_code_column
		from 	@target_database_schema.cohort_interval_added a
		left 	join @cdm_database_schema.condition_occurrence b
		on 		a.person_id = b.person_id
		where	LOWER(@kcd_code_column) LIKE '(i05|i06|i07|i08|i09|i20|i21|i22|i23|i24|i25|i26|i27|i28|i30|i31|i32|i33|i34|i35|i36|i37|i38|i39|i40|i41|i42|i43|i44|i45|i46|i47|i48|i49|i50|i51|i52)%'
		and 	a.index_before_1yr <= b.condition_start_date
		and 	b.condition_start_date <= a.index_date
		);
	create table @target_database_schema.cohort_cardiovascular_disease as(
		select distinct person_id, case when condition_start_date is not null then 1 else 0 end as mh_cardiovascular_disease
		from mh_cardiovascular_disease
		);

 IF OBJECT_ID('mh_peripheral_vascular_disease', 'U') IS NOT NULL
  	drop 	table @target_database_schema.mh_peripheral_vascular_disease;
 IF OBJECT_ID('cohort_peripheral_vascular_disease', 'U') IS NOT NULL
  	drop 	table @target_database_schema.cohort_peripheral_vascular_disease;
	create table @target_database_schema.mh_peripheral_vascular_disease as(
		select 	a.*, b.condition_start_date, b.@kcd_code_column
		from 	@target_database_schema.cohort_interval_added a
		left 	join @cdm_database_schema.condition_occurrence b
		on 		a.person_id = b.person_id
		where	LOWER(@kcd_code_column) LIKE '(i70|i71|i72|i73|i74|i75|i76|i77|i78|i79|i80|i81|i82|i83|i84|i85|i86|i87|i88|i89)%'
		and 	a.index_before_1yr <= b.condition_start_date
		and 	b.condition_start_date <= a.index_date
		);
	create table @target_database_schema.cohort_peripheral_vascular_disease as(
		select distinct person_id, case when condition_start_date is not null then 1 else 0 end as mh_peripheral_vascular_disease
		from mh_peripheral_vascular_disease
		);

 IF OBJECT_ID('mh_copd', 'U') IS NOT NULL
  	drop 	table @target_database_schema.mh_copd;
 IF OBJECT_ID('cohort_copd', 'U') IS NOT NULL
  	drop 	table @target_database_schema.cohort_copd;
	create table @target_database_schema.mh_copd as(
		select 	a.*, b.condition_start_date, b.@kcd_code_column
		from 	@target_database_schema.cohort_interval_added a
		left 	join @cdm_database_schema.condition_occurrence b
		on 		a.person_id = b.person_id
		where	LOWER(@kcd_code_column) LIKE '(j41|j43|j44|j47)%'
		and 	a.index_before_1yr <= b.condition_start_date
		and 	b.condition_start_date <= a.index_date
		);
	create table @target_database_schema.cohort_copd as(
		select distinct person_id, case when condition_start_date is not null then 1 else 0 end as mh_copd
		from mh_copd
		);

 IF OBJECT_ID('mh_asthma', 'U') IS NOT NULL
  	drop 	table @target_database_schema.mh_asthma;
 IF OBJECT_ID('cohort_asthma', 'U') IS NOT NULL
  	drop 	table @target_database_schema.cohort_asthma;
	create table @target_database_schema.mh_asthma as(
		select 	a.*, b.condition_start_date, b.@kcd_code_column
		from 	@target_database_schema.cohort_interval_added a
		left 	join @cdm_database_schema.condition_occurrence b
		on 		a.person_id = b.person_id
		where	LOWER(@kcd_code_column) LIKE '(j45|j46)%'
		and 	a.index_before_1yr <= b.condition_start_date
		and 	b.condition_start_date <= a.index_date
		);
	create table @target_database_schema.cohort_asthma as(
		select distinct person_id, case when condition_start_date is not null then 1 else 0 end as mh_asthma
		from mh_asthma
		);

 IF OBJECT_ID('mh_liver_disease', 'U') IS NOT NULL
  	drop 	table @target_database_schema.mh_liver_disease;
 IF OBJECT_ID('cohort_liver_disease', 'U') IS NOT NULL
  	drop 	table @target_database_schema.cohort_liver_disease;
	create table @target_database_schema.mh_liver_disease as(
		select 	a.*, b.condition_start_date, b.@kcd_code_column
		from 	@target_database_schema.cohort_interval_added a
		left 	join @cdm_database_schema.condition_occurrence b
		on 		a.person_id = b.person_id
		where	LOWER(@kcd_code_column) LIKE '(k70|k71|k72|k73|k74|k75)%'
		and 	a.index_before_1yr <= b.condition_start_date
		and 	b.condition_start_date <= a.index_date
		);
	create table @target_database_schema.cohort_liver_disease as(
		select distinct person_id, case when condition_start_date is not null then 1 else 0 end as mh_liver_disease
		from mh_liver_disease
		);

 IF OBJECT_ID('mt_cancer', 'U') IS NOT NULL
  	drop 	table @target_database_schema.mt_cancer;
 IF OBJECT_ID('cohort_mt_cancer', 'U') IS NOT NULL
  	drop 	table @target_database_schema.cohort_mt_cancer;
	create table @target_database_schema.mt_cancer as(
		select 	a.*, b.condition_start_date, b.@kcd_code_column
		from 	@target_database_schema.cohort_interval_added a
		left 	join @cdm_database_schema.condition_occurrence b
		on 		a.person_id = b.person_id
		where	LOWER(@kcd_code_column) LIKE '(c77|c78|c79|c80)%'
		and 	a.index_before_1yr <= b.condition_start_date
		and 	b.condition_start_date <= a.index_after_180days
		);
	create table @target_database_schema.cohort_mt_cancer as(
		select distinct person_id, case when condition_start_date is not null then 1 else 0 end as mt_cancer
		from mt_cancer
		);


 
CREATE TABLE @target_database_schema.ADT_PC_cci AS
select c.*, o.ext_cond_source_value_kcd, o.condition_start_date 
from @target_database_schema.pre_cohort  c
left join @cdm_database_schema.condition_occurrence o
on c.person_id = o.person_id
where UPPER(@kcd_code_column) LIKE '(I12|I22|I252|I099|I110|I132|I1255|I1420|I1425|I1426|I1427|I1428|I1429|I150|P290|I70|I71|I731|I738|I739|I771|I790|I792|K551|K558|K559|Z958|Z959|G45|G46|H340|I6|F00|F01|F02F03|F051|G30|G311|I278|I279|J40|J41|J42|J43|J44|J45|J46|J47|J60|J61|J62|J63|J64|J65|J66|J67|J684|J701|J703|M05|M06|M315|M32|M33M34|M351|M353|M360|K25|K28|B18|K700|K701|K702|K703|K709|K713|K714|K715|K717|K73|K74|K760|K762|K763|K764|K768|K769|Z944|E100|E101|E106|E108|E109|E110|E111|E116|E118|E119|E120|E121|E126|E128|E129|E130|E131|E136|E138|E139|E140|E141|E146|E148|E149|E102|E103|E104|E105|E107|E112|E113|E114|E115|E117|E122|E123|E124|E125|E127|E132|E133|E134|E135|E137|E142|E143|E144|E145|E147|G041|G114|G801|G802|G81|G82|G830-G834|G839|I120|I131|N032|N033|N034|N035|N036|N037|N052|N053|N054|N055|N056|N057|N18|N19|N250|Z490-Z492|Z940|Z992|C00|C01|C02|C03|C04|C05|C26|C30|C31|C32|C33|C34|C37|C38|C39|C40|C41|C43|C45|C46|C47|C48|C49|C50|C51|C52|C53|C54|C55|C56|C57|C58|C60|C61|C62|C63|C64|C65|C76|C81|C82|C83|C84|C85|C88|C90|C91|C92|C93|C94|C9|C96|C97|I850|I859|I864|I982|K704|K711|K721|K729|K765|K766|K767|C77|C78|C79|C80|B20|B21|B22|B24)%'
and c.index_before_1yr <= o.condition_start_date
and o.condition_start_date <= c.index_date;

CREATE TABLE @target_database_schema.ADT_PC_cci2 AS
select *, 
case when UPPER(@kcd_code_column) LIKE '(I12|I22|I252|I099|I110|I132|I1255)%' 								then 1 else 0  END as a1,
case when UPPER(@kcd_code_column) LIKE '(I1420|I1425|I1426|I1427|I1428|I1429|I150|P290)%'  					then 1 else 0  END as a2,
case when UPPER(@kcd_code_column) LIKE '(I70|I71|I731|I738|I739|I771|I790|I792|K551|K558|K559|Z958|Z959)%'	then 1 else 0  END as a3,
case when UPPER(@kcd_code_column) LIKE '(G45|G46|H340|I6)%'													then 1 else 0  END as a4,
case when UPPER(@kcd_code_column) LIKE '(F00|F01|F02F03|F051|G30|G311)%'									then 1 else 0  END as a5,
case when UPPER(@kcd_code_column) LIKE '(I278|I279|J40|J41|J42|J43|J44|J45|J46|J47|J60|J61|J62|J63|J64|J65|J66|J67|J684|J701|J703)%' then 1 else 0  END as a6,
case when UPPER(@kcd_code_column) LIKE '(M05|M06|M315|M32|M33M34|M351|M353|M360)%'  						then 1 else 0  END as a7,
case when UPPER(@kcd_code_column) LIKE '(K25|K28)%'  														then 1 else 0  END as a8,
case when UPPER(@kcd_code_column) LIKE '(B18|K700|K701|K702|K703|K709|K713|K714|K715|K717|K73|K74|K760|K762|K763|K764|K768|K769|Z944)%') then 1 else 0  END as a9,
case when UPPER(@kcd_code_column) LIKE '(E100|E101|E106|E108|E109|E110|E111|E116|E118|E119|E120|E121|E126|E128|E129|E130|E131|E136|E138|E139|E140|E141|E146|E148|E149)%' then 1 else 0  END as a10,
case when UPPER(@kcd_code_column) LIKE '(E102|E103|E104|E105|E107|E112|E113|E114|E115|E117|E122|E123|E124|E125|E127|E132|E133|E134|E135|E137|E142|E143|E144|E145|E147)%' then 1 else 0  END as a11,
case when UPPER(@kcd_code_column) LIKE '(G041|G114|G801|G802|G81|G82|G830|G831|G832|G833|G834|G839)%'		then 1 else 0  END as a12,
case when UPPER(@kcd_code_column) LIKE '(I120|I131|N032|N033|N034|N035|N036|N037|N052|N053|N054|N055|N056|N057|N18|N19|N250|Z490|Z491|Z492|Z940|Z992)%'					 then 1 else 0  END as a13,
case when UPPER(@kcd_code_column) LIKE '(C00|C01|C02|C03|C04|C05|C26|C30|C31|C32|C33|C34|C37|C38|C39|C40|C41|C43|C45|C46|C47|C48|C49|C50|C51|C52|C53|C54|C55|C56|C57|C58|C60|C61|C62|C63|C64|C65|C76|C81|C82|C83|C84|C85|C88|C90|C91|C92|C93|C94|C9|C96|C97)%' then 2 else 0 END as a14 ,
case when UPPER(@kcd_code_column) LIKE '(I850|I859|I864|I982|K704|K711|K721|K729|K765|K766|K767)%' 			then 3 else 0 END as a15 ,
case when UPPER(@kcd_code_column) LIKE '(C77|C78|C79|C80)%'													then 1 else 0  END as a16,
case when UPPER(@kcd_code_column) LIKE '(B20|B21|B22|B24)%'													then 6 else 0 END as a17 
from @target_database_schema.ADT_PC_cci ;

CREATE TABLE @target_database_schema.ADT_PC_cci3 AS
SELECT PERSON_ID, sum(a1) as a1, sum(a2) as a2, sum(a3) as a3, sum(a4) as a4, sum(a5) as a5, sum(a6) as a6, sum(a7) as a7, sum(a8) as a8, sum(a9) as a9,
sum(a10) as a10, sum(a11) as a11, sum(a12) as a12, sum(a13) as a13, sum(a14) as a14, sum(a15) as a15, sum(a16) as a16, sum(a17) as a17
FROM @target_database_schema.ADT_PC_cci2
GROUP BY PERSON_ID;

CREATE TABLE @target_database_schema.ADT_PC_cci4 AS
SELECT PERSON_ID, CASE WHEN A1 >0 THEN 1 ELSE 0 END AS a1
, CASE WHEN A2 >0 THEN 1 ELSE 0 END AS a2
, CASE WHEN A3 >0 THEN 1 ELSE 0 END AS a3
, CASE WHEN A4 >0 THEN 1 ELSE 0 END AS a4
, CASE WHEN A5 >0 THEN 1 ELSE 0 END AS a5
, CASE WHEN A6 >0 THEN 1 ELSE 0 END AS a6
, CASE WHEN A7 >0 THEN 1 ELSE 0 END AS a7
, CASE WHEN A8 >0 THEN 1 ELSE 0 END AS a8
, CASE WHEN A9 >0 THEN 1 ELSE 0 END AS a9
, CASE WHEN A10 >0 THEN 1 ELSE 0 END AS a10
, CASE WHEN A11 >0 THEN 2 ELSE 0 END AS a11
, CASE WHEN A12 >0 THEN 2 ELSE 0 END AS a12
, CASE WHEN A13 >0 THEN 2 ELSE 0 END AS a13
, CASE WHEN A14 >0 THEN 2 ELSE 0 END AS a14
, CASE WHEN A15 >0 THEN 3 ELSE 0 END AS a15
, CASE WHEN A16 >0 THEN 6 ELSE 0 END AS a16
, CASE WHEN A17 >0 THEN 6 ELSE 0 END AS a17
FROM @target_database_schema.ADT_PC_cci3;