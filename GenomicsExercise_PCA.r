
#clean workspace
rm(list = ls())
#set working directory
setwd("YourDirectoryGoesHere")

###
# TASK: create a joint PCA plot for the Valdostana and Massai goat data
###

# Hint: You can make this exercise easier by specifying the necessary steps 
#       OR you just leave the one-liner task description for a larger challenge 


# Reference papers:
#     Colli et al. (2018) https://gsejournal.biomedcentral.com/articles/10.1186/s12711-018-0422-x
#     Bertolini et al. (2018) https://gsejournal.biomedcentral.com/articles/10.1186/s12711-018-0421-y 
# Full data source on datadryad.org:
#     https://datadryad.org/stash/dataset/doi:10.5061/dryad.v8g21pt
# Data for the two breeds (Valdostana and Massai goats) in this exercise:
#     https://github.com/GenomicsBootCamp/codeFromGbcVideos/tree/main/data/excerciseRun


###
# 1. Merge the Valdostana and Massai data sets
###

# Detailed video on this topic on Genomics Boot Camp YouTube
# Merging genotype data with PLINK:  https://youtu.be/9_w93AU0Fdg


# Note: There could be a large variation in the format and quality of input data sets
#       In this case we already prepared PLINK files, which is the best-case scenario
#       In reality you might spend some time until you get to this point
# Note2: In this example the merge does not give warnings or errors
#        In reality, especially when merging data from different sources, 
#         you can/will encounter various obstacles you need to solve.

# merge the two sets 
system("plink --bfile ValdostanaGoats --bmerge MaasaiGoats --chr-set 29 --make-bed --out mergedGoats")


###
# 2. Do a quality control
###

# Detailed video on this topic on Genomics Boot Camp YouTube
# Genomics in practice - SNP data quality control with PLINK: https://youtu.be/QR80Y0Xhrg4


# Note: The number of SNPs (and individuals) might differ slightly depending on the chosen limits
# Note2: Filtering for --hwe in a multi breed data set should not be done (incorrect SNP deletions)

# perform quality control
# --mind 0.1 removes individuals with more than 10% missing genotypes 
# --geno 0.1 removes SNPs with more than 10% missing genotypes
# --maf 0.05 removes SNPs with minor allele frequency of less than 5%
# --autosome removes unplaced, sex chromosome and mitochondrial SNPs (keeps only autosomal SNPs)
system("plink --bfile mergedGoats --mind 0.1 --geno 0.1 --maf 0.05 --chr-set 29 --make-bed --out afterQC")


###
# 3. Perform the principal component analysis
###

# Detailed video on this topic on Genomics Boot Camp YouTube
# Simple PCA analysis with PLINK: https://youtu.be/vos6VeuNcaM

# Note: There are multiple options how to create a PCA plot (distance matrix type, software)
#        with possible small differences in the final picture
# Note2: The --pca option of PLINK is demonstrated here, but other equivalent solutions are possible

system("plink --bfile afterQC --chr-set 29 --autosome --pca --out pcaResult")

###
# 4. Visualize PCA results
###

# Detailed video on this topic on Genomics Boot Camp YouTube
# towards the end of the "Simple PCA analysis with PLINK" video: https://youtu.be/vos6VeuNcaM

# Note: Also different options here - at minimum should be an X-Y plot with a legend

# load required package
library(tidyverse)

# read in result files
eigenValues <- read_delim("pcaResult.eigenval", delim = " ", col_names = F)
eigenVectors <- read_delim("pcaResult.eigenvec", delim = " ", col_names = F)

## Proportion of variation captured by each vector
eigen_percent <- round((eigenValues / (sum(eigenValues))*100), 2)

# PCA plot
ggplot(data = eigenVectors) +
  geom_point(mapping = aes(x = X3, y = X4, color = X1, shape = X1), size = 3, show.legend = TRUE ) +
  geom_hline(yintercept = 0, linetype="dotted") +
  geom_vline(xintercept = 0, linetype="dotted") +
  labs(title = "PCA of the Valdostana and Massai goat populations",
       x = paste0("Principal component 1 (",eigen_percent[1,1]," %)"),
       y = paste0("Principal component 2 (",eigen_percent[2,1]," %)"),
       colour = "Goat breeds", shape = "Goat breeds") +
  theme_minimal()

