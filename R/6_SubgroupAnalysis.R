######################################## Setting ########################################
# INPUT PARAMETERS
target_database_schema <-""

# Download pkg
list.of.packages <- c("dplyr", "MatchIt", "moonBook", "survminer", "survival")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
library(dplyr)
library(MatchIt)
library(moonBook)
library(survminer)
library(survival)

######################################## Subgroup Analysis ########################################
# Dementia Subgroup
sql <- {"select * from @target_database_schema.Outcome_Dementia_AD
  union
  select * from @target_database_schema.Outcome_Dementia_VD
  union
  select * from @target_database_schema.Outcome_Dementia_other;"}
sql <- translate(render(sql, target_database_schema = target_database_schema),targetdialect = my_dbms)
outcome_dementia_sub <- querySql(conn, sql, progressBar = T, reportOverallTime = T)
head(outcome_dementia_sub)

# 1. data preprocessing
{
  outcome_dementia_sub <- outcome_dementia_sub %>% mutate(outcome_dementia_AD =  ifelse(cohort_definition_id == 4, 1, 0),
                                                          outcome_dementia_AD_date = ifelse(cohort_definition_id == 4, as.character(cohort_start_date), "NULL"),
                                                          
                                                          outcome_dementia_VD =  ifelse(cohort_definition_id == 5, 1, 0),
                                                          outcome_dementia_VD_date = ifelse(cohort_definition_id == 5, as.character(cohort_start_date), "NULL"),
                                                          
                                                          outcome_dementia_other =  ifelse(cohort_definition_id == 6, 1, 0),
                                                          outcome_dementia_other_date = ifelse(cohort_definition_id == 6, as.character(cohort_start_date), "NULL"),
  )
  
  colnames(outcome_dementia_sub)
  
  outcome_dementia_sub <- outcome_dementia_sub[,c(2,5:10)]
  colnames(outcome_dementia_sub)[1] <- "person_id"
  table(outcome_dementia_sub$outcome_dementia_AD)
  table(outcome_dementia_sub$outcome_dementia_VD)
  table(outcome_dementia_sub$outcome_dementia_other)
  
  cohort <- left_join(cohort,outcome_dementia_sub)
  table(cohort$outcome_dementia_AD)
  table(cohort$outcome_dementia_VD)
  table(cohort$outcome_dementia_other)
  
  cohort <- cohort %>% mutate(outcome_dementia_AD =  ifelse(is.na(outcome_dementia_AD) == T, 0, outcome_dementia_AD),
                              outcome_dementia_AD_date = ifelse(outcome_dementia_AD == 0, NA, outcome_dementia_AD_date),
                              
                              outcome_dementia_VD =  ifelse(is.na(outcome_dementia_VD) == T, 0, outcome_dementia_VD),
                              outcome_dementia_VD_date = ifelse(outcome_dementia_VD == 0, NA, outcome_dementia_VD_date),
                              
                              outcome_dementia_other =  ifelse(is.na(outcome_dementia_other) == T, 0, outcome_dementia_other),
                              outcome_dementia_other_date = ifelse(outcome_dementia_other == 0, NA, outcome_dementia_other_date)
  )
  
  
}

# 2. psm
{
  # original
  m.out0 <- matchit(target ~ person_age + age_group + cci + as.factor(cci_group) + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + urine_anticholinergic + urine_antidepressant + mt_cancer ,
                    method = NULL,
                    distance = "glm",
                    data = cohort)
  summary(m.out0) -> s
  asd <- as.data.frame(cbind(s$sum.all[,3])); colnames(asd) <- c("cohort")
  asd
  
  
  # psm
  m.out10 <- matchit(target ~ age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + cci_group, 
                     method = 'nearest',
                     distance = "glm",
                     data = cohort)
  
  m.data <- match.data(m.out10)
  
  
  m.out11 <- matchit(target ~ person_age + age_group + cci + as.factor(cci_group) + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + urine_anticholinergic + urine_antidepressant + mt_cancer ,
                     method = NULL,
                     distance = "glm",
                     data = m.data)
  summary(m.out11) -> s
  asd[,2] <- as.data.frame(cbind(s$sum.all[,3])); colnames(asd) <- c("cohort", "psm")
  asd
  
  table(m.data$target)
  
}

# 3. table 1  
{
  asd
  
  mycsv(mytable(target ~ outcome_dementia_AD + outcome_dementia_VD + outcome_dementia_other + outcome_dementia + outcome_parkinson + outcome_death + person_age + age_group + cci + cci_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + urine_anticholinergic + urine_antidepressant + mt_cancer  ,
                data = precohort, show.total=T), file = file.path(getwd(), "outputFolder", "Table1_org_dementia_detail.csv"))
  mycsv(mytable(target ~ outcome_dementia_AD + outcome_dementia_VD + outcome_dementia_other +outcome_dementia + outcome_parkinson + outcome_death + person_age + age_group + cci + cci_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + urine_anticholinergic + urine_antidepressant + mt_cancer  ,
  data = precohort, show.total=T), file = file.path(getwd(), "outputFolder", "Table1_psm_dementia_detail.csv"))

  quantile <- matrix(NA, 15,15)
  
  quantile <- rbind(quantile, quantile(m.data$cci))
  quantile <- rbind(quantile(m.data[which(m.data$target==1),]$cci))
  quantile <- rbind(quantile(m.data[which(m.data$target==0),]$cci))
  
  quantile <- rbind(quantile(cohort$cci))
  quantile <- rbind(quantile(cohort[which(cohort$target==1),]$cci))
  quantile <- rbind(quantile(cohort[which(cohort$target==0),]$cci))
  
  
  quantile <- rbind(quantile(m.data$person_age))
  quantile <- rbind(quantile(m.data[which(m.data$target==1),]$person_age))
  quantile <- rbind(quantile(m.data[which(m.data$target==0),]$person_age))
  
  quantile <- rbind(quantile(cohort$person_age))
  quantile <- rbind(quantile(cohort[which(cohort$target==1),]$person_age))
  quantile <- rbind(quantile(cohort[which(cohort$target==0),]$person_age))
  
  
  quantile <- rbind(quantile(m.data$person_age))
  quantile <- rbind(quantile(m.data[which(m.data$target==1),]$person_age))
  quantile <- rbind(quantile(m.data[which(m.data$target==0),]$person_age))
  
  write.csv(as.data.frame(quantile), file = file.path(getwd(), "outputFolder", "Table1_categoricalvariables_dementia_detail.csv"))
  
}

# 4. table 2
{
  t2 <- matrix(NA, 6, 5)
  
  # dementia
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target, data = cohort) -> c; summary(c) -> c
  t2[1,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort) -> c; summary(c) -> c
  t2[1,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target, data = m.data) -> c; summary(c) -> c
  t2[1,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data) -> c; summary(c) -> c
  t2[1,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target +
          age_group + urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data) -> c; summary(c) -> c
  t2[1,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  # parkinson
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target, data = cohort) -> c; summary(c) -> c
  t2[2,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort) -> c; summary(c) -> c
  t2[2,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target, data = m.data) -> c; summary(c) -> c
  t2[2,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data) -> c; summary(c) -> c
  t2[2,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target +
          age_group + urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data) -> c; summary(c) -> c
  t2[2,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  # death
  coxph(Surv(outcome_death_time, outcome_death) ~ target, data = cohort) -> c; summary(c) -> c
  t2[3,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort) -> c; summary(c) -> c
  t2[3,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target, data = m.data) -> c; summary(c) -> c
  t2[3,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data) -> c; summary(c) -> c
  t2[3,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target +
          age_group + urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data) -> c; summary(c) -> c
  t2[3,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  
  
  # dementia AD
  coxph(Surv(outcome_dementia_time, outcome_dementia_AD) ~ target, data = cohort) -> c; summary(c) -> c
  t2[4,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_AD) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort) -> c; summary(c) -> c
  t2[4,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_AD) ~ target, data = m.data) -> c; summary(c) -> c
  t2[4,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_AD) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data) -> c; summary(c) -> c
  t2[4,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_AD) ~ target +
          age_group + urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data) -> c; summary(c) -> c
  t2[4,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  
  # dementia VD
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target, data = cohort) -> c; summary(c) -> c
  t2[5,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort) -> c; summary(c) -> c
  t2[5,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target, data = m.data) -> c; summary(c) -> c
  t2[5,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data) -> c; summary(c) -> c
  t2[5,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target +
          age_group + urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data) -> c; summary(c) -> c
  t2[5,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  
  # dementia other
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target, data = cohort) -> c; summary(c) -> c
  t2[6,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort) -> c; summary(c) -> c
  t2[6,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target, data = m.data) -> c; summary(c) -> c
  t2[6,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data) -> c; summary(c) -> c
  t2[6,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target +
          age_group + urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data) -> c; summary(c) -> c
  t2[6,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  write.csv(t2, file = file.path(getwd(), "outputFolder", "Table2_Cox_dementia_detail.csv"))
  
}


