library(tidyverse)

#' Create the CONTROL file for the HYSPLIT model
#'
#' @param out_file
#' @param date
#' @param locations
#'
#' @return
#' @export
#'
#' @examples
#'

# creating directory (might move to inside function)
# create folder name
folder_name <- "July"
# creating file folder
dir.create(folder_name)

create_control <- function(out_file, date, locations, dir_templates = "file_templates/", dir_save = "July") {

  # Build paths
  control_file <- "CONTROL_template"
  control_path <- file.path(dir_templates, control_file)
  out_full <- file.path(dir_save, out_file) # saves to the file path you choose (currently set to July)
  out_conn <- file(out_full) # how to create file in R that you write line-by-line

  # Read control file in
  control_lines <- readLines(control_path) # reading in template

  # Create the parameters
  nb_fire <- nrow(locations)

  writeLines(c(date, nb_fire), out_conn) # how you write lines for vectors. Date as one line, number fire as one line, written to out_conn file
  close(out_conn) # closing the file

  # Add lat long to file
  write.table(locations, out_full, row.names = FALSE, col.names = FALSE, append=TRUE) # adding a table

  # Add template
  write(control_lines, out_full, append = TRUE) # Writing content of template is different because it's a block of text
}

# create file name
filename <- "CONTROL_july"

# read EMITIMES file
my_locations <- read_delim("/home/shares/snapp-wildfire/HYSPLIT_samplefiles/EMITIMES_july", delim = " ", skip = 1) %>% # skip = 1 to remove header info for the other data
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

july_date <- as.character(july_date[1])

# Call the function
create_control(filename, july_date, my_locations)



