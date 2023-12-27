######################################## Create cohort Target Comparator ########################################
pathToCsv <-  file.path(getwd(), "inst", "settings", "CohortsToCreate.csv")
cohortsToCreate <- read.csv(pathToCsv)
for (i in c(1,2,3)) {
  writeLines(paste("Creating cohort:", cohortsToCreate$name[i]))
  if (i == 2) {median = medianDate} else {median = 0}
  if (i == 1) {target = 1} else if (i == 2) {target = 0} else {target = 999}
  sql <- SqlRender::render(readSql(file.path(getwd(), "inst", "sql", "CreateCohortSetPC.sql")),
                           oracleTempSchema = oracleTempSchema,
                           target_database_schema = target_database_schema,
                           target_cohort_table = "AdtVsNonadtPc",
                           CreateCohortTable = cohortsToCreate$tableName[i],
                           target_cohort_id = cohortsToCreate$cohortId[i],
                           medianDate = median,
                           target = target)
  sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))[1]
  ParallelLogger::logInfo("Constructing concept information on server")
  DatabaseConnector::executeSql(connection, sql)
}
######################################## Create cohort Merge Target Comparator #######################################
sql <- file.path(getwd(), "inst", "sql", "CreateCohortSetPCMerge.sql")
sql <- SqlRender::readSql(sql)
sql <- SqlRender::render(sql,
                            oracleTempSchema = oracleTempSchema,
                            target_database_schema = target_database_schema,
                            AdtVsNonadtPc_COHORT_date = "AdtVsNonadtPc_COHORT_date")
sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))[1]
ParallelLogger::logInfo("Constructing concept information on server")
DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
######################################## Create cohort Outcomes #######################################
pathToCsv <-  file.path(getwd(), "inst", "settings", "CohortsToCreate.csv")
cohortsToCreate <- read.csv(pathToCsv)
for (i in 3:7) {
  writeLines(paste("Creating cohort:", cohortsToCreate$name[i]))
  sql <- SqlRender::render(readSql(file.path(getwd(), "inst", "sql", "CreateCohortSetOutcome.sql")),
                           oracleTempSchema = oracleTempSchema,
                           CreateCohortTable = cohortsToCreate$tableName[i],
                           cohortId = cohortsToCreate$cohortId[i],
                           AdtVsNonadtPc_COHORT_date = "AdtVsNonadtPc_COHORT_date",
                           target_database_schema = target_database_schema)
  sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))[1]
  ParallelLogger::logInfo("Constructing concept information on server")
  DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)
}
######################################## Create cohort Merge Outcomes #######################################
sql <- file.path(getwd(), "inst", "sql", "CreateCohortSetOutcomeMerge.sql")
sql <- SqlRender::readSql(sql)
sql <- SqlRender::render(sql,
                         oracleTempSchema = oracleTempSchema,
                         target_database_schema = target_database_schema)
sql <- SqlRender::translate(sql, targetDialect = attr(connection, "dbms"))[1]
ParallelLogger::logInfo("Constructing concept information on server")
DatabaseConnector::executeSql(connection, sql, progressBar = TRUE, reportOverallTime = TRUE)