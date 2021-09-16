# This test model emulates functions often included in microsimulation models

library(truncnorm)
library(crcrdm)
library(dplyr)

attachment::att_amend_desc()
devtools::document(roclets = c('rd', 'collate', 'namespace'))
devtools::load_all()

# Source sample model functions:
source("./dev/example_model.R")
# devtools::build_manual()

# Creates a CRC model object and gives it a name.
model = crcmodel$new(name = "CRCSPIN 2.1.1 - SSP")

# Setting model inputs:
model$
  set_input(name = "pop.size", value = 1000, type = "settings")$
  set_input(name = "risk.mean",value = 0.15,type = "natural_history")$
  set_input(name = "risk.sd",value = 0.02,type = "natural_history")$
  set_input(name = "trials",value = 10,type = "natural_history")$
  set_input(name = "strategy.id",value = 1,type = "screening")$
  set_input(name = "some_date",value = "2020-01-01",type = "screening")$
  set_input(name = "det.ratios",value = seq.default(from = 0, to = 1, length.out = 101),type = "screening")$
  set_input(name = "null_input",value = "some input",type = "screening")

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

head(model$posterior_params)

View(model$posterior_params)

# note that using the average works the same way:
model$set_posterior(posteriors_list = list(pa = posterior.a, pb = posterior.b, pc = posterior.b),
                    posterior_weights = "weights", use_average = T)

head(model$posterior_params)


# Setting and using the Model functions -------------------------------------------------

model$set_natural_history_fn(natural_history_fn = crcspin_simulate_natural_history)
model$set_screening_fn(screening_fn = crcspin_simulate_screening)

View(model$natural_history_results)

model$simulate_natural_history()
model$simulate_screening()

# Converting Inputs to and from JSON: -----------------------------------------------
json = model$to_json()

# Re-creating the model from json:
new_model = crcmodel$new(name = "CRCSPIN 3.0 - SSP")
new_model$set_inputs_from_json(json = json)

# Set posterior for this model:
new_model$set_posterior(posteriors_list = list(pa = posterior.a),
                    posterior_weights = "weights", use_average = T, n_posterior = 1000)


# Defining a multi-model experiment ---------------------------------------
my_experiment = crcexperiment$new(model, new_model)$
  set_parameter(parameter_name = "test.1", experimental_design = "grid", values = c("Colonoscopy"))$
  set_parameter("start.age", "grid", seq.default(from = 45, to = 65, by = 5))$
  set_parameter("end.age", "grid", seq.default(from = 65, to = 85, by = 5))$
  set_parameter("uncertainty.a", "lhs", min = 0, max = 100)$
  set_parameter("uncertainty.b", "lhs", min = 0, max = 100)$
  set_parameter("uncertainty.c", "lhs", min = 0, max = 100)

# Running it again is not working.
my_experiment$set_design(n_lhs = 100, convert_lhs_to_grid = F, lhs_to_grid_midpoints = 4)

nrow(my_experiment$experimental_design)

View(my_experiment$experimental_design)






## Evaluate the experiment
my_screening_experiment$run(backend = "EMEWS")


# Creating the experimental design ----------------------------------------


# Now test your functions with:
model$simulate_natural_history()

model$simulate_screening()






## 1. Defining the model structure and inputs:
# I still don't like the way we are passing parameters.
# We should be able to define parameters as part of the model inputs, then not have to passe them anymore. This will require rewiring some things in the function or in a wrapper function.

## 2. Simulating the Natural History and Screening functions with the generic function:
# Again, this is a little inconsistent because one could use the existing inputs instead of passing them to the function again.
set.seed(1234)
natural_history_results = simulate_natural_history(x = crcspinmodel)

screening_results = simulate_screening(x = crcspinmodel, population = natural_history_results)


## 3. Translating the model inputs to and from JSON:
json_model = model_to_json(crcspinmodel)
model_from_json = json_to_model(json_model)

# The object we get from JSON is not identical to the original model. This can happen because we have rounding differences when we translate the model to JSON.
# Also, empty objects are represented as empty vectors in JSON. Maybe using NULL is better
identical(crcspinmodel, model_from_json)

# But the natural history functions result in the same values:
set.seed(1234)
natural_history_results_json = simulate_natural_history(x = model_from_json)

screening_results_json = simulate_screening(x = model_from_json, population = natural_history_results)

# Results from JSON and original model are identical
identical(screening_results, screening_results_json)



## 4. Dealing with more than one posterior file:
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


# Setting the posterior(s):
crcspinmodel = crcspin(name = "CRCSPIN 2.1.1 - SSP") %>%
  set_input(., name = "pop_size",value = 10000,type = "run_settings") %>%
  set_posterior(x = .,posteriors_list = list(pa = posterior.a, pb = posterior.b, pc = posterior.b), posterior_weights = "weights", use_average = F, n_posterior = 100)

View(crcspinmodel$posterior_params)


## 5. Setting the EMEWS Backend for CRCSPIN and non-CRCSPIN models:
crcspinmodel = crcspinmodel %>%
  set_emews_backend(x = .,emews_project_root = "/path/to/emews/project",
                    workflow_script = "scripts/run_model.sh", dbuser = "plima",
                    project = "CISNET")


# We can define another model by setting inputs, posterior(s) and information about the EMEWS backend:
cisnetmodel2 = crcmodel(name = "Other CISNET Model") %>%
  set_input(., name = "some_arbitrary_parameter",value = 0,type = "natural_history") %>%
  set_posterior(x = .,posteriors_list = list(pa = posterior.a, pb = posterior.b, pc = posterior.b), posterior_weights = "weights", use_average = F, n_posterior = 100) %>%
  set_emews_backend(x = .,emews_project_root = "/path/to/emews/model2",
                    workflow_script = "scripts/run_model.sh", dbuser = "plima",
                    project = "CISNET")




# 7. Running the Experiment:
experiment_results = run_experiment(my_experiment, backend = "EMEWS:EQ/R", output_path = "/path_to_output")
