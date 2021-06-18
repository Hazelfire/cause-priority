library("rstan") 
library(tidyverse)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

N <- 10000

model <- list(donation_size=100000,
              discount_rate=0.04,
              value_of_ln_consumption = 1.44,
              value_of_under_5_death_averted = 117,
              value_of_over_5_death_averted = 83
              )

prior_predictive_beta <- function(params) {
  prior_alpha = rgamma(N, shape=2,scale = params$alpha_prior_scale)
  prior_beta = rgamma(N,shape = 2, scale = params$beta_prior_scale)
  return(rbeta(N, shape1=prior_alpha + 1, shape2=prior_beta + 1))
}

prior_predictive_normal_log <- function(params) {
  prior_mu = rlnorm(N, meanlog=params$mu_prior_mu,sdlog=params$mu_prior_sigma)
  prior_sigma = rexp(N,rate=1/params$sigma_prior_mu)
  return(rnorm(N, mean=prior_mu, sd=prior_sigma))
}

prior_predictive_poisson <- function(params) {
  prior_mu = rexp(N, rate=1/params$mu_prior_mu)
  return(rpois(N, lambda=prior_mu))
}

beta_distr <- function(alpha_scale, beta_scale) {
  return(
    list(data_size = 0,
         y = c(),
         alpha_prior_scale = alpha_scale,
         beta_prior_scale = beta_scale
         ))
}

normal_distr <- function(mu_prior_mu, mu_prior_sigma, sigma_prior_mu) {
  return(list(data_size = 0,
       y = c(),
       mu_prior_mu = mu_prior_mu,
       mu_prior_sigma = mu_prior_sigma,
       sigma_prior_mu = sigma_prior_mu
       ))
}

poisson_distr <- function(mu_prior_mu) {
  return(
    list(data_size = 0,
         y = c(),
         mu_prior_mu = 4
         )
    )
}

proportion_to_program <- beta_distr(8, 2)
size_of_transfer <- normal_distr(log(1000), 1, 100)
household_size <- poisson_distr(4)
transfers_invested <- beta_distr(8, 2)
roi <- beta_distr(1, 10)
# I need to work out 
consumption_per_capita <- normal_distr(log(500), 1, 100)
#fit <- stan(file = 'models/beta.stan', data = beta_model)

#print(fit)
#plot(fit)

prior_predictive = prior_predictive_beta(transfers_invested)
df = tibble(prior_predictive = prior_predictive)
print(df)
ggplot(df, aes(x=prior_predictive)) + geom_histogram(bins=30)
