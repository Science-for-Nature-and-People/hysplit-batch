library(tidyverse)


#' Create the SETUP file for the HYSPLIT model
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

create_setup <- function(out_file, date, locations, dir_templates = "file_templates/", dir_save = "July") {

  # Build paths
  setup_file <- "SETUP_template"
  setup_path <- file.path(dir_templates, setup_file)
  out_full <- file.path(dir_save, out_file) # saves to the file path you choose (currently set to July)
  out_conn <- file(out_full) # how to create file in R that you write line-by-line

  # Read control file in
  setup_lines <- readLines(setup_path) # reading in template

  # EMITIMES file name
  EMITMES <- "CONTROL_july"

  writeLines(c(date, nb_fire), out_conn) # how you write lines for vectors. Date as one line, number fire as one line, written to out_conn file
  close(out_conn) # closing the file

}

# create file name
filename <- "SETUP_july"

