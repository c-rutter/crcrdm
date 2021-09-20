
# Natural History Method --------------------------------------------------

crcspin_simulate_natural_history = function(self, ...){

  # Inputs set to the model can be accessed with:
  #
  #self$inputs$some_date
  # inputs given directly to the function can be accessed with:
  #p = list(...)
  #p$some_parameter

  # If the user wishes to remove this behavior and hard-code the model inputs, one can always do that.
  # You should document self$inputs used by your model in your function.
  # parameters in the posterior can be accessed with:
  # self$posterior_params$risk.mean

  # This form of running the model is attractive because it removes the need to hard-code model parameters between calls.
  # Instead of passing parameters between functions, we can simply ask the model object to evaluate itself given its inputs.

  # Ultimately, the natural history function returns a population data.frame (also an adenoma data.frame, but it doesn't matter)
  results = data.frame(p.id = 1:self$inputs$pop.size,
                       risk = rnorm(n = self$inputs$pop.size, mean = self$inputs$risk.mean, sd = self$inputs$risk.sd)) %>%
    mutate(probability.event = 1-exp(-risk)) %>%
    mutate(n.events =  rbinom(n = 1:self$inputs$pop.size, size = self$inputs$trials, prob = probability.event))

  # Return an object.
  # You should avoid assigning things to the self object.
  # This object can be anything (a list, a data.frame), and will be stored in self$natural_history_results
  return(results)

}


crcspin_simulate_screening = function(self, ...) {

  population = self$natural_history_results

  # Use strategy characteristic to do something interesting:
  population$n.identified = rbinom(n = 1:nrow(population), size = population$n.events, prob = self$inputs$det.ratios[self$inputs$strategy.id])

  # Summarize information:
  summary = data.frame(total_identified = sum(population$n.identified),
                       total_events = sum(population$n.events)) %>%
    mutate(identified_per_person = total_identified/nrow(population))

  # Produce list of results with the population and a summary object.
  list(population = population, summary = summary)

}


# Creating a model object -------------------------------------------------

# Creates a CRC model object and gives it a name.
model = crcmodel$new(name = "CRCSPIN 2.1.1 - SSP")

test_that("crcmodel was created", {
  expect_true(is.crcmodel(model))
})


# Setting model inputs:
model$
  set_input(name = "pop.size", value = 1000, type = "settings")$
  set_input(name = "risk.mean",value = 0.15,type = "natural_history")$
  set_input(name = "risk.sd",value = 0.02,type = "natural_history")$
  set_input(name = "trials",value = 10,type = "natural_history")$
  set_input(name = "strategy.id",value = 1,type = "screening")$
  set_input(name = "some_date",value = "2020-01-01",type = "screening")$
  set_input(name = "det.ratios",value = seq.default(from = 0, to = 1, length.out = 101),type = "screening")

test_that("input was created", {
  expect_true(model$inputs$pop.size == 1000)
})

## Testing set posterior:


# Set posterior -----------------------------------------------------------

# Loading multiple posterior data.frames:
posterior.a = data.frame(
  risk.mean = rtruncnorm(n = 1000, mean = 0, sd = 0.5, a = 0,b = 3),
  risk.sd = rtruncnorm(n = 1000, mean = 1, sd = 2, a = 0,b = 10),
  weights = 1/1000
)
# Let's suppose a different calibration resulted in a different posterior:
posterior.b = data.frame(
  risk.mean = rtruncnorm(n = 1000, mean = 1, sd = 0.5, a = 0,b = 3),
  risk.sd = rtruncnorm(n = 1000, mean = 0.5, sd = 2, a = 0,b = 10),
  weights = 1/1000
)

# Here we set the posterior of the model using three posterior files:
model$set_posterior(posteriors_list = list(pa = posterior.a, pb = posterior.b, pc = posterior.b),
                    posterior_weights = "weights", use_average = F, n_posterior = 1000)

test_that("set_posterior works", {
  expect_true(nrow(model$posterior_params) == 3000)
})


# Here we set the posterior of the model using three posterior files:
model$set_posterior(posteriors_list = list(pa = posterior.a, pb = posterior.b, pc = posterior.b),
                    posterior_weights = "weights", use_average = T)

test_that("set_posterior works with averages", {
  expect_true(nrow(model$posterior_params) == 3)
})

