

#------------------------------------------------------------------------------#
#
# CRCRDM: Robust Decision Making tools for Colorectal Cancer Screening Models
#
# Author: Pedro Nascimento de Lima
# See LICENSE.txt and README.txt for information on usage and licensing
#------------------------------------------------------------------------------#

#------------------------------------------------------------------------------#
# Functions to query which persons are part of a population block
# Purpose: Functions to query which persons are part of a population block.
# Creation Date: July 2021
#------------------------------------------------------------------------------#

# Returns vector of people in selected block:
#' Find IDS of persons in a given block
#'
#' @param person_ids a vector of integers of people ids. This vector starts in 1.
#' @param blocks the number of population blocks.
#' @param block_id the id of the population block to query
#'
#' @return a vector of people who belong to the block_id
#' @export
get_people_in_block = function(person_ids, blocks, block_id) {
  person_ids[get_block_ids(person_ids, blocks) == block_id]
}

# Returns the block ids of a set of people:
get_block_ids = function(person_ids, blocks) {
  n_blocks = max(person_ids) / blocks
  ceiling(person_ids / n_blocks) # + initial_person_id
}
