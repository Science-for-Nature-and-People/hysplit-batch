
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
create_control <- function(out_file, date, locations, runtime, dir_templates="file_templates/") {

  # Build paths
  control_file <- "CONTROL_template"
  control_path <- file.path(dir_templates, control_file)
  out_full <- out_file #file.path("output", out_file)
  out_conn <- file(out_full) # how to create file in R that you write line-by-line

  # Read control file in
  control_lines <- readLines(control_path) # reading in template

  # Create the parameters
  nb_fire <- as.character(nrow(locations))

  writeLines(c(date, nb_fire), out_conn) # how you write lines for vectors. Date as one line, number fire as one line, written to out_conn file
  close(out_conn) # closing the file

  # Add lat long to file
  write.table(locations, out_full, row.names = FALSE, col.names = FALSE, append=TRUE) # adding a table

  # Add runtime
  write(runtime, out_full, append = TRUE)

  # Add template
  write(control_lines, out_full, append = TRUE) # Writing content of template is different because it's a block of text
}
