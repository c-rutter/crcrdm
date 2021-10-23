library(crcspin)
library(dplyr)

devtools::load_all()

attachment::att_amend_desc()

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
experiment = crcexperiment$new(model)
# Create an experimental design:
experiment$set_design(blocks = 10)

View(experiment$nh_json_design)

View(experiment$screening_json_design)

View(experiment$json_design)

# Methods Missing in the experiment:
experiment$run # runs the experiment

# Required for the Comparative Calibration Paper:
# Maybe this code should be in the HPC side of things.
# assign_inputs() Assign inputs to model - this is custom code and may change depending on the experimental design.
# simulate_natural_history(): Run the model.
# compute_outputs(): Compute additional outputs listed by Carolyn. - maybe this is a project-specific script.
# save_outputs():
# Save Inputs to specified location.


json_design = experiment$to_json()

model = expe

# The Run Experiment Function is a function to be assigned to the model.
# This function is project-specific and can do whatever the user wants.
# This function takes the crcmodel and a row
#
run_experiment_fn = function(crcmodel, json_inputs){

  json_inputs = rjson::unserializeJSON(json_inputs)

}

model_analysis_function = function(model, exp_design_line)






View(experiment$experimental_design)

write.table(x = additional_json_experimental_design, file = additional_json_experimental_design_path, row.names = F, col.names = F,quote = F)
