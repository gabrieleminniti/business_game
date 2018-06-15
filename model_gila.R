### source
source("eda.R")


### Variable importance giusto per vedere come va
library(ranger)

# rf_vi <- ranger(formula = TARGET ~ TKT_START + TKT_START_DIFF + MERCATO + n + COD_PR + MCALL + TKT_TYPE + 
#                   SERIE + AVARROLE + m + num_risorse + Apertura + Assegnato + Attivazione_Specialista + 
#                   Caso_Riaperto + Confirmed + Escalation + Feedback_Negativo + Prima_Attivazione_Secondo_Livello + 
#                   Riapertura + Soluzione_Non_Efficace, 
#                 data = train, 
#                 write.forest = FALSE, 
#                 num.random.splits = 4, 
#                 verbose = TRUE,
#                 importance = "impurity")
# 
# importance(rf_vi)

rf_prev <- ranger(formula = TARGET ~ TKT_START + TKT_START_DIFF + MERCATO + n + COD_PR + MCALL + TKT_TYPE + 
                    SERIE + AVARROLE + m + num_risorse + Apertura + Assegnato + Attivazione_Specialista + 
                    Caso_Riaperto + Confirmed + Escalation + Feedback_Negativo + Prima_Attivazione_Secondo_Livello + 
                    Riapertura + Soluzione_Non_Efficace + DINTERV + MARCA, 
                data = train, 
                write.forest = TRUE, 
                num.random.splits = 4, 
                verbose = TRUE, 
                num.trees = 2000)

yhat_rf <- predict(rf_prev, data = test)
yhat_rf <- exp(yhat_rf$predictions)

# rm(rf_prev)
# write.table(x = yhat, file = "mySubmission4.txt", row.names = FALSE, col.names = FALSE)

########################################################################################################################

library(xgboost)

### params
my_params <- list(eta = 0.1, min_child_weight = 10, subsample = 0.5)


### data
my_formula <- formula(TARGET ~ TKT_START + TKT_START_DIFF + MERCATO + n + COD_PR + MCALL + TKT_TYPE + 
                        SERIE + AVARROLE + m + num_risorse + Apertura + Assegnato + Attivazione_Specialista + 
                        Caso_Riaperto + Confirmed + Escalation + Feedback_Negativo + Prima_Attivazione_Secondo_Livello + 
                        Riapertura + Soluzione_Non_Efficace + DINTERV + MARCA)

set.seed(99)
samples_CV <- sample(1:nrow(train), size = round(0.66*nrow(train)), replace = FALSE)

# data_train <- Matrix::sparse.model.matrix(object = my_formula, 
#                                           data = train)

data_train_1 <- Matrix::sparse.model.matrix(object = my_formula, 
                                            data = train[samples_CV,])
data_train_1 <- xgb.DMatrix(data_train_1, label = train[samples_CV, "TARGET", drop = TRUE])

data_train_2 <- Matrix::sparse.model.matrix(object = my_formula, 
                                            data = train[-samples_CV,])
data_train_2 <- xgb.DMatrix(data_train_2, label = train[-samples_CV, "TARGET", drop = TRUE])

### watchlist
my_watchlist <- list(train = data_train_1, test = data_train_2) # NB: usare solo data_train_1 ovviamente in training

### objective
my_objective <- "reg:linear"

# reg:linear linear regression (Default).
# reg:logistic logistic regression.
# binary:logistic logistic regression for binary classification. Output probability.
# binary:logitraw logistic regression for binary classification, output score before logistic transformation.
# num_class set the number of classes. To use only with multiclass objectives.
# multi:softmax set xgboost to do multiclass classification using the softmax objective. Class is represented by a number and should be from 0 to num_class - 1.
# multi:softprob same as softmax, but prediction outputs a vector of ndata * nclass elements, which can be further reshaped to ndata, nclass matrix. The result contains predicted probabilities of each data point belonging to each class.
# rank:pairwise set xgboost to do ranking task by minimizing the pairwise loss.

xgb_prev <- xgb.train(params = my_params, 
                      data = data_train_1, 
                      nrounds = 300,  
                      watchlist = my_watchlist, 
                      objective = my_objective, 
                      verbose = 1, 
                      print_every_n = 50,
                      nthread = 4) 

### Preparo i testdata

my_formula_test <- formula( ~ TKT_START + TKT_START_DIFF + MERCATO + n + COD_PR + MCALL + TKT_TYPE + 
                        SERIE + AVARROLE + m + num_risorse + Apertura + Assegnato + Attivazione_Specialista + 
                        Caso_Riaperto + Confirmed + Escalation + Feedback_Negativo + Prima_Attivazione_Secondo_Livello + 
                        Riapertura + Soluzione_Non_Efficace + DINTERV + MARCA)

data_test <- Matrix::sparse.model.matrix(object = my_formula_test, 
                                         data = test)

### Prediction
yhat_xgb <- predict(xgb_prev, data_test)
yhat_xgb <- exp(yhat_xgb)

### Final prediction
yhat_final <- (yhat_rf + yhat_xgb)/2
write.table(x = yhat_final, file = "mySubmission5.txt", row.names = FALSE, col.names = FALSE)
