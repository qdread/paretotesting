data {
	int<lower=0> N;
	int<lower=0> M; // number of groups
	vector<lower=0>[N] x;
	int<lower=1,upper=M> fg[N];	// Mapping to groups 1-M
    real<lower=0> x_min;
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

generated quantities {
	vector[N] log_lik; // Log-likelihood for getting info criteria later
	
	for (i in 1:N) {
		log_lik[i] = pareto_lpdf(x[i] | x_min, exp(log_alpha_mean + alpha_fg[fg[i]]));
	}
}
