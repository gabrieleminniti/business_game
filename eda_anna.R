### Source
source("data_import.R")

### EDA
# Boh, un po' di cose a caso

summary(train$TARGET)
hist(train$TARGET)
hist(log(train$TARGET), n =100)

## molto skewed

full <- bind_rows(train, test)

table(full$MERCATO)
## a parte Italia e Brasile le altre più o meno simili. Turchia 3
# Europa? si possono creare delle aree (sudamerica, nordeuropa, centroeuropa, est)
boxplot(train$TARGET~train$MERCATO)
table(test$MERCATO) #nel test nella Turchia sono 100


table(full$COD_PR)


table(train$TKT_TYPE) # quasi tutti TESEO e TUTOR, pochissimi gli altri (idem TEST)

table(train$GRAVITA, useNA = "ifany") #alta bassa media e un botto di NA
boxplot(train$TARGET~train$GRAVITA)


table(train$DINTERV) # NA!!
sum(is.na(train$DINTERV))  #151 NA

table(train$MARCA)
sum(is.na(train$MARCA)) #419 NA
boxplot(train$TARGET ~train$MARCA)


# mancano DEA, COD_PR: cosa vuol dire?

## si può creare 6 classi per la tipologia di ticket (A-B-C-D-E-F)

table(full$MCALL, full$GRAVITA)

table(full$TKT_TYPE)




### dati binari
# apertura? 

boxplot(full$TARGET ~full$Feedback_Negativo)

table(full$Apertura) #si
table(full$Assegnato) #si tantitable(full$Attesa_Ricambi) #ok
table(full$Attesa_di_Conferma) #si
table(full$Attivazione_Specialista)
table(full$Caso_Riaperto)
table(full$Caso_Singolo)
table(full$Cet)
table(full$Confirmed) #si
table(full$Escalation)
table(full$Feedback_Negativo) #si
table(full$Prima_Attivazione_Secondo_Livello)
table(full$Riapertura)
table(full$Soluzione_Non_Efficace)

## pochi 1


boxplot(train$TARGET~train$Secondo_Livello_in_Uscita)


table(full$Caso_Riaperto, full$Soluzione_Non_Efficace)
#tutti quelli riaperti erano inefficaci

