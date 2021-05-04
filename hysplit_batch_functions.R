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
  # read locations from EMITIMES file
  my_locations <- read_delim(emitimes_file, delim = " ", skip = 1) %>% # skip = 1 to remove header info for the other data
    slice(-1) %>% # removing the first row that contains the other information
    dplyr::select(!(X13)) # removing blank column

  # Compute the runtime duration
  my_locations <- my_locations %>%
    mutate(date = make_date(YYYY, MM, DD)) # changing object class to Date

  int <- interval(min(my_locations$date), max(my_locations$date) + 1) # +1 because we want to include the last day
  my_runtime <- (time_length(int, "day") + 7) * 24 # We run the model 7 days after the last fire observation and transform to hours

  # creating record line from EMITIMES file
  records <- read_delim(emitimes_file, delim = " ") %>%
    slice(2) %>%  # only selecting first row with the correct information
    dplyr::select(!(X7))

  # get date from EMI file
  my_date <- records %>%
    mutate(YYYY = substr(YYYY, nchar(YYYY) - 1, nchar(YYYY))) %>%  # converting YYYY into just the last two digits of the year
    select(YYYY, MM, DD, HH) %>% # selecting columns to merge
    unite("date", YYYY:HH, sep = " ") %>% # merging and separating by a space
    pull() # we want a character

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
  control_file <- "CONTROL_template"
  control_path <- file.path(dir_templates, control_file)
  # out_full <- out_file # file.path("output", out_file)
  out_full <- paste0(out_file, ".", extension)
  out_conn <- file(out_full) # how to create file in R that you write line-by-line

  # Read control file in
  control_lines <- readLines(control_path) # reading in template

  # Create the parameters
  nb_fire <- as.character(nrow(locations))

  writeLines(c(date, nb_fire), out_conn) # how you write lines for vectors. Date as one line, number fire as one line, written to out_conn file
  close(out_conn) # closing the file

  # Add lat long to file
  write.table(locations, out_full, row.names = FALSE, col.names = FALSE, append=TRUE) # adding a table

  # adding .ARL file (model forcing) and file path to ARL file
  write(c("0", "10000.0 ", "1", arl_dir, arl_file), out_full, append = TRUE) # the lines 0, 10000.0, and 1 would have just been in the template, but it was easier not to have to split up

  # Add runtime
  write(runtime, out_full, append = TRUE)

  # Add template
  write(control_lines, out_full, append = TRUE) # Writing content of template is different because it's a block of text


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
  setup_file <- "SETUP_template.CFG"
  setup_path <- file.path(dir_templates, setup_file)

  # copy the EMITIMES files
  file.copy(setup_path, file.path(folder_run, paste0("SETUP.CFG", ".", extension)), overwrite = TRUE)

}
