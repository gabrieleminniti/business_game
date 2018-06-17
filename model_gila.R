### source
source("eda.R")


### Variable importance giusto per vedere come va
# library(ranger)

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

#############################################################################################################
### L'idea è buona ma in questo caso non funzione

# library(glmnet) # Sarebbe utile fare questo per primo, xgboost secondo e rf terzo
# library(doParallel)
# 
# my_cl <- makePSOCKcluster(2) # da cambiare
# registerDoParallel(my_cl)
# 
# ### data
# my_formula <- formula( ~ TKT_START + TKT_START_DIFF + MERCATO + n + COD_PR + MCALL + TKT_TYPE + 
#                         SERIE + AVARROLE + m + num_risorse + Apertura + Assegnato + Attivazione_Specialista + 
#                         Caso_Riaperto + Confirmed + Escalation + Feedback_Negativo + Prima_Attivazione_Secondo_Livello + 
#                         Riapertura + Soluzione_Non_Efficace + DINTERV + MARCA)
# 
# train_sparse <- sparse.model.matrix(my_formula, train)
# test_sparse <- sparse.model.matrix(my_formula, test)
# 
# ### parameters
# my_alpha <- seq(0, 1, length.out = 20)
# 
# ### model
# 
# my_stored_MSE <- numeric(length(my_alpha))
# 
# for(i in seq_along(my_alpha)) {
#   glmnet_prev <- cv.glmnet(x = train_sparse, 
#                          y = train$TARGET, 
#                          nfolds = 5, 
#                          parallel = TRUE,
#                          nlambda = 500,
#                          alpha = my_alpha[i])
#   my_stored_MSE[i] <- min(glmnet_prev$cvm)
#   print(paste("Iterazione numero", i, "di", length(my_alpha)))
#   print("Per ora il miglior modello fa")
#   print(min(my_stored_MSE[1:i]))
# }
# 
# ### goodness of fit
# glmnet_prev$cvm
# 
# stopCluster(my_cl)
# rm(my_cl)
# detach("package:doParallel", unload = TRUE)
# 
# # plot(glmnet_prev)
# yhat_glmnet <- exp(predict(glmnet_prev, newx = test_sparse)[,1])

#############################################################################################################
# library(nnet)
# 
# 
# ### prepare data
# train_for_nn <- train %>%
#   select(TKT_START, TKT_START_DIFF, MERCATO, n, COD_PR, MCALL, TKT_TYPE, SERIE, AVARROLE, m, num_risorse, 
#          Apertura, Assegnato, Attivazione_Specialista, Caso_Riaperto, Confirmed, Escalation, Feedback_Negativo,
#          Prima_Attivazione_Secondo_Livello, Riapertura, Soluzione_Non_Efficace, DINTERV, MARCA) %>%
#   mutate_if(is.numeric, scale) %>%
#   model.matrix(~ TKT_START + TKT_START_DIFF + MERCATO + n + COD_PR + MCALL + TKT_TYPE + 
#                  SERIE + AVARROLE + m + num_risorse + Apertura + Assegnato + Attivazione_Specialista + 
#                  Caso_Riaperto + Confirmed + Escalation + Feedback_Negativo + Prima_Attivazione_Secondo_Livello + 
#                  Riapertura + Soluzione_Non_Efficace + DINTERV + MARCA, data = .)
# 
# ### model
# nnet_prev <- nnet(x = train_for_nn, 
#                   y = train$TARGET, 
#                   size = 12, # da tunare?
#                   linout = TRUE) # for regression
# 
# mean((nnet_prev$fitted.values - train$TARGET)**2)

#############################################################################################################
# Troppo lento

# 
#
# library(kernlab)
# library(parallel)
# 
# ### formula
# my_formula <- formula(TARGET ~ -1 + TKT_START + TKT_START_DIFF + MERCATO + n + COD_PR + MCALL + TKT_TYPE + 
#                         SERIE + AVARROLE + m + num_risorse + Apertura + Assegnato + Attivazione_Specialista + 
#                         Caso_Riaperto + Confirmed + Escalation + Feedback_Negativo + Prima_Attivazione_Secondo_Livello + 
#                         Riapertura + Soluzione_Non_Efficace + DINTERV + MARCA)
# 
# ### sigma estimate
# sigest(train %>% model.matrix(my_formula, data = .)) #potrei fixarlo per non scalare i factors
# 
# ### grid
# pox_par <- expand.grid(
#   sigma = seq(0.005, 0.02, 0.005), # la prendo da subito sopra
#   type = c("eps-svr"), # da cambiare se faccio classificazione
#   # sarebbero da tunare anche eps e nu
#   C = 10 ^ seq(-2, 2) #sarebbe da fare da -2 a 2
# )
# 
# ### CV in parallel
# my_superman <- makeCluster(2L)
# 
# ### model
# cv_result <- clusterMap(
#   cl = my_superman, 
#   fun = function(my_sigma, my_C, my_type, my_formula, my_df) {
#     library(tidyverse)
#     library(kernlab)
#     return(
#       ksvm(x = my_formula, 
#            data = my_df %>% sample_frac(.1) %>% as.data.frame(),
#            scaled = TRUE,
#            cross = 5,
#            kernel = "rbfdot",
#            type = my_type,
#            kpar = list(sigma = my_sigma),
#            C = my_C)
#     )
#   },
#   my_sigma = pox_par$sigma,
#   my_C = pox_par$C,
#   my_type = as.character(pox_par$type),
#   MoreArgs = list(my_formula = my_formula, my_df = train),
#   RECYCLE = FALSE
# )
# stopCluster(my_superman)
# 
# # number of support vectors used
# plot(map_int(cv_result, function(x) x@nSV), ylab = "# of SV")
# 
# # Cross error
# (pox_par$cv_error <- map_dbl(cv_result, function(x) x@cross))
# 
# ggplot(pox_par) + 
#   geom_line(aes(x = sigma, y = cv_error)) + # da aggiungere col = type nel caso 
#   facet_grid(vars(type),vars(C))

#############################################################################################################
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

########################################################################################################
library(ranger)

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

#################################################################################################################

# cor(cbind(yhat_rf, yhat_xgb, yhat_glmnet))

### get weights

# data_train <- Matrix::sparse.model.matrix(object = my_formula, 
#                                             data = train)
# coef(lm(train$TARGET ~ predict(xgb_prev, data_train) + predict(rf_prev, train)$predictions))
# 
### Final prediction
### potrebbe essere meglio una media aritmetica
yhat_final <- (0.98* yhat_rf + 0.19 * yhat_xgb)/(0.98 + 0.19)
write.table(x = yhat_final, file = "mySubmission7.txt", row.names = FALSE, col.names = FALSE)


