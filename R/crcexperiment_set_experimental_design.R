

#------------------------------------------------------------------------------#
#
# CRCRDM: Robust Decision Making tools for Colorectal Cancer Screening Models
#
# Author: Pedro Nascimento de Lima
# See LICENSE.txt and README.txt for information on usage and licensing
#------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#
# Set Experimental Design Function
# Purpose: Defines the Experimental Design table.
# Creation Date: September 2021
#------------------------------------------------------------------------------#


# Functions for Running Experiments ---------------------------------------

# These functions may be generalized for the crcexperiment class later.

# See documentation within the crcexperiment class.
#' @importFrom lhs randomLHS
#' @import dplyr
#' @importFrom stats qunif
crcexperiment_set_design = function(self, n_lhs, convert_lhs_to_grid, lhs_to_grid_midpoints) {

  # convert LHS parameters to grid if requested:
  if(convert_lhs_to_grid) {

    # Convert all lhs parameters to grid
    self$experimental_parameters = lapply(X = self$experimental_parameters, FUN = convert_lhs_param_to_grid, lhs_to_grid_midpoints = lhs_to_grid_midpoints)

  }


  ## Getting a Data.Frame of LHS Parameters
  lhs_params = do.call(rbind.data.frame, Filter(f = function(a) a$experimental_design == "lhs", self$experimental_parameters))

  grid_lhs_params = Filter(f = function(a) a$experimental_design == "grid_lhs", self$experimental_parameters) %>%
    sapply(., function(a) a[3]) %>%
    expand.grid(.)

  # Only sample lhs if there is one LHS variable:
  if(nrow(lhs_params)>0) {

    # Obtan an LHS sample with the lhs::randomLHS sample.
    lhs_sample <- lhs::randomLHS(n = n_lhs, k = nrow(lhs_params)) %>%
      as.data.frame()

    names(lhs_sample) = lhs_params$parameter_name

    lhs_experiments = list()

    for (param in names(lhs_sample)) {
      # Use a uniform quantile to translate the random LHS to actual values.
      lhs_experiments[[param]] = qunif(p = lhs_sample[,param], min = lhs_params$min[lhs_params$parameter_name == param], max = lhs_params$max[lhs_params$parameter_name == param])
    }

    lhs_experiments = lhs_experiments %>% as.data.frame(.) %>%
      mutate(lhs.id = row_number())

  } else if(nrow(grid_lhs_params)>0) {
    # create grid with "Lhs parameters", but using a grid desing. Useful to distinguish uncertainties from policies:
    lhs_experiments = grid_lhs_params %>%
      mutate(lhs.id = row_number())

    names(lhs_experiments) = sub(pattern = '.values',replacement =  '',x = names(lhs_experiments))

  } else {
    # lhs Experiments is a single experiment with no variable:
    lhs_experiments = data.frame(lhs.id = 1)
  }

  ## Getting a Data.Frame of Grid Parameters:
  grid_params = Filter(f = function(a) a$experimental_design == "grid", self$experimental_parameters) %>%
    sapply(., function(a) a[3]) %>%
    expand.grid(.)

  # If there are no grid parameters, then there's only one point in the grid.
  if(nrow(grid_params)>0){
    grid_params = grid_params %>%
      mutate(grid.id = row_number())
  } else {
    grid_params = data.frame(grid.id = 1)
  }

  # Getting Rid of the .values appendix
  names(grid_params) = sub(pattern = '.values',replacement =  '',x = names(grid_params))


  # Obtaining a table for models and their parameters in the posterior:
  models_df = data.frame(model.name = sapply(self$models, '[[',"name")) %>%
    dplyr::mutate(model.id = dplyr::row_number())

  # Assign model ids to their posterior tables:
  for(model_id in models_df$model.id) {
    # Assign the model id to the posteriors table:
    self$models[[model_id]]$posterior_params$model.id <- model_id
  }


  # This is a very compact way of getting exactly two columns that are within the self$models objects.
  # param.id is the parameter id within each model
  # all.posteriors.id is an id referring to the experiment design. nrow(all_models_posteriors) = max(all.posteriors.id)
  all_models_posteriors = do.call(rbind, lapply(lapply(self$models, '[[', "posterior_params"), get_ids_from_posterior)) %>%
    dplyr::mutate(all.posteriors.id = dplyr::row_number())

  # experimental design is the combination of all parameters:
  experimental_design = expand.grid(all_models_posteriors$all.posteriors.id, lhs_experiments$lhs.id, grid_params$grid.id)
  names(experimental_design) = c("all.posteriors.id", "lhs.id", "grid.id")

  experimental_design = experimental_design %>%
    dplyr::left_join(all_models_posteriors, by = "all.posteriors.id")

  # Assert that the Names of Alternative tables don't collide.
  all_collumns = c(names(all_models_posteriors), names(lhs_experiments), names(grid_params))

  duplicated_names = all_collumns[duplicated(all_collumns)]
  assertthat::assert_that({
    length(duplicated_names)==0
  }, msg = paste0("The Names of these Parameters are duplicated: ", duplicated_names))


  # Setting all posteriors object:
  self$posteriors = all_models_posteriors
  self$grid = grid_params
  self$lhs = lhs_experiments

# Defining the full experimental design table (it doesn't include parameters in the posteriors because those can be different by model)
  self$experimental_design = experimental_design %>%
    left_join(grid_params, by = "grid.id") %>%
    left_join(lhs_experiments, by = "lhs.id") %>%
    mutate(experiment.id = row_number())

  invisible(self)

}


# Auxiliary functions -----------------------------------------------------


convert_lhs_param_to_grid  = function(parameter, lhs_to_grid_midpoints) {
  if(parameter$experimental_design == "lhs"){
    parameter$experimental_design = "grid_lhs"
    parameter$values = seq.default(from = parameter$min, to = parameter$max, length.out = 2+lhs_to_grid_midpoints)
    # Clearing min and max values after using them
    parameter$min = NULL
    parameter$max = NULL
  }
  parameter
}

# Creating a table with all models posteriors and their parameters ids.
# This auxiliary function selects two columns from the posterior:
get_ids_from_posterior = function(posterior) {
  posterior[,c("param.id", "model.id")]
}
