// Log-linear regression to model yearly diameter growth as a function of diameter
// Model includes exponential term to allow growth to decrease or flatten off at larger diameters
// QDR 28 June 2022
			
data {
	int<lower=0> N;				// Number of trees
	int<lower=0> M;				// Number of FGs
	vector<lower=0>[N] x;		// x variable (e.g. DBH)
	vector<lower=0>[N] y;		// Diameter growth 1990-1995
	int<lower=1,upper=M> fg[N];	// Mapping to functional groups 1-M
}

transformed data {
	vector[N] log10_x;
	log10_x = log10(x);
	vector[N] log10_y;
	log10_y = log10(y);
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
	real sigma;							// Residual standard deviation
}

model {
	// Priors
	alpha ~ normal(0, 2);
	beta ~ normal(0, 2);
	gamma ~ normal(0, 2);
	alpha_fg ~ normal(alpha, sigma_alpha);
	beta_fg ~ normal(beta, sigma_beta);
	gamma_fg ~ normal(gamma, sigma_gamma);
	sigma_alpha ~ gamma(1, 1);
	sigma_beta ~ gamma(1, 1);
	sigma_gamma ~ gamma(1, 1);
	sigma ~ gamma(1, 1);
		
	// Likelihood
	log10_y ~ normal(alpha_fg[fg] + beta_fg[fg] .* log10_x .* exp(gamma_fg[fg] .* log10_x), sigma);

}
