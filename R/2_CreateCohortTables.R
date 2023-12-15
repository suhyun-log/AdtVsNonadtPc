# INPUT PARAMETERS
vocabulary_database_schema <-""
cdm_database_schema <-""
target_database_schema <-""
oracleTempSchema = NULL # Oracle = "temp_schema" 

#logging
ParallelLogger::addDefaultFileLogger(file.path(outputFolder, "log.txt"))
on.exit(ParallelLogger::unregisterLogger("DEFAULT"))
######################################## Create cohort tables ########################################
sql <- file.path(getwd(), "inst", "sql", "CreateCohortTable.sql")
sql <- SqlRender::readSql(sql)
sql <- SqlRender::renderSql(sql,
                            create_cohort_table=TRUE,
                            cohort_database_schema=cdm_database_schema,
                            cohort_table="AdtVsNonadt")$sql
sql <- SqlRender::translateSql(sql, targetDialect = attr(connection, "dbms"))$sql
ParallelLogger::logInfo("Constructing concept information on server")
DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
######################################## Create cohorts ########################################
pathToCsv <-  file.path(getwd(), "inst", "settings", "CohortsToCreate.csv")
cohortsToCreate <- read.csv(pathToCsv)
for (i in 1:nrow(cohortsToCreate)) {
  writeLines(paste("Creating cohort:", cohortsToCreate$name[i]))
  sql <- SqlRender::loadRenderTranslateSql(sqlFilename = file.path(getwd(), "inst", "sql", paste0(cohortsToCreate$name[i], ".sql")),
                                           dbms = attr(connection, "dbms"),
                                           oracleTempSchema = oracleTempSchema,
                                           cdm_database_schema = cdm_database_schema,
                                           vocabulary_database_schema = vocabulary_database_schema,
                                           target_database_schema = target_database_schema,
                                           target_cohort_table = "AdtVsNonadt",
                                           target_cohort_id = cohortsToCreate$cohortId[i])
  DatabaseConnector::executeSql(connection, sql)
}

# Fetch cohort counts:
sql <- "SELECT cohort_definition_id, COUNT(*) AS count FROM @cohort_database_schema.@cohort_table GROUP BY cohort_definition_id"
sql <- SqlRender::render(sql,
                         cohort_database_schema = target_database_schema,
                         cohort_table = "AdtVsNonadt")
sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))
counts <- DatabaseConnector::querySql(connection, sql)
names(counts) <- SqlRender::snakeCaseToCamelCase(names(counts))
counts <- merge(counts, data.frame(cohortDefinitionId = cohortsToCreate$cohortId,
                                   cohortName  = cohortsToCreate$name))
write.csv(counts, file.path(outputFolder, "CohortCounts.csv"))