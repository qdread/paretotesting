# Testing new diameter model
# Do not use recruits

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

diam_loglin_fixef_fit <- brm(
  bf(
    log(diam_growth_rate) ~ alpha + exp(beta) * log(dbh_corr),
    alpha ~ 0 + fg,
    beta ~ 0 + fg,
    nl = TRUE
  ),
  data = diam_data, family = gaussian(link = 'identity'),
  prior = c(
    prior(normal(0, 2), nlpar = alpha),
    prior(normal(0, 2), nlpar = beta)
  ),
  chains = 4, iter = 3000, warmup = 2000, seed = 27704,
  file = '~/temp/forestlight/diam_loglin_fixef_brmfit'
)

diam_hinge_fixef_fit <- brm(
  bf(
    log(diam_growth_rate) ~ beta0 + beta1low * (log(dbh_corr) - log(x0)) + (beta1high - beta1low) * delta * log(1 + exp((log(dbh_corr) - log(x0)) / delta)),
    beta0 ~ 0 + fg,
    beta1low ~ 0 + fg,
    beta1high ~ 0 + fg,
    x0 ~ 0 + fg,
    delta ~ 1,
    nl = TRUE
  ),
  data = diam_data, family = gaussian(link = 'identity'),
  prior = c(
    prior(normal(0, 2), nlpar = beta0),
    prior(lognormal(1, 1), nlpar = beta1low, lb = 0),
    prior(lognormal(1, 1), nlpar = beta1high, lb = 0),
    prior(lognormal(1, 1), nlpar = x0, lb = 0),
    prior(exponential(10), nlpar = delta, lb = 0)
  ),
  chains = 4, iter = 3000, warmup = 2000, seed = 27603,
  file = '~/temp/forestlight/diam_hinge_fixef_brmfit'
)

# Postprocessing and plotting locally -------------------------------------

library(tidybayes)
library(ggplot2)
library(forestscaling)
library(purrr)
library(tidyr)

# Set number of bins
numbins <- 20

# Make a version of alltreedat without the unclassified trees
alltreedat_classified <- map(alltreedat, ~ filter(., !is.na(fg)))

# Bin classified trees. (log binning of density)
allyeardbh_classified <- map(alltreedat_classified[-1], ~ pull(., dbh_corr)) %>% unlist
dbhbin_allclassified <- logbin(x = allyeardbh_classified, y = NULL, n = numbins)
bin_edges <- c(dbhbin_allclassified$bin_min,dbhbin_allclassified$bin_max[numbins])

qprobs <- c(0.025, 0.25, 0.5, 0.75, 0.975)
diam_bins <- diam_data %>%
  mutate(dbh_bin = cut(dbh_corr, breaks = bin_edges, include.lowest = TRUE)) %>%
  group_by(fg, dbh_bin) %>%
  summarize(p = qprobs, q = quantile(diam_growth_rate, probs = qprobs), n = n()) %>%
  pivot_wider(names_from = p, values_from = q) %>%
  setNames(c('fg', 'dbh_bin', 'n', 'q025', 'q25', 'median', 'q75', 'q975')) %>%
  mutate(bin_midpoint = dbhbin_allclassified$bin_midpoint[as.numeric(dbh_bin)])


# Prediction grid: dbh x fg
# Limit ranges to the observed data points and bins with > 20
diam_max <- diam_bins %>%
  filter(n >= 20) %>%
  group_by(fg) %>%
  filter(bin_midpoint == max(bin_midpoint))

pred_dat <- diam_max %>%
  group_by(fg) %>%
  group_modify(~ data.frame(dbh_corr = exp(seq(log(1), log(.$bin_midpoint), length.out = 101))))

# Get epred values
diamloglin_pred <- pred_dat %>%
  add_epred_draws(diam_loglin_fixef_fit) %>%
  mutate(.epred = exp(.epred))

diamhinge_pred <- pred_dat %>%
  add_epred_draws(diam_hinge_fixef_fit) %>%
  mutate(.epred = exp(.epred))

### LOGLIN
### Quick diag. plot
ggplot(diam_bins %>% filter(n >= 20), aes(x=bin_midpoint, y = median)) +
  stat_lineribbon(aes(y = .epred, x = dbh_corr), data = diamloglin_pred, size = 0.5) +
  geom_pointrange(aes(ymin = q25, ymax = q75), color = 'gray40') +
  facet_wrap(~ fg) + scale_x_log10(name = 'diameter (cm)') + scale_y_log10(name = 'diameter growth (cm/y)') +
  scale_fill_brewer(palette = 'Blues') +
  theme_bw() +
  theme(legend.position = c(0.8, 0.2), strip.background = element_blank())

### Plot with all data points
ggplot(diam_data, aes(x = dbh_corr, y = diam_growth_rate)) +
  geom_point(size = 0.5, alpha = 0.1) +
  stat_lineribbon(aes(y = .epred, x = dbh_corr), data = diamloglin_pred, color = 'blue4', size = 0.5) +
  facet_wrap(~ fg) + scale_x_log10(name = 'diameter (cm)') + scale_y_log10(name = 'diameter growth (cm/y)') +
  scale_fill_brewer(palette = 'Blues') +
  theme_bw() +
  theme(legend.position = c(0.8, 0.2), strip.background = element_blank())

### HINGE
### Quick diag. plot
ggplot(diam_bins %>% filter(n >= 20), aes(x=bin_midpoint, y = median)) +
  stat_lineribbon(aes(y = .epred, x = dbh_corr), data = diamhinge_pred, size = 0.5) +
  geom_pointrange(aes(ymin = q25, ymax = q75), color = 'gray40') +
  facet_wrap(~ fg) + scale_x_log10(name = 'diameter (cm)') + scale_y_log10(name = 'diameter growth (cm/y)') +
  scale_fill_brewer(palette = 'Blues') +
  theme_bw() +
  theme(legend.position = c(0.8, 0.2), strip.background = element_blank())

### Plot with all data points
ggplot(diam_data, aes(x = dbh_corr, y = diam_growth_rate)) +
  geom_point(size = 0.5, alpha = 0.1) +
  stat_lineribbon(aes(y = .epred, x = dbh_corr), data = diamhinge_pred, color = 'blue4', size = 0.5) +
  facet_wrap(~ fg) + scale_x_log10(name = 'diameter (cm)') + scale_y_log10(name = 'diameter growth (cm/y)') +
  scale_fill_brewer(palette = 'Blues') +
  theme_bw() +
  theme(legend.position = c(0.8, 0.2), strip.background = element_blank())
