######################################## Setting ########################################
# Download pkg
list.of.packages <- c("dplyr", "MatchIt", "moonBook", "survminer", "survival")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
library(dplyr)
library(MatchIt)
library(moonBook)
library(survminer)
library(survival)

######################################## Analysis ########################################
# 1. data preprocessing
{
  precohort$cci_group <- ifelse(precohort$cci_group== "NULL", "0", precohort$cci_group)
  precohort$age_group <- as.factor(precohort$age_group)
  
  precohort$outcome_parkinson_time <- ifelse(precohort$outcome_parkinson_time == "NULL", 0, precohort$outcome_parkinson_time)
  precohort$outcome_parkinson_time <- as.numeric(precohort$outcome_parkinson_time)
  
  precohort$outcome_death_time <- ifelse(precohort$outcome_death_time == "NULL", 0, precohort$outcome_death_time)
  precohort$outcome_death_time <- as.numeric(precohort$outcome_death_time)
  
  precohort$outcome_dementia_time <- ifelse(precohort$outcome_dementia_time == "NULL", 0, precohort$outcome_dementia_time)
  precohort$outcome_dementia_time <- as.numeric(precohort$outcome_dementia_time)
  
  precohort <- left_join(precohort, cci)
  precohort$cci <- ifelse(precohort$cci ==1, 3, precohort$cci)
  precohort$cci <- ifelse(is.na(precohort$cci) == T, 2 , precohort$cci)
  precohort$cci_group <- ifelse(precohort$cci <=3, 1, ifelse(precohort$cci <=5, 2, 3))
  
  table(precohort$cci)
  
  precohort %>% select(person_id) %>% unique() %>% count() # 1709
  colnames(precohort)
  
  precohort <- precohort %>% filter(person_age < 80)
  precohort$age_group <- as.character(precohort$age_group)
}

# 2. psm
{
  # original
  m.out0 <- matchit(target ~ person_age + age_group + cci + as.factor(cci_group) + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + urine_anticholinergic + urine_antidepressant + mt_cancer ,
                    method = NULL,
                    distance = "glm",
                    data = precohort)
  summary(m.out0) -> s
  asd <- as.data.frame(cbind(s$sum.all[,3])); colnames(asd) <- c("cohort")
  asd
  
  
  # psm
  m.out10 <- matchit(target ~ age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + cci_group, 
                     method = 'nearest',
                     distance = "glm",
                     data = precohort)
  
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
  
  mycsv(mytable(target ~ outcome_dementia + outcome_parkinson + outcome_death + person_age + age_group + cci + cci_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + urine_anticholinergic + urine_antidepressant + mt_cancer  ,
                data = precohort, show.total=T), file = file.path(getwd(), "outputFolder", "Table1_ORG.csv"))
  
  mycsv(mytable(target ~ outcome_dementia + outcome_parkinson + outcome_death + person_age + age_group + cci + cci_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + urine_anticholinergic + urine_antidepressant + mt_cancer  ,
                data = m.data, show.total=T), file = file.path(getwd(), "outputFolder", "Table1_PSM.csv"))
  
  quantile <- matrix(NA, 15,15)
  
  quantile <- rbind(quantile, quantile(m.data$cci))
  quantile <- rbind(quantile(m.data[which(m.data$target==1),]$cci))
  quantile <- rbind(quantile(m.data[which(m.data$target==0),]$cci))
  
  quantile <- rbind(quantile(precohort$cci))
  quantile <- rbind(quantile(precohort[which(precohort$target==1),]$cci))
  quantile <- rbind(quantile(precohort[which(precohort$target==0),]$cci))
  
  
  quantile <- rbind(quantile(m.data$person_age))
  quantile <- rbind(quantile(m.data[which(m.data$target==1),]$person_age))
  quantile <- rbind(quantile(m.data[which(m.data$target==0),]$person_age))
  
  quantile <- rbind(quantile(precohort$person_age))
  quantile <- rbind(quantile(precohort[which(precohort$target==1),]$person_age))
  quantile <- rbind(quantile(precohort[which(precohort$target==0),]$person_age))
  
  
  quantile <- rbind(quantile(m.data$person_age))
  quantile <- rbind(quantile(m.data[which(m.data$target==1),]$person_age))
  quantile <- rbind(quantile(m.data[which(m.data$target==0),]$person_age))
  
  write.csv(as.data.frame(quantile), file = file.path(getwd(), "outputFolder", "Table1_categoricalvariables.csv"))
}

