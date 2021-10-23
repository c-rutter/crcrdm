


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
crcexperiment_to_json <- function(self, experimental_design){
  # Create a data.frame of json objects.
  data.frame(json_inputs = apply(experimental_design, 1, experiment_to_json, self = self)) %>%
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
    inputs = self$models[[model_id]]$to_json(),
    params = self$models[[model_id]]$posterior_params %>%
      dplyr::filter(param.id == param_id) %>%
      dplyr::select(-dplyr::any_of(c("posterior.df.id", "posterior.df.name", "posterior.orig.row.id", "posterior.df.row.id", "param.id", "model.id")))
  )

  jsonlite::serializeJSON(experiment_data, digits = 20)
}

