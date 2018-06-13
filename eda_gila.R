### Source di Data Import
source("data_import.R")

### Inizio EDA
### Analisi della distribuzione del target
summary(train$TARGET)
ggplot(train) + 
  geom_histogram(aes(TARGET), bins = 50)

### Molto sbilanciata, potrebbe essere utile un log
ggplot(train) + 
  geom_histogram(aes(log(TARGET)), bins = 100)

### Leggermente meglio ma sembrano evidenziarsi come due/tre cluster di soggetti
### Inoltre sembrano esserci strani picchi

full <- bind_rows(train, test)


### TKT_START
summary(full$TKT_START)
### Dafuq vuol dire?
library(RcppRoll)
full %>%
  select(TKT_START) %>%
  mutate(diff = c(0, diff(TKT_START))) %>%
  select(diff) %>%
  .[[1, drop = TRUE]] %>%
  quantile(probs = c(0.95))
  

### MERCATO
table(full$MERCATO)
# Sono presenti alcuni "livelli rari" ma la situazione non è affatto tragica
# Non ha nessun senso lasciare "TURCHIA" da solo. Inoltre perchè EUROPE è a se?
# Vorrà dire il resto dell'europa?
# C'è anche un livello altro a cui potremmo aggregare TURCHIA

ggplot(full) + 
  geom_boxplot(aes(y = log(TARGET), group = MERCATO, col = MERCATO)) + 
  coord_flip()

### DEA
# In questo caso ci sono 9000 modalità per 100000 variabili, aka circa 1/10
# Proviamo a vedere quante obs ci sono per ogni modalità
full %>%
  group_by(DEA) %>%
  count() %>%
  ggplot(aes(x = n)) + 
  geom_histogram(bins = 100)

full %>%
  group_by(DEA) %>%
  count() %>%
  summary()
# L'evento è molto sbilanciato. 
# Si potrebbe una nuova variabile che indica quanto un cliente rompe il cazzo
# Del tipo "Poco" (tra 1 e 15), "Medio" (tra 15 e 30), e "Alto" (oltre 30)
full %>%
  group_by(DEA) %>%
  count() %>%
  ungroup() %>%
  select(n) %>%
  .[[1, drop = TRUE]] %>%
  quantile(probs = c(0.9))



### COD_PR
table(full$COD_PR)
### Alcuni eventi rari che aggregerei ad altro
ggplot(full, aes(y = TARGET, group = COD_PR, col = COD_PR)) + 
  geom_boxplot()

## Cambiare MCALL

## TKT_TYPE

### GRAVITA
table(full$GRAVITA, useNA = "ifany")
full %>%
  mutate(GRAVITA = ifelse(is.na(GRAVITA), "NA", GRAVITA)) %>%
  ggplot(aes(y = log(TARGET), group = GRAVITA, col = GRAVITA)) + 
  geom_boxplot()