# 5. table 3
{
  
  t3 <- matrix(NA, 6, 5)
  cohort_under70 <- cohort %>% filter(person_age <70)
  # psm
  m.out20 <- matchit(target ~ age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + cci_group, 
                     method = 'nearest',
                     distance = "glm",
                     data = cohort_under70)
  
  m.data20 <- match.data(m.out20)
  
  
  # dementia
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target, data = cohort_under70) -> c; summary(c) -> c
  t3[1,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort_under70) -> c; summary(c) -> c
  t3[1,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target, data = m.data20) -> c; summary(c) -> c
  t3[1,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data20) -> c; summary(c) -> c
  t3[1,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target +
          age_group + urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data20) -> c; summary(c) -> c
  t3[1,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  # parkinson
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target, data = cohort_under70) -> c; summary(c) -> c
  t3[2,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort_under70) -> c; summary(c) -> c
  t3[2,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target, data = m.data20) -> c; summary(c) -> c
  t3[2,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data20) -> c; summary(c) -> c
  t3[2,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target +
          age_group + urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data20) -> c; summary(c) -> c
  t3[2,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  # death
  coxph(Surv(outcome_death_time, outcome_death) ~ target, data = cohort_under70) -> c; summary(c) -> c
  t3[3,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort_under70) -> c; summary(c) -> c
  t3[3,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target, data = m.data20) -> c; summary(c) -> c
  t3[3,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data20) -> c; summary(c) -> c
  t3[3,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target +
          age_group + urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data20) -> c; summary(c) -> c
  t3[3,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  
  #
  cohort_above70 <- cohort %>% filter(person_age >=70)
  # psm
  m.out21 <- matchit(target ~ mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + cci_group, 
                     method = 'nearest',
                     distance = "glm",
                     data = cohort_above70)
  
  m.data21 <- match.data(m.out21)
  
  # dementia
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target, data = cohort_above70) -> c; summary(c) -> c
  t3[4,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target + #age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort_above70) -> c; summary(c) -> c
  t3[4,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target, data = m.data21) -> c; summary(c) -> c
  t3[4,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target + #age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data21) -> c; summary(c) -> c
  t3[4,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target + #age_group
          urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data21) -> c; summary(c) -> c
  t3[4,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  # parkinson
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target, data = cohort_above70) -> c; summary(c) -> c
  t3[5,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target + #age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort_above70) -> c; summary(c) -> c
  t3[5,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target, data = m.data21) -> c; summary(c) -> c
  t3[5,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target + #age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data21) -> c; summary(c) -> c
  t3[5,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target + #age_group
          urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data21) -> c; summary(c) -> c
  t3[5,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  # death
  coxph(Surv(outcome_death_time, outcome_death) ~ target, data = cohort_above70) -> c; summary(c) -> c
  t3[6,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target + # age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort_above70) -> c; summary(c) -> c
  t3[6,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target, data = m.data21) -> c; summary(c) -> c
  t3[6,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target + #age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data21) -> c; summary(c) -> c
  t3[6,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target + #age_group
          urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data21) -> c; summary(c) -> c
  t3[6,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  t3
  
  write.csv(t3, file = file.path(getwd(), "outputFolder", "Table3_Cox_subgroup_dementia_detail.csv"))
  
  
  mycsv(mytable(target ~ outcome_dementia + outcome_parkinson +  outcome_death, data = cohort_under70, show.total = T), file = file.path(getwd(), "outputFolder", "Table3_subgroup_baseline_org_under.csv"))
  mycsv(mytable(target ~ outcome_dementia + outcome_parkinson +  outcome_death, data = cohort_above70, show.total = T), file = file.path(getwd(), "outputFolder", "Table3_subgroup_baseline_org_above.csv"))
  mycsv(mytable(target ~ outcome_dementia + outcome_parkinson +  outcome_death, data = m.data20, show.total = T), file = file.path(getwd(), "outputFolder", "Table3_subgroup_baseline_psm_under.csv"))
  mycsv(mytable(target ~ outcome_dementia + outcome_parkinson +  outcome_death, data = m.data21, show.total = T), file = file.path(getwd(), "outputFolder", "Table3_subgroup_baseline_psm_above.csv"))
  
  
}


# 6. table 33
{
  
  t33 <- matrix(NA, 6, 5)
  cohort_under70 <- cohort %>% filter(person_age <70)
  # psm
  m.out20 <- matchit(target ~ age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + cci_group, 
                     method = 'nearest',
                     distance = "glm",
                     data = cohort_under70)
  
  m.data20 <- match.data(m.out20)
  
  
  # dementia AD
  coxph(Surv(outcome_dementia_time, outcome_dementia_AD) ~ target, data = cohort_under70) -> c; summary(c) -> c
  t33[1,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_AD) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort_under70) -> c; summary(c) -> c
  t33[1,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_AD) ~ target, data = m.data20) -> c; summary(c) -> c
  t33[1,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_AD) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data20) -> c; summary(c) -> c
  t33[1,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_AD) ~ target +
          age_group + urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data20) -> c; summary(c) -> c
  t33[1,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  # dementia VD
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target, data = cohort_under70) -> c; summary(c) -> c
  t33[2,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort_under70) -> c; summary(c) -> c
  t33[2,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target, data = m.data20) -> c; summary(c) -> c
  t33[2,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data20) -> c; summary(c) -> c
  t33[2,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target +
          age_group + urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data20) -> c; summary(c) -> c
  t33[2,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  # death
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target, data = cohort_under70) -> c; summary(c) -> c
  t33[3,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort_under70) -> c; summary(c) -> c
  t33[3,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target, data = m.data20) -> c; summary(c) -> c
  t33[3,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data20) -> c; summary(c) -> c
  t33[3,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target +
          age_group + urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data20) -> c; summary(c) -> c
  t33[3,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  
  #
  cohort_above70 <- cohort %>% filter(person_age >=70)
  # psm
  m.out21 <- matchit(target ~ mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + cci_group, 
                     method = 'nearest',
                     distance = "glm",
                     data = cohort_above70)
  
  m.data21 <- match.data(m.out21)
  
  # dementia
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target, data = cohort_above70) -> c; summary(c) -> c
  t33[4,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target + #age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort_above70) -> c; summary(c) -> c
  t33[4,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target, data = m.data21) -> c; summary(c) -> c
  t33[4,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target + #age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data21) -> c; summary(c) -> c
  t33[4,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target + #age_group
          urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data21) -> c; summary(c) -> c
  t33[4,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  # parkinson
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target, data = cohort_above70) -> c; summary(c) -> c
  t33[5,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target + #age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort_above70) -> c; summary(c) -> c
  t33[5,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target, data = m.data21) -> c; summary(c) -> c
  t33[5,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target + #age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data21) -> c; summary(c) -> c
  t33[5,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_VD) ~ target + #age_group
          urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data21) -> c; summary(c) -> c
  t33[5,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  # death
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target, data = cohort_above70) -> c; summary(c) -> c
  t33[6,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target + # age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = cohort_above70) -> c; summary(c) -> c
  t33[6,2] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target, data = m.data21) -> c; summary(c) -> c
  t33[6,3] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target + #age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = m.data21) -> c; summary(c) -> c
  t33[6,4] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  
  coxph(Surv(outcome_dementia_time, outcome_dementia_other) ~ target + #age_group
          urine_anticholinergic + urine_antidepressant + mt_cancer, 
        data = m.data21) -> c; summary(c) -> c
  t33[6,5] <- paste0(round(c$coefficients[1,2],2), "(", round(c$conf.int[1,3],2), "-", round(c$conf.int[1,4],2), ")")
  t33
  
  
  write.csv(t33, file = file.path(getwd(), "outputFolder", "Table3_Cox_subgroup_dementia_detail.csv"))
  
  
  mycsv(mytable(target ~ outcome_dementia + outcome_parkinson +  outcome_death, data = cohort_under70, show.total = T), file = file.path(getwd(), "outputFolder", "Table33_subgroup_baseline_org_under.csv"))
  mycsv(mytable(target ~ outcome_dementia + outcome_parkinson +  outcome_death, data = cohort_above70, show.total = T), file = file.path(getwd(), "outputFolder", "Table33_subgroup_baseline_org_above.csv"))
  mycsv(mytable(target ~ outcome_dementia + outcome_parkinson +  outcome_death, data = m.data20, show.total = T), file = file.path(getwd(), "outputFolder", "Table33_subgroup_baseline_psm_under.csv"))
  mycsv(mytable(target ~ outcome_dementia + outcome_parkinson +  outcome_death, data = m.data21, show.total = T), file = file.path(getwd(), "outputFolder", "Table33_subgroup_baseline_psm_above.csv"))
  
  
}
