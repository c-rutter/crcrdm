

# Natural History Method --------------------------------------------------

library(truncnorm)

crcspin_simulate_natural_history = function(self, ...){

  # Inputs set to the model can be accessed with:
  #
  #self$inputs$some_date
  # inputs given directly to the function can be accessed with:
  #p = list(...)
  #p$some_parameter

  # If the user wishes to remove this behavior and hard-code the model inputs, one can always do that.
  # You should document self$inputs used by your model in your function.
  # parameters in the posterior can be accessed with:
  # self$posterior_params$risk.mean

  # This form of running the model is attractive because it removes the need to hard-code model parameters between calls.
  # Instead of passing parameters between functions, we can simply ask the model object to evaluate itself given its inputs.

  # Ultimately, the natural history function returns a population data.frame (also an adenoma data.frame, but it doesn't matter)
  results = data.frame(p.id = 1:self$inputs$pop.size,
             risk = rtruncnorm(n = self$inputs$pop.size, a = 0, b = Inf, mean = self$inputs$risk.mean, sd = self$inputs$risk.sd)) %>%
    mutate(probability.event = 1-exp(-risk)) %>%
    mutate(n.events =  rbinom(n = 1:self$inputs$pop.size, size = self$inputs$trials, prob = probability.event))

  # Return an object.
  # You should avoid assigning things to the self object.
  # This object can be anything (a list, a data.frame), and will be stored in self$natural_history_results
  return(results)

}


crcspin_simulate_screening = function(self, ...) {

  population = self$natural_history_results

  # Use strategy characteristic to do something interesting:
  population$n.identified = rbinom(n = 1:nrow(population), size = population$n.events, prob = self$inputs$det.ratios[self$inputs$strategy.id])

  # Summarize information:
  summary = data.frame(total_identified = sum(population$n.identified),
                       total_events = sum(population$n.events)) %>%
    mutate(identified_per_person = total_identified/nrow(population))

  # Produce list of results with the population and a summary object.
  list(population = population, summary = summary)

}
