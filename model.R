library("rstan") 
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

givedirectly <- list(donation_size=100000,
                    discount_rate=0.04,
                    value_of_ln_consumption = 1.44
                    )

fit <- stan(file = 'givedirectly.stan', data = givedirectly)

print(fit)
plot(fit)
