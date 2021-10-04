


#------------------------------------------------------------------------------#
#
# CRCRDM: Robust Decision Making tools for Colorectal Cancer Screening Models
#
# Author: Pedro Nascimento de Lima
# See LICENSE.txt and README.txt for information on usage and licensing
#------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#
# model_to_json and model_from_json functions
# Purpose: Converts crcmodel objects to and from JSON.
# Can be used to pass and get model parameters as JSON objects.
# Creation Date: July 2021
#------------------------------------------------------------------------------#

# Manipulating model inputs as JSON objects ------------------------------------

# Converts a CRCmodel to a JSON string
crcexperiment_to_json <- function(self){
  # Create a data.frame of jsob objects.
  data.frame(json_inputs = apply(self$experimental_design, 1, experiment_to_json, self = self)) %>%
    mutate(json_inputs = json_inputs)
}

# Auxiliary functions to transform an experimental design table to a json object.

# Converts a single experiment in the experimental design to a json object:

experiment_to_json = function(experiment_row, self) {

  model_id = as.integer(experiment_row["model.id"])
  param_id = as.integer(experiment_row["param.id"])

  # This is the structure of the object created within each JSON row.
  # More information could be added here, if necessary.
  experiment_data = list(
    experiment_row = as.list(experiment_row),
    model_inputs = list(
      model_name = self$models[[model_id]]$name,
      # Selecting model inputs from current model
      inputs = self$models[[model_id]]$inputs,
      # Selecting parameter set for this particular run:
      params = self$models[[model_id]]$posterior_params[self$models[[model_id]]$posterior_params$param.id==param_id,]
    )
  )

  rjson::toJSON(experiment_data)
}

