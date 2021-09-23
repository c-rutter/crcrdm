library(crcspin)
library(crcrdm)
library(dplyr)

devtools::load_all()

# Creating a model --------------------------------------------------------
model = crcspin$new(name = "crcspin v2.1")
# Set posterior:
model$set_posterior(posteriors_list = list(v2_4 = read.csv("./dev/good.modelparms_v2_4_ABC_R5_35.csv")),
                    posterior_weights = "sample.wt",
                    use_average = F,
                    n_posterior = 50,
                    seed = 1234)
# Creating an experiment --------------------------------------------------
# An experiment can contain more than one model, each with their onw posteriors:
experiment = crcexperiment$new(model, other_model)
# Create an experimental design:
experiment$set_design()
json_experiment = experiment$to_json()

write.table(x = additional_json_experimental_design, file = additional_json_experimental_design_path, row.names = F, col.names = F,quote = F)
