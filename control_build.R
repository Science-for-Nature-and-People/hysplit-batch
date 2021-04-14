library(tidyverse)

source("hysplit_batch_functions.R")



# create folder name
folder_name <- "July"
# creating file folder
dir.create(folder_name)

# create file name
filename <- "CONTROL_june"

# read EMITIMES file
locations <- read_delim("/home/shares/snapp-wildfire/HYSPLIT_samplefiles/EMITIMES_july", delim = " ", skip = 1) %>% # skip = 1 to remove header info for the other data
  slice(-1) %>% # removing the first row that contains the other information
  dplyr::select(!(X13)) # removing blank column

records <- read_delim("/home/shares/snapp-wildfire/HYSPLIT_samplefiles/EMITIMES_july", delim = " ") %>%
  slice(2) %>%  # only selecting first row with the correct information
  dplyr::select(!(X7))

# get date from EMI file
july_date <- records %>%
  mutate(YYYY = substr(YYYY, nchar(YYYY) - 1, nchar(YYYY))) %>%  # converting YYYY into just the last two digits of the year
  select(YYYY, MM, DD, HH) %>% # selecting columns to merge
  unite("date", YYYY:HH, sep = " ") # merging and separating by a space

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
# create_control(filename, june_date, my_locations)


