
#clean workspace
rm(list = ls())

# based on the response to a Stack Overflow thread by Cybernetic
# answered Dec 8, 2018, edited Apr 18, 2021
# https://stackoverflow.com/questions/6957549/overlaying-histograms-with-ggplot2-in-r

# load required package
library(tidyverse)
library(palmerpenguins)

###
# Custom functions to visualize overlapping histograms and density plots
###

# Note: special emphasis on borders, make the resulting graphs "pop"

# Changes added by Gabor

# 1 New function argument for plot title - plotTitle -  with empty default value
#   useful if generating more histograms
#
# 2 Fixed calculation of the mean value - now works if NA is present
#
# 3 changed dot-dot notation (`..density..`)as it  was deprecated in ggplot2 3.4.0.
#   Used `after_stat(density)` instead, as suggested


plot_histogram <- function(df, feature, plotTitle = "") {
  plt <- ggplot(df, aes(x=eval(parse(text=feature)))) +
    geom_histogram(aes(y = after_stat(density)), alpha=0.7, fill="#33AADE", color="black") +
    geom_density(alpha=0.3, fill="red") +
    geom_vline(aes(xintercept=mean(eval(parse(text=feature)), na.rm = T)), color="black", linetype="dashed", size=1) +
    labs(title = plotTitle, x=feature, y = "Density") 
  print(plt)
}

plot_multi_histogram <- function(df, feature, label_column, plotTitle = "") {
  plt <- ggplot(df, aes(x=eval(parse(text=feature)), fill=eval(parse(text=label_column)))) +
    geom_histogram(alpha=0.7, position="identity", aes(y = after_stat(density)), color="black") +
    geom_density(alpha=0.7) +
    geom_vline(aes(xintercept=mean(eval(parse(text=feature)), na.rm = T)), color="black", linetype="dashed", size=1) +
    labs(title = plotTitle, x=feature, y = "Density")
  plt + guides(fill=guide_legend(title=label_column))
}


###
# Let's try it out!
###

#check the data set
penguins

# a simple histogram
plot_histogram(penguins, "body_mass_g")


# a overlaid histograms
plot_multi_histogram(penguins, "body_mass_g", "species")
ggsave("multiHistogramPenguins.png", width = 1280, height = 720, units = "px")


