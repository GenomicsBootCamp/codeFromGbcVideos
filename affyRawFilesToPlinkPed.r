# Gabor Meszaros, Genomics Boot Camp, https://www.youtube.com/GenomicsBootCamp
# change Affymetrix text file to PLINK

#clean work space
rm(list = ls())
#set working directory
setwd("c:/analysis/2020_GenomicsBootCamp_Demo/2023/affyFileToPed/")
#load packages
library(tidyverse)


# load Affy file
# WARNING!!! Manual change of "Call Modified" to "CallModified"
rawData <- read_table("rawAffySample.txt", skip = 5)

###############################
# Arrange tped file structure
###############################
# chr snpName morgan position nGenotypes
tped <- rawData %>% 
  mutate(morgan = 0) %>% 
  #select(Chr_id, probeset_id, morgan, Start, starts_with("animal")) # alternative col select: ends_with()
  select(Chr_id, probeset_id, morgan, Start, 2:91) %>% 
  mutate(across(.fns = ~replace(., . ==  "AA" , "A A")))%>% 
  mutate(across(.fns = ~replace(., . ==  "AB" , "A B")))%>% 
  mutate(across(.fns = ~replace(., . ==  "BA" , "B A")))%>% 
  mutate(across(.fns = ~replace(., . ==  "BB" , "B B")))%>% 
  mutate(across(.fns = ~replace(., . ==  "NoCall" , "0 0")))
# write out to file
write_delim(tped, "GenomicsBootCamp.tped", col_names = F, quote = "none")


###############################
# Arrange fam file structure
###############################
tmp <- rawData %>% 
  #select(Chr_id, probeset_id, morgan, Start, starts_with("animal")) # alternative col select: ends_with()
  select(2:91)
IID <- colnames(tmp)

tfam <- tibble(IID) %>% 
  mutate(FID = "GBC", sire = 0, dam = 0, sex = 0, pheno = -9) %>% 
  relocate(IID, .after = FID)
# write out to file
write_delim(tfam, "GenomicsBootCamp.tfam", col_names = F, quote = "none")


###############################
# Change genotype file format w PLINK
###############################
system("plink --tfile GenomicsBootCamp --cow --recode --out GenomicsBootCamp")

