// Logistic regression to model mortality as a function of diameter
// Model includes exponential term to allow mortality to increase at large diameters
// QDR 27 June 2022
			
data {
	int<lower=0> N;				// Number of trees
	int<lower=0> M;				// Number of FGs
	vector<lower=0>[N] x;		// x variable: Light per area or DBH
	int<lower=0,upper=1> y[N];	// Mortality 1990-1995
	int<lower=1,upper=M> fg[N];	// Mapping to functional groups 1-M
}

transformed data {
	vector[N] log10_x;
	log10_x = log10(x);
}

parameters {
	real alpha;							// Mean intercept
	vector[M] alpha_fg;					// Deviation of each FG from mean intercept
	real<lower=0> sigma_alpha;			// Variation in intercepts
	real beta;							// Mean slope
	vector[M] beta_fg;					// Deviation of each FG from mean slope
	real<lower=0> sigma_beta;			// Variation in slopes
	real gamma;							// Mean coefficient on exponential term
	vector[M] gamma_fg;					// Deviation of each FG from mean exponential coefficient
	real<lower=0> sigma_gamma;			// Variation in exponential coefficient
	
}

model {
	// Priors
	alpha ~ normal(0, 2);
	beta ~ normal(0, 5);
	gamma ~ normal(0, 2);
	alpha_fg ~ normal(alpha, sigma_alpha);
	beta_fg ~ normal(beta, sigma_beta);
	gamma_fg ~ normal(gamma, sigma_gamma);
	sigma_alpha ~ gamma(1, 1);
	sigma_beta ~ gamma(1, 1);
	sigma_gamma ~ gamma(1, 1);
		
	// Likelihood
	y ~ bernoulli_logit(alpha_fg[fg] + beta_fg[fg] .* log10_x .* exp(gamma_fg[fg] .* log10_x));

}
