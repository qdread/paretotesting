// Log-linear regression to model yearly diameter growth as a function of diameter
// Model includes exponential term to allow growth to decrease or flatten off at larger diameters
// QDR 28 June 2022
			
data {
	int<lower=0> N;				      // Number of trees
	int<lower=0> M;				      // Number of FGs
	vector<lower=0>[N] x;		    // x variable (e.g. DBH)
	vector<lower=0>[N] y;		    // Diameter growth 1990-1995
	int<lower=1,upper=M> fg[N];	// Mapping to functional groups 1-M
}

transformed data {
	vector[N] log10_x;
	log10_x = log10(x);
	vector[N] log10_y;
	log10_y = log10(y);
}

parameters {
	vector[M] alpha;					// Deviation of each FG from mean intercept
	vector[M] beta;					  // Deviation of each FG from mean slope
	vector[M] gamma;					// Deviation of each FG from mean exponential coefficient
	real sigma;							  // Residual standard deviation
}

model {
	// Priors
	alpha ~ normal(0, 2);
	beta ~ normal(0, 2);
	gamma ~ normal(0, 2);
	sigma ~ gamma(1, 1);
		
	// Likelihood
	log10_y ~ normal(alpha[fg] + beta[fg] .* log10_x .* exp(gamma[fg] .* log10_x), sigma);

}
