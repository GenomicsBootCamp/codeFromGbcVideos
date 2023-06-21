#########################
# Transform final report to PLINK files
#########################
# Note: This is *one* of the possible solutions
#       Any other way could be used that creates the same file structure
#########################

# Clear workspace
rm(list = ls())
# Set working directory
setwd("d:/analysis/2020_GenomicsBootCamp_Demo/")
#load packages
library(tidyverse)

# read in final report file
#
# base R - puts . in column names, instead of spaces
#finalReport <- read.csv("finalReportExample.csv", skip = 9, header = T)
#
# tidyverse - keeps spaces in column names and these arebetween single quotation marks 'columnName '  
finalReport <-  read_delim("finalReportExample.csv", delim = ",", skip = 9, col_names = T)  

###############################
# Your goal is to create lgen, fam and map files
# Some information might be missing in the final report, so youe need to replace them 
###############################
# Scenario 1 - You have all the info in the Final Report - Jackpot!
###############################


# Fam file
finalReport %>%
  distinct(`Sample Name`) %>%
  mutate(FID = "BTAU", sire = 0, dam = 0, sex = 0, phenotype = -9) %>%
  relocate(`Sample Name`, .after = FID) %>%
  write_delim("GenomicsBootCamp.fam", col_names = F)

# Lgen file
finalReport %>%
  mutate(FID = "BTAU") %>%
  select(FID, `Sample Name`, `SNP Name`, `Allele1 - AB`, `Allele2 - AB`) %>%
  write_delim("GenomicsBootCamp.lgen", col_names = F)

# Map file
finalReport %>%
  distinct(`SNP Name`, .keep_all = TRUE) %>%
  mutate(morgan = 0) %>%
  dplyr::select(Chr, `SNP Name`, morgan, Position) %>%
  write_delim("GenomicsBootCamp.map", col_names = F)

# change to ped file with PLINK 
system("plink --cow --nonfounders --allow-no-sex --lfile GenomicsBootCamp --missing-genotype - --output-missing-genotype 0 --recode --out BosTaurus")

###############################
# Scenario 2 - SNP coordinates (chromosome and position) are missing from the final report - common occurrentce
###############################
# Fam file
finalReport %>%
  distinct(`Sample Name`) %>%
  mutate(FID = "BTAU", sire = 0, dam = 0, sex = 0, phenotype = -9) %>%
  relocate(`Sample Name`, .after = FID) %>%
  write_delim("GenomicsBootCamp_annon.fam", col_names = F)

# Lgen file
finalReport %>%
  mutate(FID = "BTAU") %>%
  select(FID, `Sample Name`, `SNP Name`, `Allele1 - AB`, `Allele2 - AB`) %>%
  write_delim("GenomicsBootCamp_annon.lgen", col_names = F)

# Map file - chr and bpPosition not available - tmp values for now
finalReport %>%
  distinct(`SNP Name`) %>%
  mutate(chr = 0, morgan = 0, bpPosition = 0) %>%
  relocate(`SNP Name`, .after = chr) %>%
  write_delim("GenomicsBootCamp_annon.map", col_names = F)

# Change to ped file with PLINK
system("plink --cow --nonfounders --allow-no-sex --lfile GenomicsBootCamp_annon --missing-genotype - --output-missing-genotype 0 --recode --out BosTaurus_annon")

# Proceed with updating map files, as described in the "Update genomic map positions with PLINK"
#   on the Genomics Boot Camp YouTube channel

