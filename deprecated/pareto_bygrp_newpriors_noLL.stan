data {
	int<lower=0> N;
	int<lower=0> M;
	vector<lower=0>[N] x;
	vector<lower=0>[N] y;
  real<lower=0> x_min;
  real<lower=0> x_max;
	int<lower=1,upper=M> fg[N];	// Mapping to groups 1-M
}

parameters {
	// Pareto density
	real log_alpha_mean;
	vector[M] alpha_fg;			// Deviation of each group from mean intercept
	real<lower=0> sigma_alpha;	// Variation in intercepts
	
}

model {
	// Prior: Pareto density
	log_alpha_mean ~ normal(1, 1);
	alpha_fg ~ normal(0, sigma_alpha);
	sigma_alpha ~ exponential(1);
	
	// Likelihood: Pareto density
	x ~ pareto(x_min, exp(log_alpha_mean + alpha_fg[fg]));

}
