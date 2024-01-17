IF OBJECT_ID('AdtVsNonadtPc_cci1', 'U') IS NOT NULL
	drop 	table @target_database_schema.AdtVsNonadtPc_cci1; 
CREATE TABLE @target_database_schema.AdtVsNonadtPc_cci1 AS
select c.*, o.@kcd_code_column, o.condition_start_date 
from @target_database_schema.AdtVsNonadtPc_COHORT_date  c
left join @cdm_database_schema.condition_occurrence o
on c.person_id = o.person_id
where (
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('I12', 'I22') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('I252', 'I099', 'I110', 'I132')  OR
substr(UPPER(o.@kcd_code_column), 1, 5) IN ('I1255') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('I150', 'P290') OR
substr(UPPER(o.@kcd_code_column), 1, 5) IN ('I1420', 'I1425', 'I1426', 'I1427', 'I1428', 'I1429') OR
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('I70', 'I71')	OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('I731', 'I738', 'I739', 'I771', 'I790', 'I792', 'K551', 'K558', 'K559', 'Z958', 'Z959')	OR
substr(UPPER(o.@kcd_code_column), 1, 2) IN ('I6') OR
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('G45', 'G46') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('H340') OR
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('F00', 'F01', 'F02', 'F03', 'G30') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('F051', 'G311') OR
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('J40', 'J41', 'J42', 'J43', 'J44', 'J45', 'J46', 'J47', 'J60', 'J61', 'J62', 'J63', 'J64', 'J65', 'J66', 'J67') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('I278', 'I279', 'J684', 'J701', 'J703') OR
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('M05', 'M06', 'M32', 'M33', 'M34') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('M315', 'M351', 'M353', 'M360') OR
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('K25', 'K28') OR
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('B18', 'K73', 'K74') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('K700', 'K701', 'K702', 'K703', 'K709', 'K713', 'K714', 'K715', 'K717', 'K760', 'K762', 'K763', 'K764', 'K768', 'K769', 'Z944') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('E100', 'E101', 'E106', 'E108', 'E109', 'E110', 'E111', 'E116', 'E118', 'E119', 'E120', 'E121', 'E126', 'E128', 'E129', 'E130', 'E131', 'E136', 'E138', 'E139', 'E140', 'E141', 'E146', 'E148', 'E149') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('E102', 'E103', 'E104', 'E105', 'E107', 'E112', 'E113', 'E114', 'E115', 'E117', 'E122', 'E123', 'E124', 'E125', 'E127', 'E132', 'E133', 'E134', 'E135', 'E137', 'E142', 'E143', 'E144', 'E145', 'E147') OR
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('G81', 'G82', 'G830', 'G831', 'G832', 'G833', 'G834', 'G839')	OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('G041', 'G114', 'G801', 'G802', 'G830', 'G831', 'G832', 'G833', 'G834', 'G839')	OR
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('N18', 'N19') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('I120', 'I131', 'N032', 'N033', 'N034', 'N035', 'N036', 'N037', 'N052', 'N053', 'N054', 'N055', 'N056', 'N057', 'N250', 'Z490', 'Z491', 'Z492', 'Z940', 'Z992') OR
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('C00', 'C01', 'C02', 'C03', 'C04', 'C05', 'C26', 'C30', 'C31', 'C32', 'C33', 'C34', 'C37', 'C38', 'C39', 'C40', 'C41', 'C43', 'C45', 'C46', 'C47', 'C48', 'C49', 'C50', 'C51', 'C52', 'C53', 'C54', 'C55', 'C56', 'C57', 'C58', 'C60', 'C61', 'C62', 'C63', 'C64', 'C65', 'C76', 'C81', 'C82', 'C83', 'C84', 'C85', 'C88', 'C90', 'C91', 'C92', 'C93', 'C94', 'C9', 'C96', 'C97') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('I850', 'I859', 'I864', 'I982', 'K704', 'K711', 'K721', 'K729', 'K765', 'K766', 'K767') OR
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('C77', 'C78', 'C79', 'C80')	OR
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('B20', 'B21', 'B22', 'B24')	
)
and c.index_before_1yr <= o.condition_start_date
and o.condition_start_date <= c.index_date;
IF OBJECT_ID('AdtVsNonadtPc_cci2', 'U') IS NOT NULL
	drop 	table @target_database_schema.AdtVsNonadtPc_cci2;
