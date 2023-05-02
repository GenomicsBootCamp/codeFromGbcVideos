#########################
# Change between TOP and FORWARD allele coding
#########################

# Clear workspace
rm(list = ls())
# Set working directory
setwd("c:/analysis/2020_GenomicsBootCamp_Demo/2023/topForwardSwitch/")
#load packages
library(tidyverse)

###
# Merge TOP and FOROWARD data sets >>> Error message
###
system("plink --cow --bfile BosTaurus_Forward_chr1 --bmerge BosTaurus_Top_chr1 --recode --out BosTaurus_merged")

###
# Create file for allele recording and recode on of the files
###
# SNPchiMp website: https://webserver.ibba.cnr.it/SNPchimp/index.php/download
# Note: Manual edits to column names in SNPchiMp text file - cleaner code.
#
# read in SNP chiMp and separate alleles to columns
snpChimp <- read_delim("SNPchimp_result_4007536756.csv", delim = ",") %>% 
  separate(Alleles.A.B.FORWARD, c("Allele1_FORWARD", "Allele2_FORWARD"), remove = F) %>% 
  separate(Alleles.A.B.TOP, c("Allele1_TOP", "Allele2_TOP"), remove = F)

# create input file for "--update-alleles"
# Description on the PLINK website: https://www.cog-genomics.org/plink/1.9/data#update_map
# --update-alleles updates variant allele codes. Its input should have the following five fields:
#   
# Variant ID
# One of the old allele codes
# The other old allele code
# New code for the first named allele
# New code for the second named allele

snpChimp %>% 
  select(SNPname, Allele1_TOP, Allele2_TOP, Allele1_FORWARD, Allele2_FORWARD) %>% 
  write_delim(., "alleleUpdata_Top2Forward.txt", col_names = F, delim = " ")

# In this example we change from TOP to FORWARD
#   i.e. the "old" allele codes are TOP, the "new" allele codes are FORWARD
#   If your goal is to change from FORWARD to TOP, just flip the entire process, 
#   including the follow up update files in PLINK


###
# Update alleles in the TOP coded file
###
system(str_c("plink --cow --bfile BosTaurus_Top_chr1 --update-alleles alleleUpdata_Top2Forward.txt ",
             " --make-bed --out BosTaurus_Top2Forward_chr1"))

###
# Merge again the original FORWARD and the recoded-FORWARD file >>> Success!
###
system("plink --cow --bfile BosTaurus_Forward_chr1 --bmerge BosTaurus_Top2Forward_chr1 --recode --out BosTaurus_merged")









