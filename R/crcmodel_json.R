

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
crcmodel_to_json <- function(self, private, types){

  # Create a list with all objects to be converted:
  x = list()
  for (obj in private$json_objects) {x[[obj]] <- self[[obj]]}

  # Filter inputs from the desired type:
  if(!missing(types)){
    x$inputs_table = x$inputs_table[self$inputs_table$type %in% types,]
  }

  # Convert data.frames to list:
  for(obj in private$df_objects){x[[obj]] = as.list(x[[obj]])}

  # Filter Inputs list and table to only include desired input types:
  if(!missing(types)){
    x$inputs = x$inputs[x$inputs_table$name]
  }

  # Capturing the model class as a character vector string:
  x$class = class(self)
  x$model_name = self$name

  json_model = jsonlite::serializeJSON(x, digits = 20)

  return(json_model)
}

# Converts a JSON Object to a crcspin model object
crcmodel_set_inputs_from_json = function(self, json){

  json_list = jsonlite::unserializeJSON(json)

  #original model class should match the the class defined in the json objects:
  assertthat::assert_that(identical(json_list$class, class(self)),msg = "The model class used to create the json file does not correspond to this model's class. Make sure to use exactly the same function to create the model")

  # Assign all inputs to the model.
  for(input_name in names(json_list$inputs)){
    # Set each input:
    self$set_input(name = input_name, value = json_list$inputs[[input_name]], type = json_list$inputs_table$type[json_list$inputs_table$name==input_name])
  }

  # Returning the model object.
  return(invisible(self))

}


