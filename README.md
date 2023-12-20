AdtVsNonadtPc
==============================

##### Comparison of the risk of dementia and Parkinson's disease in Androgen deprivation therapy (ADT) patients with the non-ADT group
##### Project I  D: 2023-B00009-001



Requirements
============

- A database in [Common Data Model version 5](https://github.com/OHDSI/CommonDataModel) in one of these platforms: SQL Server, Oracle, PostgreSQL, IBM Netezza, Apache Impala, Amazon RedShift, Google BigQuery, or Microsoft APS.
- R version 3.5.0 or newer
- On Windows: [RTools](http://cran.r-project.org/bin/windows/Rtools/)
- [Java](http://java.com)
- 25 GB of free disk space

How to run
==========
1. Follow [these instructions](https://ohdsi.github.io/Hades/rSetup.html) for seting up your R environment, including RTools and Java. 

2. Open your study package in RStudio. 

3. You can execute the study by modifying and using the code below. For your convenience, this code is also provided under `extras/CodeToRun.R`:


```r
# Set working directory 
getwd()
outputFolder <- file.path(getwd(), "outputFolder")
if (!file.exists(outputFolder)) {dir.create(outputFolder, recursive = TRUE)}

# DB information
my_dbms<-''     # available : postgresql, oracle, redshift, sql server, pdw, netezza, bigquery, sqlite, sqlite extended, spark
my_host<-''     # host address
my_dbname<-''   # OMOP CDM db name
my_port<-       # port
my_user<-''     # username
my_password<-'' # password
my_server <- '' # server : 123.45.123.456

# Download pkg
source(file.path(getwd(), "R/Package.R"))

# Download JDBC driver
pathToDriver <- file.path(getwd(), "jdbc")
downloadJdbcDrivers(my_dbms, pathToDriver)

# Connect to DB
connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = my_dbms,
					  server = paste0(my_server,"/",my_user),
					  user = my_user,
					  password = my_password,
					  port = my_port,
					  pathToDriver=pathToDriver)
connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)



# Input parameters
vocabulary_database_schema <-""
cdm_database_schema <-""
target_database_schema <-""
kcd_code_column <- "" # KCD-7 or ICD-10 column name in your CDM DB
oracleTempSchema = NULL # If your my_dbms is oracle, then enter "temp_schema" to oracleTempSchema

# Logging
ParallelLogger::addDefaultFileLogger(file.path(outputFolder, "log.txt"))
on.exit(ParallelLogger::unregisterLogger("DEFAULT"))

# Query sql
source(file.path(getwd(), "R/CreateCohortTables.R"))
source(file.path(getwd(), "R/CreateCohortSets.R"))
source(file.path(getwd(), "R/CreateCovariateSets.R"))

# Load data & pkg 
source(file.path(getwd(), "R/Analysis.R"))

# Analysis 
whole <- cohort; result1 <- matching_psm(whole); survival_fit(result1)

# Subgroup analysis 
under70 <- cohort %>% filter(person_age <70); result2 <- matching_psm(under70); survival_fit(result2)
above70 <- cohort %>% filter(person_age >=70); result3 <- matching_psm(above70); survival_fit(result3)

```

4. Upload the file ```outputFolder_<HospitalName>.zip``` in the output folder to the study coordinator:

License
=======
The AdtVsNonadtPc package is licensed under Apache License 2.0

Development
===========
AdtVsNonadtPc was developed in ATLAS and R Studio.

[Medical record Observation & Assessment for drug safety (2023-B00009-001)](https://moa.drugsafe.or.kr/main) 


