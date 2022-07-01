

# Example natural history and screening methods ---------------------------

# A natural history function for testing purposes
model_simulate_natural_history = function(self, ...){
  results = data.frame(p.id = 1:self$inputs$pop.size,
                       risk = rnorm(n = self$inputs$pop.size, mean = self$inputs$risk.mean, sd = self$inputs$risk.sd))

  results$probability.event = 1-exp(-results$risk)

  results$n.events = rbinom(n = 1:self$inputs$pop.size, size = self$inputs$trials, prob = results$probability.event)

  self$natural_history_results = results

  invisible(self)
}

# A screening function for testing purposes
model_simulate_screening = function(self, ...) {

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
model = crcmodel$new(name = "model 2.1.1 - SSP")

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

# Setting an input twice:
model$set_input(name = "risk.sd",value = 0.02,type = "natural_history")

test_that("input was created", {
  expect_true(model$inputs$pop.size == 1000)
})


# Set posterior -----------------------------------------------------------

# Loading multiple posterior data.frames:
posterior.a = data.frame(
  risk.mean = rnorm(n = 1000, mean = 0, sd = 0.5),
  risk.sd = rnorm(n = 1000, mean = 1, sd = 2),
  weights = 1/1000
)
# Let's suppose a different calibration resulted in a different posterior:
posterior.b = data.frame(
  risk.mean = rnorm(n = 1000, mean = 1, sd = 0.5),
  risk.sd = rnorm(n = 1000, mean = 0.5, sd = 2),
  weights = 1/1000
)

# Here we set the posterior of the model using three posterior files:
model$set_posterior(posteriors_list = list(pa = posterior.a, pb = posterior.b, pc = posterior.b),
                    posterior_weights = "weights", use_average = F, n_posterior = 10)

test_that("set_posterior works", {
  expect_true(nrow(model$posterior_params) == 30)
})

# Set posterior works without sampling:
model$set_posterior(posteriors_list = list(pa = posterior.a, pb = posterior.b, pc = posterior.b),
                    posterior_weights = "weights", resample = F)

test_that("set_posterior works without resampling", {
  expect_true(nrow(model$posterior_params) == 3000)
})

# Here we set the posterior of the model using three posterior files:
model$set_posterior(posteriors_list = list(pa = posterior.a, pb = posterior.b, pc = posterior.b),
                    posterior_weights = "weights", use_average = T)

test_that("set_posterior works with averages", {
  expect_true(nrow(model$posterior_params) == 3)
})



# simulate_natural_history and screening ----------------------------------

model$set_natural_history_fn(model_simulate_natural_history)
set.seed(1234)
model$simulate_natural_history()

test_that("simulate_natural_history works", {
  expect_equal(object = nrow(model$natural_history_results),expected = model$inputs$pop.size)
})

test_that("get_people_in_block works", {
  expect_equal(object = length(get_people_in_block(person_ids = model$natural_history_results$p.id, blocks = 1, block_id = 1)),expected = nrow(model$natural_history_results))
  expect_equal(object = length(get_people_in_block(person_ids = model$natural_history_results$p.id, blocks = 2, block_id = 1)),expected = nrow(model$natural_history_results)/2)
  expect_equal(object = get_people_in_block(person_ids = model$natural_history_results$p.id, blocks = 2, block_id = 2),expected = (nrow(model$natural_history_results)/2 + 1):nrow(model$natural_history_results))
})



test_that("simulate_screening works", {
  model$set_screening_fn(model_simulate_screening)
  set.seed(1234)
  results = model$simulate_screening()
  expect_true(is.crcmodel(results))
})




# json tests --------------------------------------------------------------

json = model$to_json()
# Re-creating the model from json:
new_model = crcmodel$new(name = "model 2.1.2 - SSP")
new_model$set_inputs_from_json(json = json)

test_that("to_json and set_input_from_json work", {

  expect_equal(length(new_model$inputs), length(model$inputs))

})


test_that("results from a json-converted model is identical to original model", {

  new_model$set_natural_history_fn(model_simulate_natural_history)
  set.seed(1234)
  new_model$simulate_natural_history()

  expect_identical(model$natural_history_results, new_model$natural_history_results)

})


# set_input tests ---------------------------------------------------------

test_that("set_inputs handles unusual inputs", {

  expect_error(model$set_input())

  # Unusual data-types
  expect_warning(model$set_input(name = "some_date", value = as.Date("2021-01-01")))

  expect_warning(model$set_input(name = "some_list", value = list(a = as.Date("2021-01-01")) ))

  # objects with different lengths:
  expect_warning(model$set_input(name = "pop.size", value = c(1,2,3)))

  # lists with nested values:

})



# crcexperiment tests -----------------------------------------------------

test_that("crcexperiment works with set_parameter", {
  experiment = crcexperiment$new(model)

  experiment$
    set_parameter(parameter_name = "Test1",experimental_design = "grid", values = c("Colonoscopy", "FIT"))$
    set_parameter(parameter_name = "abc",experimental_design = "lhs",min = 1, max = 10)$
    set_design(n_lhs = 2)

  expect_true(is.crcexperiment(experiment))
})

test_that("crcexperiment works without set_parameter", {
  experiment = crcexperiment$new(model)
  experiment$set_design()
  expect_true(is.crcexperiment(experiment))
})

experiment = crcexperiment$new(model)

experiment$
  set_parameter(parameter_name = "Test1",experimental_design = "grid", values = c("Colonoscopy", "FIT"))$
  set_parameter(parameter_name = "abc",experimental_design = "lhs",min = 1, max = 10)$
  set_design(n_lhs = 2, convert_lhs_to_grid = T)

test_that("crcexperiment works with convert to grid = T", {
  expect_true(is.crcexperiment(experiment))
})

test_that("to_JSON returns a list with the experiment", {
  json_exp = experiment$write_design()
  expect_true(length(json_exp) == 2)
})

test_that("to_JSON can write to a file", {
  experiment$write_design(path = "json-test/", block_ids = 1)

  expect_true(file.exists("./json-test/screening_design.txt"))
  expect_true(file.exists("./json-test/nh_design.txt"))

  file.remove("./json-test/screening_design.txt")
  file.remove("./json-test/nh_design.txt")
  file.remove("./json-test/")
})

test_that("crcexperiment works with pre-existing design", {
  experiment = crcexperiment$new(model)
  # External grid:
  grid_design = expand.grid(c(1:10), c(10:13))
  # Create an experimental design:
  experiment$set_design(grid_design_df = grid_design)
  expect_true(is.crcexperiment(experiment))
})