CREATE TABLE @target_database_schema.AdtVsNonadtPc_cci2 AS
select o.*, 
case when 
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('I12', 'I22') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('I252', 'I099', 'I110', 'I132')  OR
substr(UPPER(o.@kcd_code_column), 1, 5) IN ('I1255') 
then 1 else 0  END as a1,
case when 
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('I150', 'P290') OR
substr(UPPER(o.@kcd_code_column), 1, 5) IN ('I1420', 'I1425', 'I1426', 'I1427', 'I1428', 'I1429') 
then 1 else 0  END as a2,
case when 
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('I70', 'I71')	OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('I731', 'I738', 'I739', 'I771', 'I790', 'I792', 'K551', 'K558', 'K559', 'Z958', 'Z959')	
then 1 else 0  END as a3,
case when 
substr(UPPER(o.@kcd_code_column), 1, 2) IN ('I6') OR
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('G45', 'G46') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('H340') 
then 1 else 0  END as a4,
case when 
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('F00', 'F01', 'F02', 'F03', 'G30') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('F051', 'G311') 
then 1 else 0  END as a5,
case when 
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('J40', 'J41', 'J42', 'J43', 'J44', 'J45', 'J46', 'J47', 'J60', 'J61', 'J62', 'J63', 'J64', 'J65', 'J66', 'J67') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('I278', 'I279', 'J684', 'J701', 'J703') 
then 1 else 0  END as a6,
case when 
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('M05', 'M06', 'M32', 'M33', 'M34') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('M315', 'M351', 'M353', 'M360') 
then 1 else 0  END as a7,
case when 
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('K25', 'K28')
then 1 else 0  END as a8,
case when 
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('B18', 'K73', 'K74') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('K700', 'K701', 'K702', 'K703', 'K709', 'K713', 'K714', 'K715', 'K717', 'K760', 'K762', 'K763', 'K764', 'K768', 'K769', 'Z944') 
then 1 else 0  END as a9,
case when 
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('E100', 'E101', 'E106', 'E108', 'E109', 'E110', 'E111', 'E116', 'E118', 'E119', 'E120', 'E121', 'E126', 'E128', 'E129', 'E130', 'E131', 'E136', 'E138', 'E139', 'E140', 'E141', 'E146', 'E148', 'E149') 
then 1 else 0  END as a10,
case when 
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('E102', 'E103', 'E104', 'E105', 'E107', 'E112', 'E113', 'E114', 'E115', 'E117', 'E122', 'E123', 'E124', 'E125', 'E127', 'E132', 'E133', 'E134', 'E135', 'E137', 'E142', 'E143', 'E144', 'E145', 'E147') 
then 1 else 0  END as a11,
case when 
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('G81', 'G82', 'G830', 'G831', 'G832', 'G833', 'G834', 'G839')	OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('G041', 'G114', 'G801', 'G802', 'G830', 'G831', 'G832', 'G833', 'G834', 'G839')	
then 1 else 0  END as a12,
case when 
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('N18', 'N19') OR
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('I120', 'I131', 'N032', 'N033', 'N034', 'N035', 'N036', 'N037', 'N052', 'N053', 'N054', 'N055', 'N056', 'N057', 'N250', 'Z490', 'Z491', 'Z492', 'Z940', 'Z992') 
then 1 else 0  END as a13,
case when 
substr(UPPER(o.@kcd_code_column), 1, 3) IN ('C00', 'C01', 'C02', 'C03', 'C04', 'C05', 'C26', 'C30', 'C31', 'C32', 'C33', 'C34', 'C37', 'C38', 'C39', 'C40', 'C41', 'C43', 'C45', 'C46', 'C47', 'C48', 'C49', 'C50', 'C51', 'C52', 'C53', 'C54', 'C55', 'C56', 'C57', 'C58', 'C60', 'C61', 'C62', 'C63', 'C64', 'C65', 'C76', 'C81', 'C82', 'C83', 'C84', 'C85', 'C88', 'C90', 'C91', 'C92', 'C93', 'C94', 'C9', 'C96', 'C97') 
then 2 else 0 END as a14 ,
case when 
substr(UPPER(o.@kcd_code_column), 1, 4) IN ('I850', 'I859', 'I864', 'I982', 'K704', 'K711', 'K721', 'K729', 'K765', 'K766', 'K767') 
then 3 else 0 END as a15 ,
case when substr(UPPER(o.@kcd_code_column), 1, 3) IN ('C77', 'C78', 'C79', 'C80')	
then 1 else 0  END as a16,
case when substr(UPPER(o.@kcd_code_column), 1, 3) IN ('B20', 'B21', 'B22', 'B24')	
then 6 else 0 END as a17 
from @target_database_schema.AdtVsNonadtPc_cci1 o;
IF OBJECT_ID('AdtVsNonadtPc_cci3', 'U') IS NOT NULL
	drop 	table @target_database_schema.AdtVsNonadtPc_cci3;
CREATE TABLE @target_database_schema.AdtVsNonadtPc_cci3 AS
SELECT PERSON_ID, sum(a1) as a1, sum(a2) as a2, sum(a3) as a3, sum(a4) as a4, sum(a5) as a5, 
sum(a6) as a6, sum(a7) as a7, sum(a8) as a8, sum(a9) as a9, sum(a10) as a10, 
sum(a11) as a11, sum(a12) as a12, sum(a13) as a13, sum(a14) as a14, sum(a15) as a15, 
sum(a16) as a16, sum(a17) as a17
FROM @target_database_schema.AdtVsNonadtPc_cci2
GROUP BY PERSON_ID;
IF OBJECT_ID('AdtVsNonadtPc_cci4', 'U') IS NOT NULL
	drop 	table @target_database_schema.AdtVsNonadtPc_cci4;
CREATE TABLE @target_database_schema.AdtVsNonadtPc_cci4 AS
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
FROM @target_database_schema.AdtVsNonadtPc_cci3;
IF OBJECT_ID('AdtVsNonadtPc_cci', 'U') IS NOT NULL
	drop 	table @target_database_schema.AdtVsNonadtPc_cci;
CREATE TABLE @target_database_schema.AdtVsNonadtPc_cci AS
SELECT PERSON_ID, A1 + A2 + A3 + A4 + A5 + A6 + A7 + A8 + A9 + A10 + A11 + A12 + A13 + A14 + A15 + A16 + A17 AS CCI
FROM @target_database_schema.AdtVsNonadtPc_cci4 ;