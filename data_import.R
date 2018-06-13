### Librerie
library(tidyverse)


### Data

print("Inizio import training")
train <- read_tsv("data/TRAIN.txt")
print("Fine import training")
print("Inizio import test")
test <- read_tsv("data/TEST0.txt")
print("fine import test")
print("------------------------------------")
###