
library(crcspin)
library(dplyr)


# Creating a model --------------------------------------------------------

model = crcspin$new(name = "crcspin v2.1")
# Set posterior:
model$set_posterior(posteriors_list = list(v2_4 = read.csv("./dev/good.modelparms_v2_4_ABC_R5_35.csv"),
                                           v2_3 = read.csv("./dev/good.modelparms.csv")),
                    posterior_weights = "sample.wt",
                    use_average = T,
                    n_posterior = 100,
                    seed = 1234)
# Deep = T guarantees that it will be duplicated.
other_model = model$clone(deep = T)
other_model$name = "crcspin v3.0"



# Creating an experiment --------------------------------------------------

# An experiment can contain more than one model, each with their onw posteriors:
experiment = crcexperiment$new(model, other_model)

# Create an experimental design:
experiment$
  set_parameter(parameter_name = "Test1",experimental_design = "grid", values = c("Colonoscopy", "FIT"))$
  set_parameter(parameter_name = "abc",experimental_design = "lhs",min = 1, max = 10)$
  set_design(n_lhs = 2)


View(experiment$experimental_design)


# Write experimental design.





View(experiment$posteriors)

# Seeing the inputs
model$inputs$parms



