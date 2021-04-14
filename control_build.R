library(tidyverse)
library(lubridate)
library(foreach)

source("hysplit_batch_functions.R")

# start cluster
nb_cores <- 4  # Aurora has 96 cores
cl <- parallel::makeCluster(nb_cores)
doParallel::registerDoParallel(cl)

# EMITIMES file
emitimes_file <- "/home/shares/snapp-wildfire/HYSPLIT_samplefiles/EMITIMES_july"

# create folder name
my_folder_run <- "July"

# creating file folder
dir.create(my_folder_run)

# create CONTROL filename
filename <- file.path(my_folder_run, "CONTROL")

# copy the EMITIMES files
emitimes_run <- file.path(my_folder_run,"EMITIMES")
file.copy(emitimes_file, emitimes_run, overwrite = TRUE)

# copy SETUP
create_setup <- create_setup(my_folder_run)

# Get information from EMITIMES
control_info <- read_emitimes(emitimes_run)

# Create the CONTROL file
create_control(filename, control_info$date, control_info$locations, control_info$runtime)

#### Run the model #####

# stop cluster
parallel::stopCluster(cl)
