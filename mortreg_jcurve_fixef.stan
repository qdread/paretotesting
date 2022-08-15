// Logistic regression to model mortality as a function of diameter
// Model includes exponential term to allow mortality to increase at large diameters
// Functional groups are fit as fixed effects
// Exponentiate the alpha and beta parameters to ensure that alpha is always positive and beta is negative
// QDR 15 August 2022
			
data {
	int<lower=0> N;				      // Number of trees
	int<lower=0> M;				      // Number of FGs
	vector<lower=0>[N] x;		    // x variable: Light per area or DBH
	int<lower=0,upper=1> y[N];	// Mortality 1990-1995
	int<lower=1,upper=M> fg[N];	// Mapping to functional groups 1-M
}

transformed data {
	vector[N] log10_x;
	log10_x = log10(x);
}

parameters {
	vector[M] alpha;					// Intercepts for each FG
	vector[M] beta;					  // Log-linear slope for each FG
	vector[M] gamma;					// Coefficient of exponential increase at large sizes for each FG

}

model {
	// Priors
	alpha ~ normal(0, 2);
	beta ~ normal(0, 2);
	gamma ~ normal(0, 2);

	// Likelihood
	y ~ bernoulli_logit(exp(alpha[fg]) + -exp(beta[fg]) .* log10_x .* exp(gamma[fg] .* log10_x));

}
