

#------------------------------------------------------------------------------#
#
# CRCRDM: Robust Decision Making tools for Colorectal Cancer Screening Models
#
# Author: Pedro Nascimento de Lima
# See LICENSE.txt and README.txt for information on usage and licensing
#------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#
# CRC Experiment Class
# Purpose: The crcexperiment class represents an experiment of one or more crcmodels.
# Creation Date: July 2021
#------------------------------------------------------------------------------#

#'
#' # CRC model constructor
#' new_crcexperiment = function(...) {
#'
#'   # The first argument is a list of models.
#'   models = list(...)
#'
#'   # Any crcspin model is a list.
#'   experiment = structure(
#'     .Data = list(models = models),
#'     class = c("crcexperiment")
#'   )
#'
#'   # Getting user name (for HPC purposes):
#'   experiment$user = unname(Sys.info()["user"])
#'
#'   # Creation date:
#'   experiment$creation_date = Sys.time()
#'
#'   # Model Type:
#'   class(experiment) = "crcexperiment"
#'
#'   experiment
#'
#' }
#'
#'
#' # crcmodel validator
#' validate_experiment.crcexperiment = function(x) {
#'
#'   # Check if has the correct class
#'   stopifnot(any("crcexperiment" %in% class(x)))
#'
#'   x
#'
#' }
#'
#' #' Creates a crc model object
#' #'
#' #' @param name a string naming the model.
#' #' @param path an id
#' #'
#' #' @return
#' crcexperiment = function(...){
#'
#'   experiment = validate_experiment(new_crcexperiment(...))
#'
#'   experiment
#'
#' }
#'
#'
#' # crc model generics ------------------------------------------------------
#'
#' # Validate model
#' validate_experiment <- function(x, ...){
#'   UseMethod("validate_experiment", x)
#' }
