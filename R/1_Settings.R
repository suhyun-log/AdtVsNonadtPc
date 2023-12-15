######################################## Setting ########################################

# 1. Set working directory 
getwd()
outputFolder <- file.path(getwd(), "outputFolder")
if (!file.exists(outputFolder))
  dir.create(outputFolder, recursive = TRUE)

# 2. DB information
my_dbms<-''    # available : postgresql, oracle, redshift, sql server, pdw, netezza, bigquery, sqlite, sqlite extended, spark
my_host<-''    # host address
my_dbname<-''  # OMOP CDM db name
my_port<-      # port
my_user<-''    # username
my_password<-''# password
my_server <- '123.45.123.456' # sever

# 3. Download pkg
list.of.packages <- c("SqlRender", "DatabaseConnector")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
library(SqlRender)
library(DatabaseConnector)

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