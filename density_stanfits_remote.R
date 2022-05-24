library(ggplot2)
library(dplyr)
library(cmdstanr)

library(tidyverse)
library(cmdstanr)

dens_mod1 <- cmdstan_model('~/GitHub/paretotesting/pareto_bygrp_newpriors_noLL.stan')
dens_mod2 <- cmdstan_model('~/GitHub/paretotesting/pareto2_bygrp_newpriors_noLL.stan')
dens_mod3 <- cmdstan_model('~/GitHub/paretotesting/pareto3_bygrp_newpriors_noLL.stan')
# They compile!!!

# load the data to test it on real data
load('~/GitHub/forestscalingworkflow/data/rawdataobj1995.RData')

# Thin down the data to a manageable amount for testing.
dat <- alltreedat[[3]] %>%
  filter(!is.na(fg)) %>%
  group_by(fg) %>%
  sample_n(5000)

density_data_dump <- with(dat, list(N = nrow(dat), M = 5, x = dbh_corr, y = production, x_min = 1, x_max = 286, fg = as.numeric(factor(fg))))

### ONE PART

dens_fit1 <- dens_mod1$sample(
  data = density_data_dump,
  seed = 1,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 2000,
  iter_sampling = 1000
)

dens_fit1$save_object('/90daydata/shared/qdr/paretotest/dens_fit1.rds')

summ <- dens_fit1$summary(variables = c('log_alpha_mean', 'alpha_fg', 'sigma_alpha'))
 
saveRDS(summ, '/90daydata/shared/qdr/paretotest/dens_fit1_summ.rds')

### TWO PART

dens_fit2 <- dens_mod2$sample(
  data = density_data_dump,
  seed = 222,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 2000,
  iter_sampling = 1000
)

dens_fit2$save_object('/90daydata/shared/qdr/paretotest/dens_fit2.rds')

summ2 <- dens_fit2$summary(variables = c('log_alpha_low_mean', 'alpha_low_fg', 'sigma_alpha_low', 'log_alpha_high_mean', 'alpha_high_fg', 'sigma_alpha_high', 'tau_mean', 'tau_fg', 'sigma_tau'))

saveRDS(summ2, '/90daydata/shared/qdr/paretotest/dens_fit2_summ.rds')

### THREE PART

dens_fit3 <- dens_mod3$sample(
  data = density_data_dump,
  seed = 555,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 2000,
  iter_sampling = 1000
)

dens_fit3$save_object('/90daydata/shared/qdr/paretotest/dens_fit3.rds')

summ3 <- dens_fit3$summary(variables = c('log_alpha_low_mean', 'alpha_low_fg', 'log_alpha_mid_mean', 'alpha_mid_fg', 'sigma_alpha_low', 'sigma_alpha_mid', 'log_alpha_high_mean', 'alpha_high_fg', 'sigma_alpha_high', 'tau_low_mean', 'tau_low_fg', 'sigma_tau_low', 'tau_high_mean', 'tau_high_fg', 'sigma_tau_high'))

saveRDS(summ3, '/90daydata/shared/qdr/paretotest/dens_fit3_summ.rds')
