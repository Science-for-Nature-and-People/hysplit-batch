#' This script loops through a series of runs of the HYSPLIT model

## Libraries
library(tidyverse)
library(lubridate)
library(foreach)


## Paths and files
aurora_user <- "klope" # user folder name on aurora
repo_dir <- file.path("/home", aurora_user, "R/hysplit-batch") # git repo directory
shared_dir <- "/home/shares/snapp-wildfire/HYSPLIT_samplefiles/"
run_dir <- "~/run2"
# folder to save model files in your home directory
dir.create(run_dir, showWarnings = FALSE)

# create simlink of .ARL files into the working directory (now set to run_dir folder)
system("ln -s /home/shares/snapp-wildfire/HYSPLIT_samplefiles/June.ARL June.ARL")
system("ln -s /home/shares/snapp-wildfire/HYSPLIT_samplefiles/July.ARL July.ARL")
system("ln -s /home/shares/snapp-wildfire/HYSPLIT_samplefiles/Aug.ARL Aug.ARL")

# Move the files you need to run the model
file.copy(file.path(shared_dir,"ASCDATA.CFG"), run_dir, overwrite = TRUE)
# file.copy(list.files(path = shared_dir, pattern = ".ARL", full.names = TRUE), run_dir, overwrite = FALSE) # To be changed as we do not want to move those files around

## Start cluster
nb_cores <- 12  # Aurora has 96 cores
cl <- parallel::makeCluster(nb_cores)
doParallel::registerDoParallel(cl)

# list of ARL files
arl_files <- c("June", "July", "Aug")

## MAIN loop
foreach(model_run = arl_files) %dopar% {
  source(file.path(repo_dir,"hysplit_batch_functions.R"))

  # copy the EMITIMES files
  emitimes_file <- file.path(shared_dir, paste0("EMITIMES_", tolower(model_run)))
  emitimes_run <- file.path(run_dir, paste0("EMITIMES", ".", model_run))
  file.copy(emitimes_file, emitimes_run, overwrite = TRUE)

  # copy SETUP
  create_setup <- create_setup(run_dir, extension = model_run, dir_templates =  file.path(repo_dir,"file_templates"))

  # Get information from EMITIMES
  control_info <- read_emitimes(emitimes_run)
  control_locations <- control_info$locations %>%
    dplyr::select(LAT, LON)

  # Create the CONTROL file
  control_filename <- file.path(run_dir, "CONTROL")
  create_control(control_filename,
                 control_info$date,
                 control_locations,
                 control_info$runtime,
                 arl_file = paste0(model_run, ".ARL"),
                 "./",
                 extension = model_run,
                 dir_templates =  file.path(repo_dir,"file_templates"))


  #### Run the model #####
  repo <- getwd()
  setwd(run_dir)
  system(sprintf("../hysplit/5.0.0/exec/hycs_std %s", model_run))
  setwd(repo)

}

# stop cluster
parallel::stopCluster(cl)
