

#------------------------------------------------------------------------------#
#
# CRCRDM: Robust Decision Making tools for Colorectal Cancer Screening Models
#
# Author: Pedro Nascimento de Lima
# See LICENSE.txt and README.txt for information on usage and licensing
#------------------------------------------------------------------------------#


#------------------------------------------------------------------------------#
# Evaluate CRC Experiments
# Purpose: The crcexperiment class represents an experiment of one or
# more crcmodels.
# Creation Date: July 2021
#------------------------------------------------------------------------------#

# Documented within the crc_experiment class.
# crcexperiment_run = function(self, sim_end_date, runs = 1:nrow(model$future_experimental_design), n_cores = parallel::detectCores() - 2, parallel_mode = "PSOCK", solver = "lsoda", write_csv = F, test_run = F) {
#
#   # If runs is missing, assume all runs:
#
#   ### Reducing the Model Object Size - This is Important to fully leverage parallelization ###
#   model$cal_results = model$cal_results %>%
#     filter(Date == max(Date))
#
#   model$cali_augm_results = model$cali_augm_results %>%
#     filter(Date == max(Date))
#
#   model$timeseriesnas = NULL
#
#   # Selecting only the latest date in the time series object:
#   model$timeseries = model$timeseries %>%
#     select(LocationID, Date, PositiveTests, PortfolioID, Population, MaxPortfolioID) %>%
#     filter(Date == max(Date))
#
#
#   cat_green_tick(paste(Sys.time(),"- Hold Tight. Running ", length(runs), "future scenario runs in Parallel with", n_cores, "cores."))
#   start_time = Sys.time()
#   cat_green_tick(start_time)
#
#   if(write_csv) {
#     write.csv(x = model$future_experimental_design,file = "./output/experimental_design.csv", row.names = F)
#     write.csv(x = model$scenarios, file = "./output/scenarios.csv", row.names = F)
#     write.csv(x = model$location, file = "./output/location.csv", row.names = F)
#   }
#
#   if(test_run) {
#     cat_green_tick(paste0(Sys.time(), " - Starting Test Run."))
#     scenarios_outputs = run_experiment(experiment_id = runs[1], model = model, sim_end_date = sim_end_date, solver = solver, write_csv = write_csv)
#   }
#
#   cl <- parallel::makeCluster(n_cores, type = parallel_mode)
#   set_up_cluster(cluster = cl, model = model, parallel_mode = parallel_mode)
#   # Original Apply:
#   #scenarios_outputs <- parLapply(cl = cl, X = selected_model$future_runs$ExperimentID,fun = run_future_scenario_rep, selected_model = filtered_model, sim_end_date = sim_end_date, solver = solver)
#   # Bcat_green_tick(paste(Sys.time(),"- Running Test experiment."))
#
#   # Parallel Implementation:
#   # Testing a Single Experiment:
#
#   scenarios_outputs <- pbapply::pblapply(cl = cl, X = runs,FUN = run_experiment, model = model, sim_end_date = sim_end_date, solver = solver, write_csv = write_csv)
#
#   stopCluster(cl)
#
#   finish_time = Sys.time()
#
#   cat_green_tick(finish_time)
#
#   cat_green_tick(paste0(Sys.time(), " - We're done with this simulation. Total time: ", finish_time - start_time, " for ", length(runs), " model runs."))
#
#   # Return all runs:
#   do.call(rbind, scenarios_outputs)
#
# }


# Runs a Single Experiment
#
# Runs a single Experiment defined by the set_experimental_design function. The experiment_id corresponds to the ExperimentID collumn in the future_experimental_design data.frame
#
# @param experiment_id The ExperimentID
#
# @return data.frame with simulation results.
# run_experiment = function(experiment_id) {
#
#   future_run = model$future_experimental_design %>%
#     dplyr::filter(ExperimentID == experiment_id)
#
#   run_id = future_run$RunID
#
#   # Set Stocks
#   model = model %>%
#     model$set_calibrated_stocks(., run_id)
#
#
#   # Set Time - Based on Initial Date:
#   final_date = lubridate::as_date(sim_end_date)
#   final_time = max(model$time) + as.integer(final_date - max(model$cal_results$Date))
#   model$time = (max(model$time)):final_time
#
#   #scenarios_results = run_single_future_run(scenarios_model, run_id = run_id, solver, ...)
#
#   locationid = model$scenarios$LocationID[model$scenarios$RunID == run_id]
#
#   # Set Selected Params and Stock Positions:
#   model = model %>%
#     filter_inputs(., location_ids = locationid, level = model$level) %>%
#     set_selected_params_for_run_id(.,run_id) %>%
#     model$set_stocks_positions(.)
#
#   # Bring experimental parameters to the parameter set:
#   model$params = cbind(model$params, future_run)
#
#   results = try(solve_model(model, run_id = run_id, solver = solver))
#
#   # Solve Model
#   #results = solve_model(model, run_id = run_id, solver = solver)
#
#   # Check if results is not an atomic object:
#   if(!(class(results)=="try-error")){
#     # Results can be a null object
#
#     results$LocationID = locationid
#     results$ExperimentID = experiment_id
#
#     # This function executes an user-defined function to process the results. This will replace the "compute augmented outputs" function which is used elsewhere.
#     # This allows more flexibility and allows us to tailor the output files for each application we want to have.
#     results = model$compute_experiment_output(results = results, model = model)
#
#     if(write_csv) {
#       # Trying to generate results as we go, within each core:
#       #write.csv(x = results, file = "./output/experimental_results.csv", append = T, row.names = F)
#       write.table(x = results, file = "./output/experimental_results.csv", append = T, row.names = F, sep = ",")
#     }
#
#     results
#
#   } else {
#     return(NULL)
#   }
#
#
#
# }
