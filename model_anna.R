### source
source("eda.R")

### model
library(glmnet)

my_formula <- formula(TARGET ~ TKT_START + TKT_START_DIFF + MERCATO + n + COD_PR + MCALL + 
                        TKT_TYPE + SERIE + AVARROLE + m + num_risorse + Apertura + Assegnato + 
                        Attivazione_Specialista + Caso_Riaperto + Confirmed + Escalation + 
                        Feedback_Negativo + Prima_Attivazione_Secondo_Livello + Riapertura + 
                        Soluzione_Non_Efficace + DINTERV + MARCA)
my_formula_test <- formula( ~ TKT_START + TKT_START_DIFF + MERCATO + n + COD_PR + MCALL + 
                        TKT_TYPE + SERIE + AVARROLE + m + num_risorse + Apertura + Assegnato + 
                        Attivazione_Specialista + Caso_Riaperto + Confirmed + Escalation + 
                        Feedback_Negativo + Prima_Attivazione_Secondo_Livello + Riapertura + 
                        Soluzione_Non_Efficace + DINTERV + MARCA)

my_train_sparse <- Matrix::sparse.model.matrix(object = my_formula, data = train)
my_test_sparse <- Matrix::sparse.model.matrix(my_formula_test, data = test)

my_lasso <- cv.glmnet(x = my_train_sparse, 
                   y = train$TARGET,
                   family = "gaussian",
                   nfolds = 5,
                   parallel = FALSE)
my_lasso
plot(my_lasso)
class(my_lasso)

my_lasso$

prev_anna <- predict(my_lasso, newx = my_test_sparse, s = "lambda.1se")
prev_anna <- exp(prev_anna[,1])
write.table(file="AnnaSubmission.txt", prev_anna,row.names = FALSE,col.names = FALSE)

