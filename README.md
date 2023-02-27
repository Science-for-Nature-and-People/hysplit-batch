# hysplit-batch

Claire Schollaert, Jihoon Jung, Julien Brun and Maggie Klope.

## Project Summary

This set of scripts was developed for the [SNAPP Wildfires and Human Health](https://snappartnership.net/teams/wildfires-and-human-health/) working group. Tha aim is to parralellize the run of the [HYSPLIT model](https://www.arl.noaa.gov/hysplit/) across the forcing files.

## Content

The main workflow is described in the Rmd file [hysplit.Rmd](hysplit.Rmd). Note it is assumed this will be ran on [NCEAS](https://www.nceas.ucsb.edu/) analytical server. Paths will have to be adapated accordingly to run on other machines.

This main Rmarkdown document relies on specialized functions that have been stored in [hysplit_batch_functions.R](hysplit_batch_functions.R)



