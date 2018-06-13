### source
source("eda.R")

### Variable importance giusto per vedere come va
library(ranger)

colnames(train)

rf_vi <- ranger(formula = TARGET ~ TKT_START + MERCATO + TKT_START_DIFF + COD_PR + TKT_TYPE + 
                  MCALL + AVARROLE + Escalation + Feedback_Negativo, 
                data = train, 
                write.forest = TRUE, 
                num.random.splits = 4, 
                verbose = TRUE)

plot(importance(rf_vi))

yhat <- predict(rf_vi, data = test)
yhat <- exp(yhat$predictions)

write.table(x = yhat, file = "mySubmission1.txt", row.names = FALSE, col.names = FALSE)
