

#' crcrdm: Tools for Robust Decision Making analyses for CRC models
#'
#' The crcrdm package contains two main types of objects: crcmodel and crcexperiment
#'
#' @section crcmodel functions:
#' A crcmodel ...
#'
#' @section crcexperiment functions:
#' A crcexperiment ...
#'
#' @section EMEWS Integration:
#' Once a crcexperiment is defined, there are a few options to run the experiment.
#'
#' @docType package
#' @name crcrdm
#' @importFrom rjson toJSON
NULL


# Allowing . to be used for dplyr
# https://stackoverflow.com/questions/48750221/dplyr-and-no-visible-binding-for-global-variable-note-in-package-check
utils::globalVariables(".")

# Exporting the where() dplyr verb, per
# https://github.com/r-lib/tidyselect/issues/240
utils::globalVariables("where")
