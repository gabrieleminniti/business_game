### source
source("data_import.R")

print("Inizio EDA")

print("Modifico il TARGET tramite la trasformazione log")
train <- train %>% mutate(TARGET = log(TARGET))

print("Creo dataset combinato")
full <- bind_rows(train, test)

print("Analisi TKT_START")
print("Carico la libreria per RcppRoll")

library(RcppRoll)
full <- full %>%
  mutate(TKT_START_DIFF = c(0, diff(TKT_START))) %>%
  mutate(TKT_START_DIFF = if_else(TKT_START_DIFF<=0.1, 0, 1))

print("Analisi di MERCATO")
print("Tolgo la povera turchia")
full <- full %>%
  mutate(MERCATO = recode(MERCATO, TURCHIA = "OTHER"))

# print("Analisi di DEA")
# print("Provo a creare una dummy che mi dice tanti/pochi interventi")
# 
# DEA_RECODE <- full %>%
#   group_by(DEA) %>%
#   count() %>%
#   ungroup() %>%
#   mutate(DEA_RECODE = if_else(n < 15, "0", if_else(n>30, "3", "2"))) %>%
#   select(-n)
# 
# full %>%
#   select(DEA)


train <- full %>% filter(!is.na(TARGET))
test <- full %>% filter(is.na(TARGET))
rm(full)
