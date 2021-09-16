

test_list = list(a = 13/3, b = list(a=c(1,2), b = c("ab", "cde")), c = c(T,F))
test_list_2 = list(a = 14, b = list(a=c(1,3), b = c("abdsadsadas", "cfdafdsafdsafdsafdde"), c = c(F, T)))



list_to_json = rjson::toJSON(test_list, indent = 0)
list_to_json2 = rjson::toJSON(test_list_2, indent = 0)

write(list_to_json, file = "model_inputs.json")


experimental_inputs = c(list_to_json, list_to_json2)

experimental_design = data.frame(json_params = c(list_to_json, list_to_json2))

write(experimental_inputs, file = "experimental_design.txt", ncolumns = 1)


write




json_to_list = rjson::fromJSON(list_to_json)

# The from and to json functions work well with lists and vectors, but not so well with dataframes.
# So make sure each object in the list is a vector, scalar or list. Do not include data.frames or tibbles.
# You can still read

identical(test_list,  json_to_list)

# Also, need to be aware that toJSON will round numbers, so there's a loss of precision here.

