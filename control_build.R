library(tidyverse)
library(lubridate)
library(foreach)

source("hysplit_batch_functions.R")



# EMITIMES file
emitimes_file <- "/home/shares/snapp-wildfire/HYSPLIT_samplefiles/EMITIMES_july"

# create folder name
folder_run <- "July"

# creating file folder
dir.create(folder_run)

# create CONTROL filename
filename <- file.path(folder_run, "CONTROL")

# create CONTROL filename
filename <- file.path(folder_run, "SETUP")

# copy the EMITIMES files
file.copy(emitimes_file, file.path(folder_run,"EMITIMES"))




# read EMITIMES file
my_locations <- read_delim(emitimes_file, delim = " ", skip = 1) %>% # skip = 1 to remove header info for the other data
  slice(-1) %>% # removing the first row that contains the other information
  dplyr::select(!(X13)) # removing blank column

# Compute the runtime duration
my_locations <- my_locations %>%
  mutate(date = make_date(YYYY, MM, DD))

int <- interval(min(my_locations$date), max(my_locations$date) + 1) # +1 because we want to include the last day
my_runtime <- (time_length(int, "day") + 7) * 24 # We run the model 7 days after the last fire observation and transform to hours

records <- read_delim(emitimes_file, delim = " ") %>%
  slice(2) %>%  # only selecting first row with the correct information
  dplyr::select(!(X7))

# get date from EMI file
my_date <- records %>%
  mutate(YYYY = substr(YYYY, nchar(YYYY) - 1, nchar(YYYY))) %>%  # converting YYYY into just the last two digits of the year
  select(YYYY, MM, DD, HH) %>% # selecting columns to merge
  unite("date", YYYY:HH, sep = " ") %>% # merging and separating by a space
  pull() # we want a character

# my_locations <- tribble(
#   ~Lat, ~Long, ~other,
#   39.22878346, -120.9402188, 0.0,
#   39.18800813, -120.9784586, 0.0,
#   39.02006513, -120.4958493, 0.0,
#   39.2990171, -120.3189658, 0.0,
#   39.16041885, -120.6598364, 0.0,
#   39.01209315, -120.5446328, 0.0
# )

# # Call the function
create_control(filename, my_date, my_locations, my_runtime)


