library(tidyverse)
library(lubridate)



#' Read EMITIMES file and extract necessary information to create the CONTROL file
#'
#' @param emitimes_file
#'
#' @return
#' @export
#'
#' @examples
#'
read_emitimes <- function(emitimes_file) {
  rundays_afterlastfire <- 15    # We run the model 15 days after the last fire observation

  # read locations from EMITIMES file
  my_locations <- read_delim(emitimes_file, delim = " ", skip = 1) %>% # skip = 1 to remove header info for the other data
    slice(-1)   # removing the first row that contains the other information

  # Compute the runtime duration
  my_locations <- my_locations %>%
    mutate(date = make_date(YYYY, MM, DD)) # changing object class to Date

  my_int <- interval(min(my_locations$date), max(my_locations$date) + 1) # +1 because we want to include the last day
  my_runtime <- (time_length(my_int, "day") + rundays_afterlastfire) * 24 # We add 15 days after the last fire observation and transform to hours

  # creating record line from EMITIMES file
  records <- read_delim(emitimes_file, delim = " ") %>%
    slice(2)   # only selecting first row with the correct information

  # get date from EMI file
  my_date <- records %>%
    mutate(YYYY = substr(YYYY, nchar(YYYY) - 1, nchar(YYYY))) %>%  # converting YYYY into just the last two digits of the year
    select(YYYY, MM, DD, HH) %>% # selecting columns to merge
    unite("date", YYYY:HH, sep = " ") %>% # merging and separating by a space
    pull() # we want a character

  # Keep only unique locations among the multiple pollutants
  my_locations <- my_locations %>%
    select(LAT, LON, `HGT(m)`) %>%
    unique()

  # output as a list
  list(locations = my_locations,
       runtime = my_runtime,
       date = my_date)
}


#######################################################################################################################

#' Create the CONTROL file for the HYSPLIT model
#'
#' @param out_file
#' @param date
#' @param locations
#' @param runtime
#' @param dir_templates
#'
#' @return
#' @export
#'
#' @examples
#'

# extension_list <- c(".001", ".002", ".003", ".004", ".005")

create_control <- function(out_file, date, locations, runtime, arl_file, arl_dir, extension, dir_templates = "file_templates/") {

  # Build paths
  control_file_1 <- "CONTROL_template_p1"
  control_file_2 <- "CONTROL_template_p2"
  control_file_grid <- "CONTROL_template_grid"
  control_file_end <- "CONTROL_template_end"
  control_path_1 <- file.path(dir_templates, control_file_1)
  control_path_2 <- file.path(dir_templates, control_file_2)
  control_path_g <- file.path(dir_templates, control_file_grid)
  control_path_e <- file.path(dir_templates, control_file_end)

  # out_full <- out_file # file.path("output", out_file)
  out_full <- paste0(out_file,".", extension)
  out_conn <- file(out_full) # how to create file in R that you write line-by-line

  # Read control file templates in
  control_lines_1 <- readLines(control_path_1)
  control_lines_2 <- readLines(control_path_2)
  control_lines_g <- readLines(control_path_g)
  control_lines_e <- readLines(control_path_e)

  # Compute the number of locations
  nb_fire <- as.character(nrow(locations))

  # Write the first 2 lines of the file
  writeLines(c(date, nb_fire), out_conn) # how you write lines for vectors. Date as one line, number fire as one line, written to out_conn file
  close(out_conn) # closing the file

  # Add lat long height to file
  write.table(locations, out_full, row.names = FALSE, col.names = FALSE, append=TRUE) # adding a table

  # Add runtime
  write(runtime, out_full, append = TRUE)

  #number of files (should be 12 as we are running montly for a year)
  nb_files <- length(arl_file)
  if (nb_files != 12)

  # adding .ARL file (model forcing) and file path to ARL file
  write(c("0", "10000.0", nb_files), out_full, append = TRUE) # the lines 0, 10000.0, and 1 could have just been in the template, but it was easier not to have to split up

  # adding the files and paths
  write(rbind("/.", arl_file), out_full, append = TRUE)

  # Add template pollutant 1
  write(c(control_lines_1, date), out_full, append = TRUE) # Writing content of template is different because it's a block of text

  # Add template pollutant 2
  write(c(control_lines_2, date), out_full, append = TRUE)

  # Append the grid info
  write(control_lines_g, out_full, append = TRUE)

  # Add cdump with extension
  # write(paste0("cdump", ".", extension), out_full, append = TRUE)
  write(paste0("cdump.", extension), out_full, append = TRUE)

  # adding the last template part
  write(control_lines_e, out_full, append = TRUE)

}

#######################################################################################################################

#' Create the SETUP file for the HYSPLIT model
#'
#' @param folder_run
#' @param dir_templates
#'
#' @return
#' @export
#'
#' @examples
#'
create_setup <- function(folder_run, extension, dir_templates="file_templates/") {

  # Build paths
  setup_template <- "SETUP_template.CFG"
  setup_path <- file.path(dir_templates, setup_template)
  file.copy(setup_path, file.path(folder_run, paste0("SETUP.", extension)), overwrite = TRUE)

  # Output filename
  setup_file <- file.path(folder_run, paste0("SETUP.", extension))

  # Add lines
  write(paste0("efile = 'EMITIMES", ".", extension,"'"), setup_file, append = TRUE)
  write("/", setup_file, append = TRUE)

  # copy the EMITIMES files
  # file.copy(setup_path, file.path(folder_run, paste0("SETUP.", extension)), overwrite = TRUE)
  # file.copy(setup_path, file.path(folder_run, "SETUP"), overwrite = TRUE)

}

