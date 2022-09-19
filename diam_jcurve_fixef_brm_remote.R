# Testing new diameter model

library(dplyr)
library(readr)
library(brms)


options(mc.cores = 4, brms.backend = 'cmdstanr', brms.file_refit = 'on_change')

# Load data
load('~/GitHub/old_projects/forestscalingworkflow/data/rawdataobj1995.RData')

diam_data <- alltreedat[[3]] %>%
  filter(!is.na(fg), !recruit) %>%
  select(fg, dbh_corr, diam_growth_rate) %>%
  mutate(fg = paste0('fg', fg))

diam_jcurve_fixef_fit <- brm(
  bf(
    log(diam_growth_rate) ~ alpha + exp(beta) * log(dbh_corr) * exp(gamma * log(dbh_corr)),
    alpha ~ 0 + fg,
    beta ~ 0 + fg,
    gamma ~ 0 + fg,
    nl = TRUE
  ),
  data = diam_data, family = gaussian(link = 'identity'),
  prior = c(
    prior(normal(0, 2), nlpar = alpha),
    prior(normal(0, 2), nlpar = beta),
    prior(normal(0, 2), nlpar = gamma)
  ),
  chains = 4, iter = 3000, warmup = 2000, seed = 27704,
  file = '~/temp/forestlight/diam_jcurve_fixef_brmfit'
)

# Postprocessing and plotting locally -------------------------------------

library(tidybayes)
library(ggplot2)
library(forestscaling)
library(purrr)

# Set number of bins
numbins <- 20

# Make a version of alltreedat without the unclassified trees
alltreedat_classified <- map(alltreedat, ~ filter(., !is.na(fg)))

# Bin classified trees. (log binning of density)
allyeardbh_classified <- map(alltreedat_classified[-1], ~ pull(., dbh_corr)) %>% unlist
dbhbin_allclassified <- logbin(x = allyeardbh_classified, y = NULL, n = numbins)

diam_bins <- diam_data %>%
  group_by(fg) %>%
  group_modify(~ cloudbin_across_years(dat_classes = .$dbh_corr, dat_values = .$diam_growth_rate, edges = dbhbin_allclassified, n_census = 1))

# Prediction grid: dbh x fg
# Limit ranges to the observed data points
diam_max <- diam_bins %>%
  filter(!is.na(mean)) %>%
  group_by(fg) %>%
  filter(bin_midpoint == max(bin_midpoint))

pred_dat <- diam_max %>%
  group_by(fg) %>%
  group_modify(~ data.frame(dbh_corr = exp(seq(log(1), log(.$bin_midpoint), length.out = 50))))

# Get epred values
jcurve_pred <- pred_dat %>%
  add_epred_draws(diam_jcurve_fixef_fit) %>%
  mutate(.epred = exp(.epred))

ggplot(diam_bins, aes(x = bin_midpoint, y = median, ymin = q25, ymax = q75)) +
  geom_pointrange() + facet_wrap(~fg) + scale_x_log10() + scale_y_log10()


### Quick diag. plot
ggplot(diam_bins, aes(x=bin_midpoint, y = median)) +
  stat_lineribbon(aes(y = .epred, x = dbh_corr), data = jcurve_pred) +
  geom_pointrange(aes(ymin = q25, ymax = q75), color = 'gray40') +
  facet_wrap(~ fg) + scale_x_log10(name = 'diameter (cm)') + scale_y_log10() + 
  scale_fill_brewer(palette = 'Blues') + 
  theme_bw() +
  theme(legend.position = c(0.8, 0.2), strip.background = element_blank())

