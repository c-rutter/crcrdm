

rm(list = ls())
gc()

# Run these avery time:
n_iterations = 30
n_people = 1e7
with_lag = T
run_with_R6 = F


library(dplyr)

square_person_fn = function(person_df, n = n_people, record_lag = with_lag) {
  if(is.null(person_df)) {
    person_df = data.frame(person = 1:n/50, name = "person_name")
  } else {
    person_df$person = person_df$person ^ 2
    if(record_lag) {
      person_lag_col = ncol(person_df) + 1
      person_df[,paste0("l_",person_lag_col)] = person_df$person
    }
  }
  person_df
}

if(run_with_R6){
  # now trying the R6 way:
  square_person_R6_fn = function(self) {
    self$person <- square_person_fn(person_df = self$person)
    invisible(self)
  }


  my_model = R6::R6Class(classname = "my_model",
                         public = list(

                           person = NULL,

                           initialize = function(){
                             self$person = square_person_fn(person_df = NULL)
                           },

                           square_person = function() {
                             square_person_R6_fn(self)
                           }

                         )
  )


  peakRAM::peakRAM({

    model = my_model$new()

    for(i in 1:n_iterations) {

      model$square_person()$
        square_person()$
        square_person()$
        square_person()$
        square_person()$
        square_person()

      print(i)

    }

  })

} else {

  # Usual Test --------------------------------------------------------------

  peakRAM::peakRAM({

    person_df = square_person_fn(person_df = NULL)

    for(i in 1:n_iterations) {

      person_df = square_person_fn(person_df = person_df) %>%
        square_person_fn(person_df = .) %>%
        square_person_fn(person_df = .) %>%
        square_person_fn(person_df = .) %>%
        square_person_fn(person_df = .) %>%
        square_person_fn(person_df = .)

      print(i)

    }

  })

}







