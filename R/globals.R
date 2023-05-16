
# dplyr is used in this package; this fixes some of the issues created by it:
# https://community.rstudio.com/t/how-to-solve-no-visible-binding-for-global-variable-note/28887
#' To produce this list run the CRAN check, copy the undefined global functions or variables that appear in the check. Paste them into sublime, replace spaces with a new line dash n, then use command shift L to edit all lines and format approproately
#' @name globalvariables definitions
#' @noRd
#' @importFrom utils globalVariables
#' @importFrom magrittr %>%
#' @import dplyr
utils::globalVariables(c("block.id",
                         "json_inputs",
                         "param.id"))
