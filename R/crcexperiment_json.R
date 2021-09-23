


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
crcexperiment_to_json <- function(self, private){

  browser()

  # Create a list with all objects to be converted:
  x = list()
  for (obj in private$json_objects) {x[[obj]] <- self[[obj]]}

  # Convert data.frames to list:
  for(obj in private$df_objects){x[[obj]] = as.list(x[[obj]])}

  # capturing the model class as a character vector string:
  x$class = class(self)
  x$model_name = self$name

  json_model = rjson::toJSON(x, indent = 0)

  return(json_model)

}

