library(Pareto)
library(ggplot2)
library(dplyr)
library(cmdstanr)

# set.seed(222)
# alpha_mean <- 2
# alpha_group <- rnorm(3, mean = alpha_mean, sd = 1.5)

# dat <- data.frame(group = 1:3, x_min = 1, alpha = alpha_group) %>%
  # group_by(group, x_min, alpha) %>%
  # summarize(x = rPareto(10000, t = x_min, alpha = alpha))

# # What does it look like
# ggplot(dat, aes(x = x, group = factor(group), fill = factor(group))) +
  # geom_histogram(position = 'dodge') +
  # scale_x_log10() + scale_y_log10(expand = c(0,0))

# mod <- cmdstan_model('pareto_bygrp_newpriors_noLL.stan')

# data_dump <- with(dat, list(N = nrow(dat), M = 3, x = x, fg = group, x_min = 1))

# fit <- mod$sample(
  # data = data_dump,
  # seed = 1,
  # chains = 3,
  # parallel_chains = 3,
  # iter_warmup = 1000,
  # iter_sampling = 500
# )

# fit$save_object('/90daydata/shared/qdr/paretotest/paretofit1.rds')

# summ <- fit$summary(variables = c('log_alpha_mean', 'alpha_fg', 'sigma_alpha'))

# saveRDS(summ, '/90daydata/shared/qdr/paretotest/summfit1.rds')

# # Two part ----------------------------------------------------------------

# set.seed(22222)
# alpha_low_mean <- 1
# alpha_high_mean <- 3
# tau_mean <- 15

# alpha_low_group <- rnorm(3, mean = alpha_low_mean, sd = 0.5)
# alpha_high_group <- rnorm(3, mean = alpha_high_mean, sd = 1.5)
# tau_group <- rnorm(3, mean = tau_mean, sd = 5)

# dat2 <- data.frame(group = 1:3, x_min = 1, alpha_low = alpha_low_group, alpha_high = alpha_high_group, tau = tau_group) %>%
  # group_by_all() %>%
  # summarize(x = rPiecewisePareto(10000, t = c(x_min, tau), alpha = c(alpha_low, alpha_high)))

# # What does it look like
# ggplot(dat2, aes(x = x, group = factor(group), fill = factor(group))) +
  # geom_histogram(position = 'dodge') +
  # scale_x_log10() + scale_y_log10(expand = c(0,0))

# mod2 <- cmdstan_model('pareto2_bygrp_newpriors_noLL.stan')

# data_dump2 <- with(dat2, list(N = nrow(dat2), M = 3, x = x, fg = group, x_min = 1, x_max = ceiling(max(x))))

# fit2 <- mod2$sample(
  # data = data_dump2,
  # seed = 1,
  # chains = 3,
  # parallel_chains = 3,
  # iter_warmup = 1000,
  # iter_sampling = 500
# )

# fit2$save_object('/90daydata/shared/qdr/paretotest/paretofit2.rds')

# summ2 <- fit2$summary(variables = c('log_alpha_low_mean', 'alpha_low_fg', 'sigma_alpha_low', 'log_alpha_high_mean', 'alpha_high_fg', 'sigma_alpha_high', 'tau_mean', 'tau_fg', 'sigma_tau'))

# saveRDS(summ2, '/90daydata/shared/qdr/paretotest/summfit2.rds')

# Three part --------------------------------------------------------------

set.seed(2232)
alpha_low_mean <- 1
alpha_mid_mean <- 3
alpha_high_mean <- 5
tau_low_mean <- 5
tau_high_mean <- 30

alpha_low_group <- rnorm(3, mean = alpha_low_mean, sd = 0.5)
alpha_mid_group <- rnorm(3, mean = alpha_mid_mean, sd = 1.5)
alpha_high_group <- rnorm(3, mean = alpha_high_mean, sd = 1.5)
tau_low_group <- rnorm(3, mean = tau_low_mean, sd = 2)
tau_high_group <- rnorm(3, mean = tau_high_mean, sd = 10)

dat3 <- data.frame(group = 1:3, x_min = 1, alpha_low = alpha_low_group, alpha_mid = alpha_mid_group, alpha_high = alpha_high_group, tau_low = tau_low_group, tau_high = tau_high_group) %>%
  group_by_all() %>%
  summarize(x = rPiecewisePareto(10000, t = c(x_min, tau_low, tau_high), alpha = c(alpha_low, alpha_mid, alpha_high)))

# What does it look like
ggplot(dat3, aes(x = x, group = factor(group), fill = factor(group))) +
  geom_histogram(position = 'dodge') +
  scale_x_log10() + scale_y_log10(expand = c(0,0))

mod3 <- cmdstan_model('pareto3_bygrp_newpriors_noLL.stan')

data_dump3 <- with(dat3, list(N = nrow(dat3), M = 3, x = x, fg = group, x_min = 1, x_max = ceiling(max(x))))

fit3 <- mod3$sample(
  data = data_dump3,
  seed = 555,
  chains = 4,
  parallel_chains = 4,
  iter_warmup = 2000,
  iter_sampling = 1000
)

fit3$save_object('/90daydata/shared/qdr/paretotest/paretofit3.rds')

summ3 <- fit3$summary(variables = c('log_alpha_low_mean', 'alpha_low_fg', 'log_alpha_mid_mean', 'alpha_mid_fg', 'sigma_alpha_low', 'sigma_alpha_mid', 'log_alpha_high_mean', 'alpha_high_fg', 'sigma_alpha_high', 'tau_low_mean', 'tau_low_fg', 'sigma_tau_low', 'tau_high_mean', 'tau_high_fg', 'sigma_tau_high'))

saveRDS(summ3, '/90daydata/shared/qdr/paretotest/summfit3.rds')