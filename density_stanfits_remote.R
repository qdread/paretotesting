library(tidyverse)
library(cmdstanr)

mod <- Sys.getenv('mod')

# Load the actual 1995 data.
load('~/GitHub/forestscalingworkflow/data/rawdataobj1995.RData')

# Thin down the data to a manageable amount for testing.
set.seed(22525)
dat <- alltreedat[[3]] %>%
  filter(!is.na(fg)) %>%
  group_by(fg) %>%
  sample_n(5000)

density_data_dump <- with(dat, list(N = nrow(dat), M = 5, x = dbh_corr, y = production, x_min = 1, x_max = 286, fg = as.numeric(factor(fg))))

### ONE PART

if (mod == '1') {
  
  dens_mod <- cmdstan_model('~/GitHub/paretotesting/pareto_bygrp_newpriors_noLL.stan')
  pars_to_save <- c('log_alpha_mean', 'alpha_fg', 'sigma_alpha')  
  
  dens_fit <- dens_mod$sample(
    data = density_data_dump,
    seed = 1,
    chains = 4,
    parallel_chains = 4,
    iter_warmup = 2000,
    iter_sampling = 1000
  )
  
}

### TWO PART

if (mod == '2') {
  
  dens_mod <- cmdstan_model('~/GitHub/paretotesting/pareto2_bygrp_newpriors_noLL.stan')
  pars_to_save <- c('log_alpha_low_mean', 'alpha_low_fg', 'sigma_alpha_low', 'log_alpha_high_mean', 'alpha_high_fg', 'sigma_alpha_high', 'tau_mean', 'tau_fg', 'sigma_tau')
  
  dens_fit <- dens_mod$sample(
    data = density_data_dump,
    seed = 222,
    chains = 4,
    parallel_chains = 4,
    iter_warmup = 2000,
    iter_sampling = 1000
  )
  
}

### THREE PART

if (mod == '3') {
  
  dens_mod <- cmdstan_model('~/GitHub/paretotesting/pareto3_bygrp_newpriors_noLL.stan')
  pars_to_save <- c('log_alpha_low_mean', 'alpha_low_fg', 'log_alpha_mid_mean', 'alpha_mid_fg', 'sigma_alpha_low', 'sigma_alpha_mid', 'log_alpha_high_mean', 'alpha_high_fg', 'sigma_alpha_high', 'tau_low_mean', 'tau_low_fg', 'sigma_tau_low', 'tau_high_mean', 'tau_high_fg', 'sigma_tau_high')  
  
  dens_fit <- dens_mod$sample(
    data = density_data_dump,
    seed = 555,
    chains = 4,
    parallel_chains = 4,
    iter_warmup = 2000,
    iter_sampling = 1000
  )
  
}

dens_fit$save_object(paste0('/90daydata/shared/qdr/paretotest/dens_fit', mod, '.rds'))
summ <- dens_fit1$summary(variables = pars_to_save)
saveRDS(summ, paste0('/90daydata/shared/qdr/paretotest/dens_fit', mod, '_summ.rds'))
