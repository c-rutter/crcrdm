

#' crcrdm: Tools for Robust Decision Making analyses for CRC models
#'
#' This package implements the \code{\link{crcmodel}} and the \code{\link{crcexperiment}} R6 classes and can be used to perform large-scale computational experiments of multiple cancer screening models using High-Performance Computing resources. The package supports common tasks, such as defining and conducting Probabilistic Sensitivity Analyses (PSAs) and robustness analyses using one or multiple models. The package is also designed to support High-Performance Computing workflows using the Extreme Scale Model Exploration with Swift/T (EMEWS) framework. This feature will allow use of High-Performance computing resources for large-scale, long-running experiments that involve simulating a large populations (e.g. 10^7) over thousands of simulation runs, which require several thousand computing hours and many terabytes of memory to run. This package has been primarly used by the CRC-SPIN model so far, but could be used for other models. The package itself does not contain any specific model.
#'
#'
#' @docType package
#' @name crcrdm
NULL


# Allowing . to be used for dplyr
# https://stackoverflow.com/questions/48750221/dplyr-and-no-visible-binding-for-global-variable-note-in-package-check
utils::globalVariables(".")

# Exporting the where() dplyr verb, per
# https://github.com/r-lib/tidyselect/issues/240
utils::globalVariables("where")
