######################################## Create cohort tables ########################################
sql <- file.path(getwd(), "inst", "sql", "CreateCohortTable.sql")
sql <- SqlRender::readSql(sql)
sql <- SqlRender::render(sql,
                            oracleTempSchema = oracleTempSchema,
                            create_cohort_table=TRUE,
                            cohort_database_schema=target_database_schema,
                            cohort_table="AdtVsNonadtPc")
sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))$sql
ParallelLogger::logInfo("Constructing concept information on server")
DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
######################################## Create cohorts ########################################
pathToCsv <-  file.path(getwd(), "inst", "settings", "CohortsToCreate.csv")
cohortsToCreate <- read.csv(pathToCsv)
for (i in 1:nrow(cohortsToCreate)) {
  writeLines(paste("Creating cohort:", cohortsToCreate$name[i]))
  sql <- SqlRender::render(readSql(file.path(getwd(), "inst", "sql", paste0(cohortsToCreate$name[i], ".sql"))),
                           oracleTempSchema = oracleTempSchema,
                           cdm_database_schema = cdm_database_schema,
                           vocabulary_database_schema = vocabulary_database_schema,
                           target_database_schema = target_database_schema,
                           target_cohort_table = "AdtVsNonadtPc",
                           target_cohort_id = cohortsToCreate$cohortId[i])
  sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))$sql
  DatabaseConnector::executeSql(connection, sql)
}
# Fetch cohort counts:
sql <- "SELECT cohort_definition_id, COUNT(*) AS count FROM @cohort_database_schema.@cohort_table GROUP BY cohort_definition_id"
sql <- SqlRender::render(sql,
                         oracleTempSchema = oracleTempSchema,
                         cohort_database_schema = target_database_schema,
                         cohort_table = "AdtVsNonadtPc")
sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))$sql
counts <- DatabaseConnector::querySql(connection, sql)
names(counts) <- SqlRender::snakeCaseToCamelCase(names(counts))
counts <- merge(counts, data.frame(cohortDefinitionId = cohortsToCreate$cohortId,
                                   cohortName  = cohortsToCreate$name))
write.csv(counts, file.path(outputFolder, "CohortCounts.csv"))
######################################## Calculate median date #################################
sql <- "SELECT a.subject_id, DATEDIFF(DAY, a.cohort_start_date, b.cohort_start_date)
FROM (SELECT * FROM @target_database_schema.AdtVsNonadtPc WHERE cohort_definition_id = 1) a
INNER JOIN (SELECT * FROM @target_database_schema.AdtVsNonadtPc WHERE cohort_definition_id = 8) b
	ON a.subject_id = b.subject_id
WHERE a.cohort_start_date <= b.cohort_start_date;"
sql <- translate(render(sql,
                        oracleTempSchema = oracleTempSchema,
                        target_database_schema = target_database_schema), targetDialect = my_dbms)
sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
dates <- querySql(connection, sql) 
medianDate <- median(dates[,2])