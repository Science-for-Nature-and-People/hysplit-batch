library(tidyverse)
library(lubridate)
library(foreach)

# folder to save model files
dir.create("/home/klope/run")

# set working directory
setwd("/home/klope/run")

# start cluster
nb_cores <- 4  # Aurora has 96 cores
cl <- parallel::makeCluster(nb_cores)
doParallel::registerDoParallel(cl)

# EMITIMES file
emitimes_file <- "/home/shares/snapp-wildfire/HYSPLIT_samplefiles/EMITIMES_july"

# For the example using the same EMITIMES
fake_dates <- seq(ymd('2012-01-07'),ymd('2012-12-22'), by = '1 month') %>% month() %>% paste0("run_", .) %>% file.path(getwd(),.)

# # create extension list
# extensions <- seq(0, (length(fake_dates)/1000), by = 0.001)

foreach(model_run = fake_dates) %dopar% {
  setwd("/home/klope/R/hysplit-batch")
  source(file.path("/home/klope/R/hysplit-batch","hysplit_batch_functions.R"))
  # source(file.path(getwd(),"hysplit_batch_functions.R"))

  # copy the EMITIMES files
  # emitimes_run <- file.path("/home/klope/run","EMITIMES")
  # file.copy(emitimes_file, emitimes_run, overwrite = TRUE)
  file.copy(emitimes_file, file.path("/home/klope/run", "EMITIMES"), overwrite = TRUE)

  # copy SETUP
  create_setup <- create_setup("/home/klope/run", extension = "")

  # Get information from EMITIMES
  control_info <- read_emitimes(emitimes_run)
  control_locations <- control_info$locations %>%
    dplyr::select(LAT, LON)

  # Create the CONTROL file
  control_filename <- file.path("/home/klope/run", "CONTROL")
  create_control(control_filename, control_info$date, control_locations, control_info$runtime, "July.ARL", "/home/klope/run/", extension = "")

  #### Run the model #####
  setwd("/home/klope/run")
  system("../hysplit/5.0.0/exec/hycs_std")

}

# stop cluster
parallel::stopCluster(cl)

# running the model
# setwd("/home/klope/run")
# system("../hysplit/5.0.0/exec/hycs_std")
