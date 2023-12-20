<<<<<<< HEAD
[Medical record Observation & Assessment for drug safety (2023-B00009-001)](https://moa.drugsafe.or.kr/main) 

# Assessment of the risk of adverse events following drug use in patients with prostate cancer using the common data model

### Comparison of the risk of dementia and Parkinson's disease in Androgen deprivation therapy (ADT) patients with the non-ADT group

##### Version 2 released on 14th Dec. 2023 / Updated by modifying code based on errors and sqlrender



1. Open AdtVsNonadt.proj
2. Run 6 R scripts in order
3. Post outputFolder.zip
=======
AdtVsNonadtPc
==============================


Information
============
- Project I  D: 2023-B00009-001
- Project Name: 전립선암 환자의 약물 사용 현황 및 이상사례 실태조사
- Project Goal: Androgen deprivation therapy(ADT) 환자에서의 치매 및 파킨슨병 발생 위험을 비 ADT군과 비교

- 발  주  처: 한국의약품안전관리원
- 연구책임자: 아주대 이한길 교수
- 공동연구자: 서울대 정창욱 교수
- 실  무  자: 서울대학교병원 김수현 (02-2072-4864, 5d932@snuh.org)


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
	######################################## Setting ########################################
  # 1. Set working directory 
  getwd()
  outputFolder <- file.path(getwd(), "outputFolder")
  if (!file.exists(outputFolder)) {dir.create(outputFolder, recursive = TRUE)}
  # 2. DB information
  my_dbms<-''     # available : postgresql, oracle, redshift, sql server, pdw, netezza, bigquery, sqlite, sqlite extended, spark
  my_host<-''     # host address
  my_dbname<-''   # OMOP CDM db name
  my_port<-       # port
  my_user<-''     # username
  my_password<-'' # password
  my_server <- '' # server : 123.45.123.456
  # 3. Download pkg
  source(file.path(getwd(), "R/Package.R"))
  # 4. Download JDBC driver
  pathToDriver <- file.path(getwd(), "jdbc")
  downloadJdbcDrivers(my_dbms, pathToDriver)
  # 5. Connect to DB
  connectionDetails <- DatabaseConnector::createConnectionDetails(dbms = my_dbms,
                                                                  server = paste0(my_server,"/",my_user),
                                                                  user = my_user,
                                                                  password = my_password,
                                                                  port = my_port,
                                                                  pathToDriver=pathToDriver)
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  ####################################### Query sql #######################################
  # INPUT PARAMETERS
  vocabulary_database_schema <-""
  cdm_database_schema <-""
  target_database_schema <-""
  kcd_code_column <- "" # KCD-7 or ICD-10 column name in your CDM DB
  oracleTempSchema = NULL # If your my_dbms is oracle, then enter "temp_schema" to oracleTempSchema
  # LOGGING
  ParallelLogger::addDefaultFileLogger(file.path(outputFolder, "log.txt"))
  on.exit(ParallelLogger::unregisterLogger("DEFAULT"))
  # DB CONNECTION
  connection <- DatabaseConnector::connect(connectionDetails = connectionDetails)
  # SQL
  source(file.path(getwd(), "R/CreateCohortTables.R"))
  source(file.path(getwd(), "R/CreateCohortSets.R"))
  source(file.path(getwd(), "R/CreateCovariateSets.R"))
  #################################### Load data & pkg #####################################
  source(file.path(getwd(), "R/Analysis.R"))
  ######################################## Analysis ########################################
  whole <- cohort; result1 <- matching_psm(whole); survival_fit(result1)
  #################################### Subgroup analysis ####################################
  under70 <- cohort %>% filter(person_age <70); result2 <- matching_psm(under70); survival_fit(result2)
  above70 <- cohort %>% filter(person_age >=70); result3 <- matching_psm(above70); survival_fit(result3)

```

4. Upload the file ```outputFolder_<HospitalName>.zip``` in the output folder to the study coordinator:

History
===========
Version 2: 2023년 12월 14일 배포
Update: 에러 및 sqlrender 기반으로 코드 수정

Version 2: 2023년 12월 21 배포
Update: 에러 코드 수정

License
=======
The hirafqs package is licensed under Apache License 2.0

Development
===========
AdtVsNonadtPc was developed in ATLAS and R Studio.

### Development status

Unknown





>>>>>>> f3e76cb (fix)
