######################################## Load data & pkg ########################################
sql <- {"SELECT * FROM @target_database_schema.AdtVsNonadtPc_COHORT;"}
sql <- translate(render(sql, 
                        oracleTempSchema = oracleTempSchema,
                        target_database_schema = target_database_schema),targetDialect = my_dbms)[1]
cohort <- querySql(connection, as.character(sql))
######################################## Data preprocessing ########################################
cohort$index_date <- substr(cohort$index_date, 1, 10)
cohort <- cohort %>% mutate_all(~ifelse(. == "NULL", 0, .))
cohort$cci <- as.numeric(cohort$cci)
cohort[, c("cci_group", "age_group")] <- sapply(cohort[, c("cci_group", "age_group")], as.numeric)
outcome_time <- tolower(paste0("outcome_", cohortsToCreate$tableName[3:7], "_time"))
cohort[, c(outcome_time)] <- sapply(cohort[, c(outcome_time)], as.numeric)
outcome <- tolower(paste0("outcome_", cohortsToCreate$tableName[3:7]))
cohort[, c(outcome)] <- sapply(cohort[, c(outcome)], as.numeric)
cohort <- cohort %>% filter(person_age < 80, person_age >= 40)
if (table(cohort$age_group)[1]==0) {cohort$age_group <- as.factor((as.numeric(cohort$age_group)-1))}
if (table(cohort$cci_group)[1]==0) {cohort$cci_group <- as.factor((as.numeric(cohort$cci_group)-1))}
######################################## Baseline characteristics ########################################
variable_formular_one <- c("person_age", "age_group", "cci", "cci_group", "hypertension", "diabetes", "dyslipidemia", "cardiovascular_disease", "peripheral_vascular_disease", "copd", "asthma", "liver_disease", "statin", "antiplatelet", "anticoagulant", "anticholinergic", "antidepressant", "antipsychotics", "urine_anticholinergic", "urine_antidepressant", "metastatic_cancer")
variable_formular_psm <- c("age_group", "hypertension", "diabetes", "dyslipidemia", "cardiovascular_disease", "peripheral_vascular_disease", "copd", "asthma", "liver_disease", "statin", "antiplatelet", "anticoagulant", "cci_group")
variable_formular_stat <- c("outcome_dementia", "outcome_dementia_time", "outcome_dementia_ad", "outcome_dementia_ad_time", "outcome_dementia_vd", "outcome_dementia_vd_time", "outcome_dementia_other", "outcome_dementia_other_time", "outcome_parkinson", "outcome_parkinson_time", "person_age", "age_group", "cci", "cci_group", "hypertension", "diabetes", "dyslipidemia", "cardiovascular_disease", "peripheral_vascular_disease", "copd", "asthma", "liver_disease", "statin", "antiplatelet", "anticoagulant", "anticholinergic", "antidepressant", "antipsychotics", "urin_anticholinergic", "urin_antidepressant", "metastatic_cancer")
target_formula <- function(dataframe, variables) {
  existing_variables <- variables[variables %in% names(dataframe)]
  formula_str <- paste("target ~", str_c(existing_variables, collapse=" + "))
  return(as.formula(formula_str))
}
matching_psm<- function(data.full){
  tryCatch(
    {
      # before matching #########################################
      asd.full <- matchit(target_formula(data.full, variable_formular_one), 
                          method = NULL, distance = "glm", data = data.full)
      asd.full <- summary(asd.full)
      asd.table.full <- round(as.data.frame(cbind(asd.full$sum.all[,1:3])),3)
      asd.table.full$variable <- rownames(asd.table.full)
      # after matching ###############################################
      data.psm <- match.data(matchit(target_formula(data.full, variable_formular_psm), 
                                     method = 'nearest', distance = "glm", data = data.full))
      if (table(data.psm$age_group)[1]==0) {data.psm$age_group <- as.factor((as.numeric(data.psm$age_group)-1))}
      if (table(data.psm$cci_group)[1]==0) {data.psm$cci_group <- as.factor((as.numeric(data.psm$cci_group)-1))}
      asd.psm <- matchit(target_formula(data.psm, variable_formular_one)
                         , method = NULL, distance = "glm", data = data.psm)
      asd.psm <- summary(asd.psm)
      asd.table.psm <- round(as.data.frame(cbind(asd.psm$sum.all[,1:3])), 3)
      asd.table.psm$variable <- rownames(asd.table.psm)
      asd <- merge(asd.table.full, asd.table.psm, by ="variable", all.x = T, all.y = T)
      colnames(asd) <- c("Variable", "Means Treated Full", "Means Control Full", "StdMD Full", "Means Treated PSM", "Means Control PSM", "StdMD PSM" )
      write.csv(asd, file = file.path(getwd(), "outputFolder",  paste0("Table_", substitute(data.full), "_1_SMD.csv")))
      #data.psm <- data.psm %>% select(colnames(data.full))
    },
    error = function(e) {
      cat("Error in Matching:", conditionMessage(e), "\n")
    },
    finally = {
      cat("End of Matching \n")
    }
  )
  tryCatch(
    {
      baseline.full <- mytable(target_formula(data.full, variable_formular_stat), data = data.full, show.total=T)
      mycsv(baseline.full, file = file.path(getwd(), "outputFolder", paste0("Table_", substitute(data.full), "_1_Full.csv")))
    },
    error = function(e) {
      cat("Error in baseline for Full cohort:", conditionMessage(e), "\n")
    },
    finally = {
      cat("End of baseline for Full cohort \n")
    }
  )
  tryCatch(
    {
      # baseline ###############################################
      baseline.psm <- mytable(target_formula(data.psm, variable_formular_stat), data = data.psm, show.total=T)
      mycsv(baseline.psm, file = file.path(getwd(), "outputFolder", paste0("Table_", substitute(data.full), "_1_PSM.csv")))
    },
    error = function(e) {
      cat("Error in baseline for Matching cohort:", conditionMessage(e), "\n")
    },
    finally = {
      cat("End of baseline for Matching cohort \n")
    }
  )
  tryCatch(
    {
      quantile <- data.frame(
        cci_full = quantile(data.full$cci),
        cci_full_Adt = quantile(data.full[which(data.full$target==1),]$cci),
        cci_full_NonAdt = quantile(data.full[which(data.full$target==0),]$cci),
        cci_psm = quantile(data.psm$cci),
        cci_psm_Adt = quantile(data.psm[which(data.psm$target==1),]$cci),
        cci_psm_NonAdt = quantile(data.psm[which(data.psm$target==0),]$cci),
        age_full = quantile(data.full$person_age),
        age_full_Adt = quantile(data.full[which(data.full$target==1),]$person_age),
        age_full_NonAdt = quantile(data.full[which(data.full$target==0),]$person_age),
        age_psm = quantile(data.psm$person_age),
        age_psm_Adt = quantile(data.psm[which(data.psm$target==1),]$person_age),
        age_psm_NonAdt = quantile(data.psm[which(data.psm$target==0),]$person_age))
      write.csv(as.data.frame(quantile), file = file.path(getwd(), "outputFolder",  paste0("Table_", substitute(data.full), "_1_Count.csv")))
    },
    error = function(e) {
      cat("Error in Count variables:", conditionMessage(e), "\n")
    },
    finally = {
      cat("End of baseline for Count variables \n")
    }
  )
  return(list(asd.full = asd.full,
              asd.psm = asd.psm,
              asd = asd,
              baseline.full = baseline.full,
              baseline.psm = baseline.psm,
              quantile = quantile,
              data.full = data.full,
              data.psm = data.psm,
              data = substitute(data.full)))
}
######################################## Survival analysis ########################################
variable_formular_two <- c("target", "age_group", "hypertension", "diabetes", "dyslipidemia", "cardiovascular_disease", "peripheral_vascular_disease", "copd", "asthma", "liver_disease", "statin", "antiplatelet", "anticoagulant", "anticholinergic", "antidepressant", "antipsychotics", "metastatic_cancer")
variable_formular_three <- c("age_group", "urine_anticholinergic", "urine_antidepressant", "metastatic_cancer")
survival_formula <- function(dataframe, variables, outcome) {
  existing_variables <- variables[variables %in% names(dataframe)]
  formula_str <- paste0("Surv(outcome_", outcome, "_time, outcome_", outcome,") ~ ", str_c(existing_variables, collapse=" + "))
  return(formula(formula_str))
}
survival_fit <- function(result){
  survival_table <- data.frame(crude = NA,
                               adj1 = NA,
                               psm = NA,
                               adj2 = NA)
  data.full <- result$data.full
  for (i in 3:7) {
    outcome <- tolower( cohortsToCreate$tableName)[i]
    survival_fit <- summary(coxph(survival_formula(data.full, "target", outcome), data = data.full))
    survival_table[i-2, 1] <- paste0(round(survival_fit$coefficients[2],2), "(", round(survival_fit$conf.int[3],2), "-", round(survival_fit$conf.int[4],2), ")")
  }
  for (i in 3:7) {
    outcome <- tolower( cohortsToCreate$tableName)[i]
    survival_fit <- summary(coxph(survival_formula(data.full, variable_formular_two, outcome), data = data.full))
    survival_table[i-2, 2] <- paste0(round(survival_fit$coefficients[2],2), "(", round(survival_fit$conf.int[3],2), "-", round(survival_fit$conf.int[4],2), ")")
  }
  data.psm <- result$data.psm
  outcome_time <- tolower(paste0("outcome_", cohortsToCreate$tableName[3:7], "_time"))
  data.psm[, c(outcome_time)] <- sapply(data.psm[, c(outcome_time)], as.numeric)
  outcome <- tolower(paste0("outcome_", cohortsToCreate$tableName[3:7]))
  data.psm[, c(outcome)] <- sapply(data.psm[, c(outcome)], as.numeric)
  for (i in 3:7) {
    outcome <- tolower( cohortsToCreate$tableName)[i]
    survival_fit <- summary(coxph(survival_formula(data.psm, "target", outcome), data = data.psm))
    survival_table[i-2, 3] <- paste0(round(survival_fit$coefficients[2],2), "(", round(survival_fit$conf.int[3],2), "-", round(survival_fit$conf.int[4],2), ")")
  }
  for (i in 3:7) {
    outcome <- tolower( cohortsToCreate$tableName)[i]
    survival_fit <- summary(coxph(survival_formula(data.psm, variable_formular_three, outcome), data = data.psm))
    survival_table[i-2, 4] <- paste0(round(survival_fit$coefficients[2],2), "(", round(survival_fit$conf.int[3],2), "-", round(survival_fit$conf.int[4],2), ")")
  }
  row.names(survival_table) = tolower( cohortsToCreate$tableName)[3:7]
  write.csv(survival_table, file = file.path(getwd(), "outputFolder", paste0("Table_", result$data, "_2_COX.csv")))
  return(survival_table = survival_table)
}