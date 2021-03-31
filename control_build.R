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
create_control <- function(out_file, date, locations, dir_templates="file_templates/") {

  # Build paths
  control_file <- "CONTROL_template"
  control_path <- file.path(dir_templates, control_file)
  out_conn <- file(out_file)

  # Read control file in
  control_lines <- readLines(control_path)

  # Create the parameters
  nb_fire <- nrow(locations)

  writeLines(c(date, nb_fire), out_conn)
  close(out_conn)

  # Add lat long to file
  write.table(locations, out_file, row.names = FALSE, col.names = FALSE, append=TRUE)

  # Add template
  write(control_lines, out_file, append = TRUE)
}


### Example ----
filename <- "CONTROL_june"

june_date <- "19 06 10 00"

# Location might be more useful as a dataframe?
my_locations <- tribble(
  ~Lat, ~Long, ~other,
  39.22878346, -120.9402188, 0.0,
  39.18800813, -120.9784586, 0.0,
  39.02006513, -120.4958493, 0.0,
  39.2990171, -120.3189658, 0.0,
  39.16041885, -120.6598364, 0.0,
  39.01209315, -120.5446328, 0.0
)

create_control(filename, june_date, my_locations)
