#' This script loops through a series of runs of the HYSPLIT model

## Libraries
library(tidyverse)
library(lubridate)
library(foreach)


## Paths and files
shared_dir <- "/home/shares/snapp-wildfire/HYSPLIT_samplefiles/"
run_dir <- "~/run2"
# folder to save model files in your home directory
dir.create(run_dir, showWarnings = FALSE)


# Move the files you need to run the model
file.copy(file.path(shared_dir,"ASCDATA.CFG"), run_dir, overwrite = TRUE)
file.copy(list.files(path = shared_dir, pattern = ".ARL", full.names = TRUE), run_dir, overwrite = FALSE) # To be changed as we do not want to move those files around

## Start cluster
nb_cores <- 12  # Aurora has 96 cores
cl <- parallel::makeCluster(nb_cores)
doParallel::registerDoParallel(cl)


## Prepare the list of dates to iterate through
# EMITIMES file
# emitimes_file <- file.path(shared_dir,"EMITIMES_july")

# For the example using the same EMITIMES
# fake_dates <- seq(ymd('2012-01-07'), ymd('2012-12-22'), by = '1 month')

# list of ARL files
arl_files <- c("June", "July", "Aug")


## MAIN loop
foreach(model_run = arl_files) %dopar% {
  # setwd("/home/klope/R/hysplit-batch")
  # source(file.path("/home/klope/R/hysplit-batch","hysplit_batch_functions.R"))
  source(file.path(getwd(),"hysplit_batch_functions.R"))

  # copy the EMITIMES files
  emitimes_file <- file.path(shared_dir, paste0("EMITIMES_", tolower(model_run)))
  emitimes_run <- file.path(run_dir, paste0("EMITIMES", ".", model_run))
  file.copy(emitimes_file, emitimes_run, overwrite = TRUE)

  # copy SETUP
  create_setup <- create_setup(run_dir, extension = model_run, dir_templates =  "/home/klope/run2/file_templates/")

  # Get information from EMITIMES
  control_info <- read_emitimes(emitimes_run)
  control_locations <- control_info$locations %>%
    dplyr::select(LAT, LON)

  # Create the CONTROL file
  # control_filename <- file.path(run_dir, "CONTROL")
  control_filename <- file.path("/home/klope/run2", "CONTROL")
  create_control(control_filename,
                 control_info$date,
                 control_locations,
                 control_info$runtime,
                 arl_file = paste0(model_run, ".ARL"),
                 "./",
                 extension = model_run,
                 dir_templates =  "/home/klope/run2/file_templates/")


  #### Run the model #####
  repo <- getwd()
  setwd(run_dir)
  system(sprintf("../hysplit/5.0.0/exec/hycs_std %s", model_run))
  setwd(repo)

}

# stop cluster
parallel::stopCluster(cl)



# running the model
# setwd("/home/klope/run")
# system("../hysplit/5.0.0/exec/hycs_std")
