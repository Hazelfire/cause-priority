/* Beta distribution with exponential priors */
data {
  int data_size;
  real y[data_size];
  real alpha_prior_mu;
  real beta_prior_mu;
}

parameters {
  real a;
  real b;
}

model {
  a ~ gamma(2, alpha_prior_mu);
  b ~ gamma(2, beta_prior_mu);
  y ~ beta(b, a);
}
