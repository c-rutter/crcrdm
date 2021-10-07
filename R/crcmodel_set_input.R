

#------------------------------------------------------------------------------#
#
# CRCRDM: Robust Decision Making tools for Colorectal Cancer Screening Models
#
# Author: Pedro Nascimento de Lima
# See LICENSE.txt and README.txt for information on usage and licensing
#------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#
# Set Input method
# Purpose: Sets inputs objects for models based on the crcmodel class.
# Creation Date: July 2021
#------------------------------------------------------------------------------#


#### set_input generic and method-------------------------------------------####

# Defines Inputs of crcmodels
# See documentation within the crcmodel file.
crcmodel_set_input = function(self, name, value, type) {

  if(missing(type)){
    type = "default"
  }

  # if input already exists, then update the table:
  if(name %in% self$inputs_table$name){

    message(paste0("Input ", name, " already exists. Replacing it with new value."))

    # for safety reasons, let's ensure we are replacing objects with the same class and type:
    # This is too annoying because numerics and integers are not from the same class.
    #assertthat::assert_that(assertthat::are_equal(class(self$inputs[[name]]), class(value)), msg= paste0("You are not allowed to replace the input ", name, " which was ", class(self$inputs[[name]]), " with an object of class ", class(value)))

    # Also, checking type:
    #assertthat::assert_that(assertthat::are_equal(typeof(self$inputs[[name]]), typeof(value)), msg= paste0("You are not allowed to replace the input ", name, " which was ", typeof(self$inputs[[name]]), " with an object of type ", typeof(value)))

    # Let's also check that the length of the objects are the same:

    if(length(self$inputs[[name]]) != length(value)){
      warning(paste0("You are replacing the input ", name, " which had length ", length(self$inputs[[name]]), " with an object of length ", length(value)))
    }

    # Replace type with the provided type
    self$inputs_table$type[which(self$inputs_table$name == name)] = type

  } else {
    # Otherwise, add another row:
    self$inputs_table = rbind(self$inputs_table, data.frame(name = name, type = type))
  }

  # Check if input type is supported.
  recommended_classes = c("numeric","integer", "logical", "character", "data.frame", "list")

  if(!(class(value) %in% recommended_classes)){
    warning(paste0("Input ", name, " includes values using classes that we do not recommend because they may cause issues when we translate model inputs to and from strings. Use only integers, numerics, logical or character objects."))
  }

  # If this is a list or datarame, also check if there aren't any weird classes within the first level of the object.
  if(class(value) %in% c("list", "data.frame")) {

    if(!all(sapply(value, class) %in% recommended_classes)) {
      warning(paste0("Input ", name, " includes values using classes that we do not recommend because they may cause issues when we translate model inputs to and from strings. Use only integers, numerics, logical or character objects."))
    }

  }

  # only after checking that types and classes are being preserved, do something else.

  self$inputs[[name]] = value

  # return invisible self because we call this function for its side effects:
  invisible(self)

}
