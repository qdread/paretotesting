library(Pareto)
library(ggplot2)
library(dplyr)
library(forestscaling) # For the homebrewed logbin() function.

theme_set(theme_classic())

set.seed(111)
x <- rPiecewisePareto(1e6, t = c(1, 5, 15), alpha = c(1, 3, 5))

xbin <- logbin(x, n = 20)

ggplot(xbin, aes(x=bin_midpoint,y=bin_value)) + geom_point() + scale_x_log10() + scale_y_log10()


#### 
# Generate example data

set.seed(222)
alpha_mean <- 2
alpha_group <- rnorm(3, mean = alpha_mean)

dat <- data.frame(group = 1:3, x_min = 1, alpha = alpha_group) %>%
  group_by(group, x_min, alpha) %>%
  summarize(x = rPareto(10000, t = x_min, alpha = alpha))

# What does it look like
ggplot(dat, aes(x = x, group = factor(group), fill = factor(group))) +
  geom_histogram(position = 'dodge') +
  scale_x_log10() + scale_y_log10(expand = c(0,0))




dat_binned <- dat %>% group_by(group) %>%
  summarize(logbin(x = y, n = 20))

ggplot(dat_binned, aes(x=bin_midpoint,y=bin_value,color=factor(group))) + geom_point() + scale_x_log10() + scale_y_log10()


####

y <- rPareto(30000, t = 1, alpha = rep(c(1, 3, 5), each = 10000))

dat <- data.frame(group = rep(1:3, each = 10000), y = y)

dat_binned <- dat %>% group_by(group) %>%
  summarize(logbin(x = y, n = 20))

ggplot(dat_binned, aes(x=bin_midpoint,y=bin_value,color=factor(group))) + geom_point() + scale_x_log10() + scale_y_log10()