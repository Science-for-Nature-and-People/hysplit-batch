create_control <- function(out_file, date, locations, arl_file, arl_dir, dir_templates = "file_templates/", extension, dir_save = "July") {

  # Build paths
  control_file <- "CONTROL_template"
  control_path <- file.path(dir_templates, control_file)
  out_full <- file.path(dir_save, paste0(out_file, extension)) # saves to the file path you choose (currently set to July)
  out_conn <- file(out_full) # how to create file in R that you write line-by-line

  # Read control file in
  control_lines <- readLines(control_path) # reading in template

  # Create the parameters
  nb_fire <- nrow(locations)

  writeLines(c(date, nb_fire), out_conn) # how you write lines for vectors. Date as one line, number fire as one line, written to out_conn file
  close(out_conn) # closing the file

  # Add lat long to file
  write.table(locations, out_full, row.names = FALSE, col.names = FALSE, append=TRUE) # adding a table

  # adding ARl file & file path information
  write(c("0", "10000.0 ", "1", arl_dir, arl_file), out_full, append = TRUE)

  # Add template
  write(control_lines, out_full, append = TRUE) # Writing content of template is different because it's a block of text

}

# Call the function
create_control(filename, july_date, my_locations, arl_file = arl, arl_dir = file_path_arl, extension = ".001")

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

arl <- "JunJuly.ARL"
file_path_arl <- "c:\\hysplit4\\met\\2019\\Jun_July\\"

# changing the cdump
# Build paths
control_file_1 <- "CONTROL_template_1"
control_file_2 <- "CONTROL_template_2"
control_path_1 <- file.path("file_templates/", control_file_1)
control_path_2 <- file.path("file_templates/", control_file_2)
out_full <- file.path("July", paste0(filename, ".001")) # saves to the file path you choose (currently set to July)
out_conn <- file(out_full) # how to create file in R that you write line-by-line

# Read control file in
control_lines_1 <- readLines(control_path_1) # reading in template
control_lines_2 <- readLines(control_path_2)

# Create the parameters
nb_fire <- nrow(my_locations)

writeLines(c(july_date, nb_fire), out_conn) # how you write lines for vectors. Date as one line, number fire as one line, written to out_conn file
close(out_conn) # closing the file

# Add lat long to file
write.table(my_locations, out_full, row.names = FALSE, col.names = FALSE, append=TRUE) # adding a table

# adding ARl file & file path information
write(c("0", "10000.0 ", "1", file_path_arl, arl), out_full, append = TRUE)

# Add template part 1
write(control_lines_1, out_full, append = TRUE) # Writing content of template is different because it's a block of text

# adding cdump with extension
write(paste0("cdump", ".", "001"), out_full, append = TRUE)

# adding template part 2
write(control_lines_2, out_full, append = TRUE)


