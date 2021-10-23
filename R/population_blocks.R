





person.ids = 1:10^7

blocks = 25

# This simple operation retrieves their block ids / no need for storing this anywhere:
get_block_ids = function(person_ids, blocks) {
  n_blocks = max(person_ids) / blocks
  ceiling(person_ids / n_blocks) # + initial_person_id
}

# Returns vector of people in selected block:
people_in_block = function(person_ids, blocks, block_id) {
  person_ids[get_block_ids(person_ids, blocks) == block_id]
}

length(people_in_block(person_ids = person.ids, blocks = blocks, block_id = 1))

