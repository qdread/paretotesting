data {
	int<lower=0> N;
	int<lower=0> M; // number of groups
	vector<lower=0>[N] x;
	int<lower=1,upper=M> fg[N];	// Mapping to groups 1-M
    real<lower=0> x_min;
}

parameters {
	// Pareto density
	real<lower=0, upper=5> alpha_mean;
	vector[M] alpha_fg;					// Deviation of each group from mean intercept
	real<lower=0,upper=10> sigma_alpha;	// Variation in intercepts
	
}

model {
	// Prior: Pareto density
	alpha_mean ~ lognormal(1, 1) T[0, 5];
	alpha_fg ~ normal(0, sigma_alpha);
	sigma_alpha ~ exponential(1);
	
	// Likelihood: Pareto density
	x ~ pareto(x_min, alpha_mean + alpha_fg[fg]);

}

generated quantities {
	vector[N] log_lik; // Log-likelihood for getting info criteria later
	
	for (i in 1:N) {
		log_lik[i] = pareto_lpdf(x[i] | x_min, alpha_mean + alpha_fg[fg[i]]);
	}
}
