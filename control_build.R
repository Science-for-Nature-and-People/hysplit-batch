library(tidyverse)
library(lubridate)
library(foreach)



# start cluster
nb_cores <- 4  # Aurora has 96 cores
cl <- parallel::makeCluster(nb_cores)
doParallel::registerDoParallel(cl)

# EMITIMES file
emitimes_file <- "/home/shares/snapp-wildfire/HYSPLIT_samplefiles/EMITIMES_july"

# For the example using the same EMITIMES
fake_dates <- seq(ymd('2012-01-07'),ymd('2012-12-22'), by = '1 month') %>% month() %>% paste0("run_", .) %>% file.path(getwd(),.)


foreach(my_folder_run = fake_dates) %dopar% {
  source(file.path(getwd(),"hysplit_batch_functions.R"))

  # creating file folder
  dir.create(my_folder_run)

  # copy the EMITIMES files
  emitimes_run <- file.path(my_folder_run,"EMITIMES")
  file.copy(emitimes_file, emitimes_run, overwrite = TRUE)

  # copy SETUP
  create_setup <- create_setup(my_folder_run)

  # Get information from EMITIMES
  control_info <- read_emitimes(emitimes_run)

  # Create the CONTROL file
  control_filename <- file.path(my_folder_run, "CONTROL")
  create_control(control_filename, control_info$date, control_info$locations, control_info$runtime)

  #### Run the model #####

}

# stop cluster
parallel::stopCluster(cl)
