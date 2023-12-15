# INPUT PARAMETERS
vocabulary_database_schema <-""
cdm_database_schema <-""
target_database_schema <-""
oracleTempSchema = NULL # Oracle = "temp_schema" 
######################################## Calculate median date #################################
sql <- "SELECT a.subject_id, DATEDIFF(a.cohort_start_date, b.cohort_start_date)
FROM (SELECT * FROM @target_database_schema.AdtVsNonadt WHERE cohort_definition_id = 1) LEFT JOIN (SELECT * FROM @target_database_schema.AdtVsNonadt WHERE cohort_definition_id = 8)
	ON a.subject_id = b.subject_id;"
sql <- translate(render(sql, target_database_schema = target_database_schema), targetDialect = my_dbms)
sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
dates <- querySql(conn, sql, progressBar = T, reportOverallTime = T)
medianDate <- median(dates)
######################################## Create cohorts ########################################
sql <- file.path(getwd(), "inst", "sql", "EachCohorts.sql")
sql <- SqlRender::readSql(sql)
sql <- SqlRender::renderSql(sql,
                            target_database_schema = target_database_schema,
                            medianDate = medianDate)$sql
sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
ParallelLogger::logInfo("Constructing concept information on server")
DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
######################################## Create Data set #######################################
sql <- file.path(getwd(), "inst", "sql", "CreateDataSet.sql")
sql <- SqlRender::readSql(sql)
sql <- SqlRender::renderSql(sql,
                            target_database_schema = target_database_schema)$sql
sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
ParallelLogger::logInfo("Constructing concept information on server")
DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)