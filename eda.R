### source
source("data_import.R")

print("Inizio EDA")

###
print("Modifico il TARGET tramite la trasformazione log")
train <- train %>% mutate(TARGET = log(TARGET))

print("Creo dataset combinato")
full <- bind_rows(train, test)

### TKT_START
print("Analisi TKT_START")
print("Carico la libreria per RcppRoll")

library(RcppRoll)
full <- full %>%
  mutate(TKT_START_DIFF = c(0, diff(TKT_START))) %>%
  mutate(TKT_START_DIFF = if_else(TKT_START_DIFF<=0.2, 0, 1))

### MERCATO
print("Analisi di MERCATO")
print("Tolgo la povera turchia")
full <- full %>%
  mutate(MERCATO = recode(MERCATO, TURCHIA = "OTHER"))

### DEA
print("Analisi di DEA")
print("Aggiungo il numero di interventi effettuato")
 
full <- full %>%  
  group_by(DEA) %>%
  add_count() %>%
  ungroup()

### COD_PR
print("Analisi di COD_PR")
full <- full %>%
  mutate(COD_PR = recode(COD_PR, altro = "AFFIL", FLOTTE = "MOBIL", PRODRISK = "MOBIL", 
                         TCS = "MOBILCC"))

### MCALL
print("Analisi di MCALL")
full <- full %>%
  mutate(MCALL = str_sub(MCALL, 8,8))

### TKT_TYPE
print("Analsi di TKT_TYPE")
full <- full %>%
  mutate(TKT_TYPE = recode(TKT_TYPE, typeFLEET = "typeTESEO", typeWDS = "typeTESEO"))

# ### DINTERV
# table(full$DINTERV, useNA = "ifany")
# full_noNA <- filter(full, !is.na(DINTERV))

# ### MODELLO
# print("Analisi per il modello")
# table(full$MODELLO)

# ### VERSIONE
# print("Analisi di Versione")
# table(full$VERSIONE)

### SERIE
print("Analisi di Serie")
full <- full %>%
  mutate(SERIE = recode(SERIE, serG = "othser", serU = "othser", serV = "othser", 
                        serW = "othser", serX = "othser", serY = "othser", serZ = "othser"))

### AVARUSER
print("Lavoro su AVARUSER")
print("Creo la funzione ausiliaria")
my_function_avaruser <- function(x) {
  if(x[[1]] == "U0000") return(x[[2]])
  else return(x[[1]])
}

print("Creo le variabili ad indicare il numero di risorse e quante volte lavorano")
full %>%
  select(AVARUSER) %>%
  mutate(num_risorse = str_count(AVARUSER, ".{5}\\h")) %>%
  mutate(ID_risorsa = unlist(map(str_split(full$AVARUSER, " "), .f = my_function_avaruser))) %>%
  group_by(ID_risorsa) %>%
  add_count() %>%
  ungroup() %>%
  select(num_risorse, n) %>%
  rename("m" = n) %>%
  bind_cols(full) -> full

rm(my_function_avaruser)

### Apertura
print("Analisi variabili binarie")
full %>%
  mutate(Apertura = ifelse(Apertura==2, 1, Apertura)) -> full



### Assegnato
full %>%
  mutate(Assegnato = ifelse(Assegnato==2, 1, Assegnato)) -> full

### Attesa di Conferma
full %>%
  mutate(Attesa_di_Conferma = ifelse(Attesa_di_Conferma==2, 1, Attesa_di_Conferma)) -> full

### Attivazione specialista
### Caso Riaperto
print("Elimino Caso Singolo e Cet")

### Confirmed
full %>%
  mutate(Confirmed = ifelse(Confirmed==2, 1, Confirmed)) -> full


############################################################################################
print("Torno a ridividere il tutto ed elimino full")

train <- full %>% filter(!is.na(TARGET))
test <- full %>% filter(is.na(TARGET))
rm(full)

print("Il modello 'suggerito' risulta essere")
print("TARGET ~ TKT_START + TKT_START_DIFF + MERCATO + n + COD_PR + MCALL + TKT_TYPE + ")
print("SERIE + AVARROLE + m + num_risorse + Apertura + Assegnato + Attivazione_Specialista")
print("Caso_Riaperto + Confirmed + Escalation + Feedback_Negativo + Prima_Attivazione_Secondo_Livello")
print("Riapertura + Soluzione_Non_Efficace")