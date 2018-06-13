### Librerie
library(tidyverse)


### Data

print("Inizio import training")
train <- read_csv("data/TRAIN.txt")
print("Fine import training")
print("Inizio import test")
test <- read_csv("data/TEST0.txt")
print("fine import test")
print("------------------------------------")
###