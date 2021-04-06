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
create_setup <- function(out_file, date, locations, dir_templates="file_templates/") {

  # Build paths
  control_file <- "SETUPL_template"
  control_path <- file.path(dir_templates, control_file)
  out_conn <- file(out_file)
  #
  # # Read control file in
  # control_lines <- readLines(control_path)
  #
  # # Create the parameters
  # nb_fire <- nrow(locations)
  #
  # writeLines(c(date, nb_fire), out_conn)
  # close(out_conn)
  #
  # # Add lat long to file
  # write.table(locations, out_file, row.names = FALSE, col.names = FALSE, append=TRUE)
  #
  # # Add template
  # write(control_lines, out_file, append = TRUE)
}

control_file <- "SETUPL_template"
control_path <- file.path("file_templates/", control_file)
out_conn <- file("FILE_NAME")

control_lines <- readLines(control_path)
