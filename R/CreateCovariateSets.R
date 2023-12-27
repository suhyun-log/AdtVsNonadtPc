######################################## Create Covariate Age #######################################
sql <- file.path(getwd(), "inst", "sql", "CreateCovariateAge.sql")
sql <- SqlRender::readSql(sql)
sql <- SqlRender::render(sql,
                         oracleTempSchema = oracleTempSchema,
                         cdm_database_schema = cdm_database_schema,
                         target_database_schema = target_database_schema)
sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))[1]
ParallelLogger::logInfo("Constructing concept information on server")
DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
######################################## Create Covariate Medical History #######################################
load(file.path(getwd(), "inst", "settings", "medicalhistory_list.RData")) 
for (i in 1:length(medicalhistory_list)) {
  sql <- file.path(getwd(), "inst", "sql", "CreateCovariateMedicalHistory.sql")
  sql <- SqlRender::readSql(sql)
  sql <- SqlRender::render(sql,
                          oracleTempSchema = oracleTempSchema,
                          cdm_database_schema = cdm_database_schema,
                          target_database_schema = target_database_schema,
                          list = names(medicalhistory_list)[i],
                          concept_id = paste0("'", str_c(medicalhistory_list[[i]], collapse="', '"), "'"),
                          kcd_code_column = kcd_code_column)
  sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))[1]
  ParallelLogger::logInfo("Constructing concept information on server")
  DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
}
######################################## Create Covariate Drug #######################################
load(file.path(getwd(), "inst", "settings", "drug_list.RData")) 
for (i in 1:(length(drug_list)-2)) {
  sql <- file.path(getwd(), "inst", "sql", "CreateCovariateDrug1.sql")
  sql <- SqlRender::readSql(sql)
  sql <- SqlRender::render(sql,
                           oracleTempSchema = oracleTempSchema,
                           vocabulary_database_schema = vocabulary_database_schema,
                           cdm_database_schema = cdm_database_schema,
                           target_database_schema = target_database_schema,
                           list = names(drug_list)[i],
                           concept_id = paste0("'", str_c(drug_list[[i]], collapse="', '"), "'")
                              )
  sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))[1]
  ParallelLogger::logInfo("Constructing concept information on server")
  DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
}
for (i in (length(drug_list)-1):length(drug_list)) {
  sql <- file.path(getwd(), "inst", "sql", "CreateCovariateDrug2.sql")
  sql <- SqlRender::readSql(sql)
  sql <- SqlRender::render(sql,
                           oracleTempSchema = oracleTempSchema,
                           vocabulary_database_schema = vocabulary_database_schema,
                           cdm_database_schema = cdm_database_schema,
                           target_database_schema = target_database_schema,
                           list = names(drug_list)[i],
                           concept_id = paste0("'", str_c(drug_list[[i]], collapse="', '"), "'")
                           )
  sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))[1]
  ParallelLogger::logInfo("Constructing concept information on server")
  DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
}
######################################## Create Covariate CCI #######################################
sql <- file.path(getwd(), "inst", "sql", "CreateCovariateCCI.sql")
sql <- SqlRender::readSql(sql)
sql <- SqlRender::render(sql,
                         oracleTempSchema = oracleTempSchema,
                         cdm_database_schema = cdm_database_schema,
                         target_database_schema = target_database_schema,
                         kcd_code_column = kcd_code_column)
sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))[1]
ParallelLogger::logInfo("Constructing concept information on server")
DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
######################################## Create Covariate Set #######################################
sql <- file.path(getwd(), "inst", "sql", "CreateCovariateSet.sql")
sql <- SqlRender::readSql(sql)
sql <- SqlRender::render(sql,
                         oracleTempSchema = oracleTempSchema,
                         target_database_schema = target_database_schema)
sql <- SqlRender::translate(as.character(sql), targetDialect = attr(connection, "dbms"))[1]
ParallelLogger::logInfo("Constructing concept information on server")
DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)