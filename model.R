library("rstan") 
library(tidyverse)
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

model <- list(donation_size=100000,
                    discount_rate=0.04,
                    value_of_ln_consumption = 1.44,
                    value_of_under_5_death_averted = 117,
                    value_of_over_5_death_averted = 83
                    )
prior_predictive_beta <- function(params) {
  prior_alpha = rgamma(10000, shape=2,scale = params$alpha_prior_mu)
  prior_beta = rgamma(10000,shape = 2, scale = params$beta_prior_mu)
  return(rbeta(10000, shape1=prior_alpha + 1, shape2=prior_beta + 1))
}

prior_predictive_normal_log <- function(params) {
  prior_mu = rlnorm(10000, meanlog=params$mu_prior_mu,sdlog=params$mu_prior_sigma)
  prior_sigma = rexp(10000,rate=1/params$sigma_prior_mu)
  return(rnorm(10000, mean=prior_mu, sd=prior_sigma))
}

prior_predictive_poisson <- function(params) {
  prior_mu = rexp(10000, rate=1/params$mu_prior_mu)
  return(rpois(10000, lambda=prior_mu))
}

proportion_to_program <- 
  list(data_size = 0,
       y = c(),
       alpha_prior_mu = 8,
       beta_prior_mu = 2
       )
size_of_transfer_prior <- 
  list(data_size = 0,
       y = c(),
       mu_prior_mu = log(1000),
       mu_prior_sigma = 1,
       sigma_prior_mu = 100
       )
household_size <-
  list(data_size = 0,
       y = c(),
       mu_prior_mu = 4
       )

transfers_invested <-
  list(data_size = 0,
       y = c(),
       alpha_prior_mu = 1,
       beta_prior_mu = 10
       )
#fit <- stan(file = 'models/beta.stan', data = beta_model)

#print(fit)
#plot(fit)

prior_predictive = prior_predictive_beta(transfers_invested)
df = tibble(prior_predictive = prior_predictive)
print(df)
ggplot(df, aes(x=prior_predictive)) + geom_histogram(bins=30)
