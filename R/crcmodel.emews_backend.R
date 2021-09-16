

#------------------------------------------------------------------------------#
#
# CRCRDM: Robust Decision Making tools for Colorectal Cancer Screening Models
#
# Author: Pedro Nascimento de Lima
# See LICENSE.txt and README.txt for information on usage and licensing
#------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#
# CRC Models Emews Backend Functions
# Purpose: These functions allow the models to be ran with an EMEWS Backend
# Creation Date: July 2021
#------------------------------------------------------------------------------#

## TODO.

# This functino records information that later will be used to run thi particular model.
set_emews_backend.crcmodel <- function(x, emews_project_root, workflow_script, dbuser, project) {

  # Setting Emews Information:
  x$emews_settings = list(
    emews_project_root = emews_project_root,
    workflow_script = workflow_script,
    dbuser = dbuser,
    project = project
  )

  return(x)

}
