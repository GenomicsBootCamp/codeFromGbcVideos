#create PLINK PED file from 705 formatted data 
# script by Gabor Meszaros, https://www.youtube.com/c/GenomicsBootCamp

#load packages
library("tidyverse")
#set working directory
setwd("c:/analysis/2020_GenomicsBootCamp_Demo/2023/705FilesToPlinkPed/")

#create PLINK PED file from 705 formatted data 
geno <-  read_table("genFileToLoad.705", col_names = F) %>% 
  filter(X3 == 20) %>% 
  mutate(sire=0, dam=0, sex=0, pheno=-9) %>% 
  select(X1, X2, sire, dam, sex, pheno, X4)

# change individual genotype codes to A-B allele coding for ped files
# Adapt the column name as necessary, in this case this is "X4"
geno$X4 <- str_replace_all(geno$X4,'0','A A ')
geno$X4 <- str_replace_all(geno$X4,'1','A B ')
geno$X4 <- str_replace_all(geno$X4,'2','B B ')
geno$X4 <- str_replace_all(geno$X4,'5','- - ')

# # In case you need numbers as allele coding
# geno$X4 <- str_replace_all(geno$X4,'0','A')
# geno$X4 <- str_replace_all(geno$X4,'1','B')
# geno$X4 <- str_replace_all(geno$X4,'2','C')
# geno$X4 <- str_replace_all(geno$X4,'5','D')
# 
# geno$X4 <- str_replace_all(geno$X4,'A',"1 1 ")
# geno$X4 <- str_replace_all(geno$X4,'B',"1 2 ")
# geno$X4 <- str_replace_all(geno$X4,'C',"2 2 ")
# geno$X4 <- str_replace_all(geno$X4,'D',"0 0 ")


###
# WRITE OUT PED FILE
###
write_delim(geno, "change705toPlink.ped", delim = " ", quote = "none", col_names = F)

###
# WRITE OUT MAP FILE
###
mapFile <- read_table("SNP-Map-Array20.map", col_names = F) %>% 
  #mutate(morgan = 0) %>% 
  #select(X3, X1, morgan, X4) %>% 
  write_delim(., "change705toPlink.map", delim = " ", quote = "none", col_names = F)

# run PLINK to see if it works without errors
system("plink --file change705toPlink --missing-genotype - --output-missing-genotype 0 --cow --make-bed --out TestResult")


