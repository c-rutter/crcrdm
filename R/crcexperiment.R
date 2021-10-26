

#------------------------------------------------------------------------------#
#
# CRCRDM: Robust Decision Making tools for Colorectal Cancer Screening Models
#
# Author: Pedro Nascimento de Lima
# See LICENSE.txt and README.txt for information on usage and licensing
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# CRC Experiment Class
# Purpose: The crcexperiment contains one or more models.
# Creation Date: July 2021
#------------------------------------------------------------------------------#

#' R6 Class Representing a `crcexperiment`
#'
#' @description
#' This class implements a `crcexperiment`.
#'
#' @import R6
#' @export
crcexperiment <- R6::R6Class(
  classname = "crcexperiment",
  # Use public to expose methods of this class:
  public = list(

    #' @field models is a list containing crcmodel objects.
    models = NULL,
    #' @field nh_design is a data.frame containing one row per natural history experiment to be run.
    nh_design = NULL,

    #' @field screening_design is a data.frame containing one row per screening experiment to be run.
    screening_design = NULL,

    #' @field grid is a data.frame containing one row per point in the grid experimental design.
    grid = NULL,

    #' @field lhs is a table containing one row per point in the Latin Hypercube experimental design.
    lhs = NULL,

    #' @field blocks is the number of population blocks used in the experimental design. This number of population blocks allows us to divide the experimental design into experimental blocks.
    blocks = NULL,

    #' @field posteriors is a data.frame containing one row per parameter set defined in the posterior of each model included in the experiment.
    posteriors = NULL,

    #' @field experimental_parameters is a list containing details about each experimental parameter. Experimental parameters can be either policy levers or uncertainties. Defining this distinction is up to the user.
    experimental_parameters = list(),

    #' @description
    #' This function is used to initialize a `crcexperiment` object. This object represents an experiment that will be run and can encompass multiple models.
    #' @param ... set of crcmodels to be included in the experiment. One `crcexperiment` can contain multiple models of the `crcmodel` class.
    #' @return a new `crcexperiment` object.
    initialize = function(...) {
      self$models <- list(...)
    },

    #' @description
    #' Set Experimental Parameter for the Experiment
    #'
    #' @details
    #' This function constructs the experimental_parameter object, and appends experimental parameters that will be visible inside the model in the future.
    #' Experimental parameters can be either uncertainties or decision levers.
    #' Every parameter defined in this function can be accessed within the model by using \code{experimental_parameters$param_name}.
    #'
    #' @param parameter_name character string defining the parameter name.
    #' @param experimental_design Either "grid" or "lhs" Use lhs if you want to create a Latin Hypercube Sample within the min and max bounds you provided. Use Grid
    #' @param values use when experimental_design = "grid". This should be a vector including the values to be included in a grid experimental design. Please use parameters and values that can be converted to strings without any issues.
    #' @param min use when experimental_design = "lhs". This should bea numeric value indicating the minimum bound in the Latin Hypercube sample.
    #' @param max use when experimental_design = "lhs". This should bea numeric value indicating the minimum bound in the Latin Hypercube sample.
    set_parameter = function(parameter_name, experimental_design, values, min, max){
      crcexperiment_set_parameter(self = self, parameter_name = parameter_name, experimental_design = experimental_design, values = values, min = min, max = max)
    },

    #' @description
    #' Set Experimental Design
    #'
    #' @details
    #' Creates two data.frames that represent the experimental design" the `nh_design` for natural history experiments and the `screening_design` for screening experiments. These experimental designs are created based on the parameters defined by the set_parameter functions. The experimental design created by this function is useful to run a typical RDM analysis where each policy is evaluated across a LHS of deep uncertainties. To achieve that, define each policy lever as a grid parameter, and each uncertainty as an "lhs" uncertainty. Natural history uncertainties are often already defined in the model's posterior file and are also considered.
    #' The natural history design will have `n_posterior` runs for each model in the experimental design.
    #' The screening experimental design will have `blocks` \* `n_lhs` \* `n_grid_points` \* `n_posterior` for each model in the experimental design.
    #'
    #' @param n_lhs The number of points in the Latin Hypercube Sample to be created.
    #' @param blocks is the number of population blocks to use to parallelize the runs across nodes.
    #' @param grid_design_df a data.frame containing a pre-existing experimental design to be used. This function will use this experimental design in lieu of parameters defined in the grid, so this effectively replaces any set of parameters that are part of a grid design.
    #' @param convert_lhs_to_grid Default is FALSE. If TRUE, this function convert the LHS parameters to "grid" parameters. This is useful when one needs to test the "corners" of the experimental design before performing a full LHS run.
    #' @param lhs_to_grid_midpoints Only relevant when convert_to_lhs = T. Default value is 0. This should be an integer determining how many points within the grid hypercube should be created for the parameters being converted from LHS to a GRID design. For example, if convert_lhs_to_grid = T and lhs_to_grid_midpoints = 0, this function will create a full factorial design of the LHS parameters with 2^n points. If one wants to use one midpoint, then the design will have 3^n points, and so on. This parameter does not affect parameters orignally defined as part of a grid design because their values have already been set.
    set_design = function(n_lhs, blocks = 1, grid_design_df, convert_lhs_to_grid = F, lhs_to_grid_midpoints = 0){
      crcexperiment_set_design(self = self, n_lhs = n_lhs, blocks = blocks, grid_design_df = grid_design_df, convert_lhs_to_grid = convert_lhs_to_grid, lhs_to_grid_midpoints = lhs_to_grid_midpoints)
    },

    #' @description
    #' Convert Experimental Design to a JSON format
    #'
    #' @details
    #' Creates a data.frame in which each row represents a single experiment. The json object included in each row contains all information that the models need to re-create themselves in the server-side in a HPC workflow.
    #'
    #' @param json_folder folder where json experimental designs should be saved. Do not specify a file name. If missing, the function will return the design specified below.
    #' @param design "natural_history", "screening" or "both". If missing, "both" is assumed.
    to_json = function(json_folder, design){

      if(missing(design)){
        design = "both"
      }

      # Write JSON design to disk if user provided a json_path
      if(!missing(json_folder)){

        dir.create(json_folder, showWarnings = F)

        if(design %in% c("natural_history", "both")){

          message("Writing Natural History Experimental Design JSON File")
          write.table(x = crcexperiment_to_json(self = self, experimental_design = self$nh_design, type = "nh"),
                      file = paste0(json_folder,"nh_design.txt"), row.names = F, col.names = F,quote = F)
        }

        if(design %in% c("screening", "both")){
          message("Writing Screening Experimental Design JSON File")
          write.table(x = crcexperiment_to_json(self = self, experimental_design = self$screening_design, type = "screening"),
                      file = paste0(json_folder,"screening_design.txt"), row.names = F, col.names = F,quote = F)
        }

      # If folder was not provided, then return the desired experimental design.

      } else {
        json_design = switch(design,
                natural_history = crcexperiment_to_json(self = self, experimental_design = self$nh_design, type = "nh"),
                screening = crcexperiment_to_json(self = self, experimental_design = self$screening_design, type = "screening"),
                both = list(natural_history = crcexperiment_to_json(self = self, experimental_design = self$nh_design, type = "nh"),
                            screening = crcexperiment_to_json(self = self, experimental_design = self$screening_design, type = "screening"))
        )
        return(json_design)
      }
    }

  ),
  # Use private to hold data that will not be accessed by the user directly.
  private = list(
    # Private objects are not documented and exported as R6 fields:
    #character vector with names of data.frame objects. This is used when converting objects to and from json.
    df_objects = c("inputs_table"),
    #character vector of list of objects to convert to and from
    json_objects = c("inputs", "inputs_table")
  ),
  # Use active binding functions to get and set the private data
  active = list()
  # Initialize function is used to initialize the object:
)


#' Checks if object is a `crcexperiment`.
#'
#' @param x the object
#'
#' @return TRUE if object is a `crcexperiment`
#' @export
is.crcexperiment = function(x){
  "crcexperiment" %in% class(x)
}
