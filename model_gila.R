### source
source("eda.R")

### Variable importance giusto per vedere come va
library(ranger)

rf_vi <- ranger(formula = TARGET ~ TKT_START + TKT_START_DIFF + MERCATO + n + COD_PR + MCALL + TKT_TYPE + 
                  SERIE + AVARROLE + m + num_risorse + Apertura + Assegnato + Attivazione_Specialista + 
                  Caso_Riaperto + Confirmed + Escalation + Feedback_Negativo + Prima_Attivazione_Secondo_Livello + 
                  Riapertura + Soluzione_Non_Efficace, 
                data = train, 
                write.forest = FALSE, 
                num.random.splits = 4, 
                verbose = TRUE,
                importance = "impurity")

importance(rf_vi)

rf_prev <- ranger(formula = TARGET ~ TKT_START + TKT_START_DIFF + MERCATO + n + COD_PR + MCALL + TKT_TYPE + 
                  SERIE + AVARROLE + m + num_risorse, 
                data = train, 
                write.forest = TRUE, 
                num.random.splits = 4, 
                verbose = TRUE)



yhat <- predict(rf_prev, data = test)
yhat <- exp(yhat$predictions)

write.table(x = yhat, file = "mySubmission2.txt", row.names = FALSE, col.names = FALSE)
