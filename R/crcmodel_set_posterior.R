

#------------------------------------------------------------------------------#
#
# CRCRDM: Robust Decision Making tools for Colorectal Cancer Screening Models
#
# Author: Pedro Nascimento de Lima
# See LICENSE.txt and README.txt for information on usage and licensing
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# Set Posterior Method
# Purpose: Samples from multiple posterior files and defines parameters
# from the posterior distribution.
# Creation Date: July 2021
#------------------------------------------------------------------------------#

# See documentation in the crcmodel class.
crcmodel_set_posterior = function(self, posteriors_list, posterior_weights, use_average, n_posterior, seed = 12345678) {

  # Setting a seed for reproducibility because this function will create a sample:
  if(!missing(seed)){
    set.seed(seed = seed)
  }

  # Checking Inputs:

  # Posterior is a list:
  assertthat::assert_that(is.list(posteriors_list),msg = "posteriors_list object should be a list.")

  # it only contains data.frames:
  assertthat::assert_that(all(sapply(posteriors_list, is.data.frame)),msg = "posteriors_list object should be a list.")

  # every data.frame contains exactly the same columns:
  names_list = lapply(posteriors_list, names)

  # all names of the data.frames are exactly the same:
  assertthat::assert_that(all(sapply(names_list, identical, names_list[[1]])), msg = "All dataframes in the posterior_lists should have the same parameters. each parameter data.frame must have the same names.")

  # posterior_weights must be provided:
  assertthat::assert_that(!missing(posterior_weights), msg = "posterior_weights parameter must be provided.")

  # posterior_weights needs to be a character:
  assertthat::assert_that(is.character(posterior_weights), msg = "posterior_weights should be a character defining the collumn name of the weights to use to sample from the posterior.")

  # It should be a single character
  assertthat::assert_that(length(posterior_weights) == 1, msg = "posterior_weights should be a single character")

  # it also needs to exist in the posterior file - we already checked all of them are the same, so we can just check the first one.
  assertthat::assert_that(posterior_weights %in% names_list[[1]])


# Sample from Posterior ------------------------------------------

  # This internal function samples from the posterior distribution. It is defined here because it is only used by the set_posterior function.
  sample_from_posterior = function(posterior_data_frame, n_posterior, posterior_weights) {

    # Assign an id to the original posterior table:
    posterior_data_frame = posterior_data_frame %>%
      mutate(posterior.orig.row.id = dplyr::row_number())

    # Next, sample from the posterior with replacement:
    ids_to_select = sample(x = posterior_data_frame$posterior.orig.row.id, size = n_posterior, replace = T, prob = posterior_data_frame[,posterior_weights])

    # Selects these rows from the data.frame:
    posterior_sample = posterior_data_frame[ids_to_select,] %>%
      dplyr::mutate(posterior.df.row.id = dplyr::row_number())

    return(posterior_sample)

  }


# Calculate weighted averages ------------------------------------

  # This private function is used to calculate weighted averages if the user wants them.
  calculate_weighted_averages = function(df, posterior_weights) {
    # Calculate a normalized_weights variable to ensure that the weighted average will be correct:
    df$normalized_weights = df[,posterior_weights] / sum(df[,posterior_weights])

    # Calculate the weighted average for every numeric variable:
    df %>%
      # Multiply value by the normalized weights:
      mutate(across(where(is.numeric) & !c(posterior.df.id, posterior.df.name), ~ .x * df$normalized_weights)) %>%
      select(-normalized_weights) %>%
      # Add them up:
      group_by(posterior.df.id, posterior.df.name) %>%
      summarise(across(where(is.numeric),sum), .groups = "drop") %>%
      as.data.frame()
  }


  # Defining the names of the posteriors:
  for(posterior_id in 1:length(names(posteriors_list)) ) {
    posteriors_list[[posterior_id]]$posterior.df.id = posterior_id
    posteriors_list[[posterior_id]]$posterior.df.name = names(posteriors_list)[posterior_id]
  }

  # If we want to use the average, we can do so:
  if(use_average) {

  # calculate weighted averages for every posterior in the posteriors_list:
    posterior_params <- purrr::map_dfr(.x = posteriors_list, .f = calculate_weighted_averages, posterior_weights = posterior_weights) %>%
      dplyr::mutate(param.id = row_number())

  # If not using weighted averages, sample from the posterior using its weights:
  } else {

    # n_posterior is smaller or equal to the size of the dataframe.
    assertthat::assert_that(all(sapply(posteriors_list, nrow) >= n_posterior), msg = "Number of rows in each posterior data.frame must be greater or equal than n_posterior.")

    # n_posterior is not missing
    assertthat::assert_that(!missing(n_posterior), msg = "n_posterior parameter must be provided.")

    # Use the purrr::map_dfr function to sample from the posterior distribution for each posterior file provided.
    posterior_params <- purrr::map_dfr(.x = posteriors_list, .f = sample_from_posterior, n_posterior = n_posterior, posterior_weights = posterior_weights) %>%
      dplyr::mutate(param.id = row_number())

    row.names(posterior_params) = NULL
  }

  # The main result of this function is the posterior_params data.frame, which we assign to self:
  self$posterior_params = posterior_params

  # Return the model object:
  invisible(self)

}