# 4. table 2
{
  t2 <- matrix(NA, 5, 5)
  
  # dementia
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target, data = precohort) -> c; summary(c) -> c
  t2[1,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = precohort) -> c; summary(c) -> c
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
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target, data = precohort) -> c; summary(c) -> c
  t2[2,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = precohort) -> c; summary(c) -> c
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
  coxph(Surv(outcome_death_time, outcome_death) ~ target, data = precohort) -> c; summary(c) -> c
  t2[3,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = precohort) -> c; summary(c) -> c
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
  
  
  write.csv(t2, file = file.path(getwd(), "outputFolder", "Table2_Cox.csv"))
}

# 5. table 3
{
  
  t3 <- matrix(NA, 6, 5)
  precohort_under70 <- precohort %>% filter(person_age <70)
  # psm
  m.out20 <- matchit(target ~ age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + cci_group, 
                     method = 'nearest',
                     distance = "glm",
                     data = precohort_under70)
  
  m.data20 <- match.data(m.out20)
  
  
  # dementia
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target, data = precohort_under70) -> c; summary(c) -> c
  t3[1,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = precohort_under70) -> c; summary(c) -> c
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
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target, data = precohort_under70) -> c; summary(c) -> c
  t3[2,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = precohort_under70) -> c; summary(c) -> c
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
  coxph(Surv(outcome_death_time, outcome_death) ~ target, data = precohort_under70) -> c; summary(c) -> c
  t3[3,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target +
          age_group + mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = precohort_under70) -> c; summary(c) -> c
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
  precohort_above70 <- precohort %>% filter(person_age >=70)
  # psm
  m.out21 <- matchit(target ~ mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + cci_group, 
                     method = 'nearest',
                     distance = "glm",
                     data = precohort_above70)
  
  m.data21 <- match.data(m.out21)
  
  # dementia
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target, data = precohort_above70) -> c; summary(c) -> c
  t3[4,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_dementia_time, outcome_dementia) ~ target + #age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = precohort_above70) -> c; summary(c) -> c
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
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target, data = precohort_above70) -> c; summary(c) -> c
  t3[5,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_parkinson_time, outcome_parkinson) ~ target + #age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = precohort_above70) -> c; summary(c) -> c
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
  coxph(Surv(outcome_death_time, outcome_death) ~ target, data = precohort_above70) -> c; summary(c) -> c
  t3[6,1] <- paste0(round(c$coefficients[2],2), "(", round(c$conf.int[3],2), "-", round(c$conf.int[4],2), ")")
  
  
  coxph(Surv(outcome_death_time, outcome_death) ~ target + # age_group
          mh_hypertension + mh_diabetes + mh_dyslipidemia + mh_cardiovascular_disease + mh_peripheral_vascular_disease + mh_copd + mh_asthma + mh_liver_disease + pd_statin + pd_antiplatelet + pd_anticoagulant + pd_anticholinergic + pd_antidepressant + pd_antipsychotics + mt_cancer, 
        data = precohort_above70) -> c; summary(c) -> c
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
  
  write.csv(t3, file = file.path(getwd(), "outputFolder", "Table3_subgroup_Cox.csv"))
  
  mycsv(mytable(target ~ outcome_dementia + outcome_parkinson +  outcome_death, data = precohort_under70, show.total = T), file = file.path(getwd(), "outputFolder", "Table3_subgroup_baseline_org_under.csv"))
  mycsv(mytable(target ~ outcome_dementia + outcome_parkinson +  outcome_death, data = precohort_above70, show.total = T), file = file.path(getwd(), "outputFolder", "Table3_subgroup_baseline_org_above.csv"))
  mycsv(mytable(target ~ outcome_dementia + outcome_parkinson +  outcome_death, data = m.data20, show.total = T), file = file.path(getwd(), "outputFolder", "Table3_subgroup_baseline_psm_under.csv"))
  mycsv(mytable(target ~ outcome_dementia + outcome_parkinson +  outcome_death, data = m.data21, show.total = T), file = file.path(getwd(), "outputFolder", "Table3_subgroup_baseline_psm_above.csv"))
  
}

