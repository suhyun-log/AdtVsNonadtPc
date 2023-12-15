# INPUT PARAMETERS
vocabulary_database_schema <-""
cdm_database_schema <-""
target_database_schema <-""
oracleTempSchema = NULL # Oracle = "temp_schema" 
kcd_code_column <- ""

######################################## Create Covariate Table #######################################
# age, medical_history, metastatic, cci
sql <- file.path(getwd(), "inst", "sql", "CreateCovariateTable1.sql")
sql <- SqlRender::readSql(sql)
sql <- SqlRender::renderSql(sql,
                            cdm_database_schema = cdm_database_schema,
                            target_database_schema = target_database_schema,
                            kcd_code_colum = kcd_code_column)$sql
sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
ParallelLogger::logInfo("Constructing concept information on server")
DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)

# drug
drug_list <- c("statin", "antiplatelet", "anticoagulant", "anticholinergic", "antidepressant", "antipsychotics", "urin_anticholinergic", "urin_antidepressant")
drug_list_concept_id <- {c(
                            #statin
                            "'atorvastatin', 'fluvastatin', 'lovastatin', 'pitavastatin', 'pravastatin', 'rosuvastatin', 'simvastatin'",

                            #antiplatelet
                            "'aspirin', 'clopidogrel', 'prasugrel', 'ticagrelor'",
                            
                            #anticoagulant
                            "'apixaban', 'dabigatran', 'edoxaban', 'rivaroxaban', 'warfarin'",
                            
                            #anticholinergic
                            "'aclidinium', ' atropine', ' benztropine', ' biperiden', ' butylscopolamine', ' cimetropium', ' clidinium', ' fesoterodine', ' flavoxate', ' glycopyrrolate', ' homatropine', ' ipratropium', ' mebeverine', ' orphenadrine', ' oxybutynin', ' papaverine', ' pinaverium', ' pralidoxime', ' procyclidine', ' scopolia', ' solifenacin', ' tiotropium', ' tiotropium', ' tolterodine', ' trihexyphenidyl', ' tropicamide', ' trospium', ' umeclidinium'",
                            
                            #antidepressant
                            "'alprazolam', ' amineptine', ' amitriptyline', ' amoxapine', ' bromazepam', 'brotiazolam', ' bupropion', ' chlordiazepoxide', ' citalopram', ' clobazam', ' clomipramine', ' clonazepam', ' clorazepate', ' clotiazepam', ' desvenlafaxine', ' diazepam', ' dosulepin', ' doxepin', ' duloxetine', ' escitalopram', ' estazolam', ' etizolam', ' fludiazepam', ' flunitrazepam', ' fluoxetine', ' flurazepam', ' fluvoxamine', ' hyperici herba', ' imipramine', ' lorazepam', ' maprotiline', ' medifoxamine', ' mexazolam', ' mianserin', ' midazolam', ' milnacipran', ' minaprine', ' mirtazapine', ' moclobemide', ' nefazodone', ' nordazepam', ' nortriptyline', ' oxazepam', ' paroxetine', ' pinazepam', ' quinupramine', ' sertraline', ' tianeptine', ' tofisopam', ' trazodone', ' triazolam', ' venlafaxine', ' vortioxetine'",
                            
                            #antipsychotics
                            "'amisulpiride', ' aripiprazole', ' blonanserin', ' bromperidol', ' chlorpromazine', ' chlorprothixene', ' clozapine', ' droperidol', ' flupentixol', ' haloperidol', ' levomepromazine', ' lithium', ' loxapine', ' melperone', ' mesoridazine', ' molindone', ' nemonapride', ' olanzapine', ' paliperidone', ' perphenazine', ' pimozide', ' prochlorperazine', ' quetiapine', ' risperidone', ' sulpiride', ' thioridazine', ' tiapride', ' triflupromazine', ' ziprasidone', ' zotepine', ' zuclopenthixol'",
                            
                            #urin_anticholinergic
                            
                            #urin_antidepressant
                            "'imipramine', 'duloxetine'"
                            
                          )}
for (i in length(length(drug_list))) {
  pd = paste0("pd_", drug_list[i])
  cohort_drug = paste0("cohort_", drug_list[i])
  sql <- file.path(getwd(), "inst", "sql", "CreateCovariateTable1.sql")
  sql <- SqlRender::readSql(sql)
  sql <- SqlRender::renderSql(sql,
                              vocabulary_database_schema = vocabulary_database_schema,
                              cdm_database_schema = cdm_database_schema,
                              target_database_schema = target_database_schema,
                              pd = pd,
                              cohort_drug = cohort_drug)$sql
  sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
  ParallelLogger::logInfo("Constructing concept information on server")
  DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
}

######################################## Create Covariate Set #######################################
# query
sql <- file.path(getwd(), "inst", "sql", "CreateCovariateTable1.sql")
sql <- SqlRender::readSql(sql)
sql <- SqlRender::renderSql(sql,target_database_schema = target_database_schema)$sql
sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
ParallelLogger::logInfo("Constructing concept information on server")
DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)

# pre cohort
sql <- {"SELECT * FROM @target_database_schema.ADT_PC_PRE_COHORT"}
sql <- translate(render(sql, target_database_schema = target_database_schema),targetdialect = my_dbms)
precohort <- querySql(conn, sql, progressBar = T, reportOverallTime = T)

# cci
sql <- {"SELECT * FROM @target_database_schema.ADT_PC_CCI_COHORT order by  cci"}
sql <- translate(render(sql, target_database_schema = target_database_schema),targetdialect = my_dbms)
cci <- querySql(conn, sql, progressBar = T, reportOverallTime = T)
