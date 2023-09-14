#########################
# GWAS - Deafness in dogs
#########################

# Data and published results
# Hayward JJ, Kelly-Smith M, Boyko AR, Burmeister L, De Risio L, Mellersh C, et al. (2020)
# A genome-wide association study of deafness in three canine breeds. 
# PLoS ONE 15(5): e0232900. https://doi.org/10.1371/journal.pone.0232900

# Clear work space
rm(list = ls())

# set up the working directory
setwd("/XXXXXXXXXXX/GEMMA_dogs")


# load packages
#library(tidyverse)
library(dplyr)
library(readr)
library(stringr)
library(ggplot2)
library(qqman)

#########################
# Prepare Phenotype data
#########################

# phenotype column name - for PLINK update
PHENOTYPE <- "deafnessCaseControl"

# load phenotype file
phenoData <- read_table("deafness_pheno.txt")

# recode phenotypes according to methods in the paper
tmp <- phenoData %>% 
  mutate(deafnessCode = case_when(
    BAER_test_phenotype == "bilaterally_deaf" ~ "1",
    BAER_test_phenotype == "unilaterally_deaf" ~ "2",
    BAER_test_phenotype == "hearing" ~ "3"
  )) %>% 
  mutate(deafnessCaseControl = case_when(
    BAER_test_phenotype == "bilaterally_deaf" ~ "1",
    BAER_test_phenotype == "hearing" ~ "2"
  )) %>% 
  mutate(FID = dogID) %>% 
  rename(IID = dogID) %>% 
#  drop_na() %>% 
  select(FID, IID, deafnessCode, deafnessCaseControl) %>% 
  write_delim("GWAS_dog_pheno.txt", delim = " ")

#########################
# Prepare Genotype data
#########################

# quality control in PLINK
system("./plink --dog --nonfounders --bfile deafness --autosome --mind 0.1 --geno 0.05 --make-bed --out afterQC")

# update phenotype in PLINK
system(str_c("./plink --dog --bfile afterQC --nonfounders --allow-no-sex --pheno GWAS_dog_pheno.txt --pheno-name ", PHENOTYPE,
             " --make-bed --out inputForGemma"))

# select only Australian cattle dogs - direct comparison w the paper
phenoData %>% 
  filter(breed == "australian_cattle_dog") %>% 
  mutate(FID = dogID) %>% 
  rename(IID = dogID) %>% 
  select(FID, IID) %>% 
  write_delim("dogsToKeep.txt", delim = " ")

system(str_c("./plink --dog --bfile inputForGemma --nonfounders --allow-no-sex ", 
             " --keep dogsToKeep.txt --make-bed --out inputForGemma_ACD"))

#########################
# Run GWAS with GEMMA
#########################

# compute the relationship matrix for population structure correction
system("./gemma-0.98.5 -bfile inputForGemma_ACD -gk 1 -o RelMat")  

# Note: all outputs and results will be saved in the "output" directory, created automatically

# run GEMMA
system("./gemma-0.98.5 -bfile inputForGemma_ACD -k ./output/RelMat.cXX.txt -lmm 2 -o GWASresults.lmm")


# in some cases the output file could contain incorrect line breaks
# possible confusion of Windows and Linux line endings
# in such cases run the following line - and than change the file name loaded for data vizualization
#system("tr -d '\r' <GWASresults.lmm.assoc.txt > GWASresults.lmm.assoc.lineBreaksOk.txt")


#########################
# Visualize results
#########################

# read in the GWAS results
resultGemma <- read_table("./output/GWASresults.lmm.assoc.txt")

#compute the Bonferroni threshold
bonferroni<--log10(0.05/ nrow(resultGemma))

#manhattan plot for Gemma results
png("GWAS_deafnessCaseControl.png")
manhattan(resultGemma,chr="chr",bp="ps",p="p_lrt",snp="rs",genomewideline=bonferroni)
dev.off()
#ggsave(str_c("GWASresults_",PHENOTYPE,".png"))

# QQ plot
png("GWAS_deafnessCaseControl_QQplot.png")
  qq(resultGemma$p_lrt)
dev.off()

#########################
# Exact the top results
#########################
resultGemma %>% 
  mutate(negLogP = -log10(p_lrt)) %>% 
  select(chr, rs, p_lrt, negLogP) %>% 
  filter(negLogP > 5)

