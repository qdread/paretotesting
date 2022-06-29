# Testing new diameter model

library(dplyr)
library(readr)
library(tidybayes)
library(cmdstanr)

dj_mod <- cmdstan_model('diamreg_jcurve.stan')

# Load data
load('~/GitHub/old_projects/forestscalingworkflow/data/rawdataobj1995.RData')

diam_data <- alltreedat[[3]] %>%
  filter(!is.na(fg)) %>%
  select(fg, dbh_corr, diam_growth_rate)

diam_data_dump <- with(diam_data, list(N = nrow(diam_data), M = 5, x = dbh_corr, y = diam_growth_rate, fg = as.integer(fg)))

# Sample model
djcurve_fit <- dj_mod$sample(
  data = diam_data_dump,
  seed = 629,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 6000,
  iter_sampling = 1000
)

# Save object
djcurve_fit$save_object('~/temp/forestlight/diam_jcurve_fit.rds')

# Check model summary
djcurve_summ <- djcurve_fit$summary() 