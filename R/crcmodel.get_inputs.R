

#------------------------------------------------------------------------------#
#
# CRCRDM: Robust Decision Making tools for Colorectal Cancer Screening Models
#
# Author: Pedro Nascimento de Lima
# See LICENSE.txt and README.txt for information on usage and licensing
#------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#
# Get Input method
# Purpose: Get inputs objects for models based on the crcmodel class.
# This side-effect function is necessary because all models.
# This function ensures that getting model inputs will not overwrite
# parent environment objects.
# Creation Date: July 2021
#------------------------------------------------------------------------------#

# These functions may no longer be needed with R6's encapsulated OOP.

# Deprecated.
get_inputs.crcmodel = function(x, input_types = c("settings", "natural_history", "screening")) {

  # First, get information about the existence, types and classes of arguments that were passed to the parent function.

  # Get information about the parameters contained in the parent function:

  # Determining which objects exist in the parent frame.
  parent_frame_objects_names = ls(envir = parent.frame(n = 1))

  # Get parent frame objects into a list:
  parent_frame_objects = mget(x = parent_frame_objects_names, envir = parent.frame())

  # Arguments with TRUE in this vector are missing - I can use this information.

  # Arguments Types and Classes should always be maintained and respected:
  arguments_types = sapply(parent_frame_objects, typeof)

  arguments_class = lapply(parent_frame_objects, class)

  passed_arguments = parent_frame_objects_names[!arguments_types=="symbol"]

  # Get information about the input objects:
  input_objects = x$inputs_table$name[x$inputs_table$type %in% input_types]

  # duplicated inputs are those that are within the inputs object and were also passed to the parent function.
  duplicated_inputs = input_objects[input_objects %in% passed_arguments]

  duplicated_input_types = sapply(x$inputs[duplicated_inputs], typeof)
  duplicated_argument_types = sapply(parent_frame_objects[duplicated_inputs], typeof)

  duplicated_input_classes = sapply(x$inputs[duplicated_inputs], class)
  duplicated_argument_classes = sapply(parent_frame_objects[duplicated_inputs], class)

  # There are a small number of inputs (dozens), so doing this with a for loop makes the messages more meaningful:
  for(input_name in names(duplicated_inputs)) {
    assertthat::assert_that(assertthat::are_equal(duplicated_input_types[input_name],
                                                  duplicated_argument_types[input_name]),
                            msg = paste0("Revise your inputs and/or arguments. Input ", input_name, "type ", duplicated_input_types[input_name], " does not match argument type ", duplicated_argument_types[input_name]))

    assertthat::assert_that(assertthat::are_equal(duplicated_input_classes[input_name],
                                                  duplicated_argument_classes[input_name]),
                            msg = paste0("Revise your inputs and/or arguments. ", input_name, "class ", duplicated_input_classes[input_name], " does not match argument class ", duplicated_argument_classes[input_name]))
  }

  if(length(duplicated_inputs)>0){
    message("Inputs passed within the model were also passed to the model function as arguments. Inputs defined with set_input will overwrite inputs directly passed to your function.")
    #cat(input_objects[duplicated_inputs])
  }

  # Assign only objects that are not already in the parent environment.
  list2env(x$inputs[input_objects], envir = parent.frame())

}

