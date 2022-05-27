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
	real log_mu_alpha;
	vector[M] log_alpha_fg;			// Slope of each group
	real<lower=0> sigma_alpha;		// SD of slopes
}

model {
	// Prior: Pareto density
	log_mu_alpha ~ normal(1, 1);
	log_alpha_fg ~ normal(log_mu_alpha, sigma_alpha);
	sigma_alpha ~ exponential(1);
	
	// Likelihood: Pareto density
	x ~ pareto(x_min, exp(log_alpha_fg[fg]));

}

/*
generated quantities {
	vector[N] log_lik; // Log-likelihood for getting info criteria later
	
	for (i in 1:N) {
		log_lik[i] = pareto_lpdf(x[i] | x_min, exp(log_alpha_fg[fg[i]]));
	}
}
*/