#!/bin/bash/Rscript
# This file produces the 'competitors-merged.dat' for fig5
source("scripts/utils.R")

twelve_services <- read.csv("data/competitors-across-12-functions.csv", stringsAsFactors = FALSE, check.names=FALSE, strip.white = T) %>%
  arrange(Company)

# Delete the Year column
year_index <- which (colnames (twelve_services) == 'Year')
if (length (year_index) > 0) twelve_services = twelve_services [, - (year_index)]

# Get rid of Amazon video for now
twelve_services = twelve_services [-(which (twelve_services$Company == 'Amazon video')), ]

twelve_services$Website <- sub (x = twelve_services$Website, pattern = '\\s*', replacement = '')
twelve_services$Website <- sub (x = twelve_services$Website, pattern = '(http(s)?://)?(www.)?',
                                replacement = '')
twelve_services$Website <- sub (x = twelve_services$Website, pattern = "/.*",
                                replacement = "")

datasets <- c ('twitter', 'reddit')

get_rows <- function (table, field, pattern) {
  print ('indices')
  indices <- grep (table [, field], pattern = sprintf ('(?<![a-zA-Z0-9\\/])%s(?![\\.a-zA-Z1-9])', pattern), perl = TRUE)
  # print (indices)
  if (length (indices) == 0) return (NA)
  domain_index <- which (colnames (table) == field)
  return ( t(cbind (colSums (table [indices, -(domain_index)]))))
}

for (ds in datasets) {
  print (ds)
  table_name <- sprintf ('%s_%s', 'services', ds)
  table <- twelve_services
  dataset <- load_dataset(datasetname = ds)
  links <- list ()
  rows_to_be_deleted <- list ()
  for (row in 1:nrow (table)) {
    # print (sprintf ('row %s', row))
    website <- table [row, 'Website']
    website_index <- which (colnames (dataset) == 'Domain')
    # We can get rid of single dots in urls as urls can come at the end of sentences?!
    index <- which (dataset [, website_index] == website)
    if (length (index) == 0) {
      rows_to_be_deleted = c (rows_to_be_deleted, row)
      next
    }
    columns_extended <- dataset [index, -(website_index)]
    links [[row]] <- as.vector (columns_extended)
  }
  # Delete if there's no row for the species in our dataset
  if (length (rows_to_be_deleted) > 0) {
    table = table [- unlist (rows_to_be_deleted),]
    links = links [- unlist (rows_to_be_deleted)]
  }
  # Now bind them
  assign ('links', links, globalenv())
  columns_extended <- do.call ('rbind', links)
  assign ('columns_extended', columns_extended, globalenv())
  # colnames (columns_extended) <- format (as.Date(colnames (columns_extended), variables$DATE_AS_COLNAME))
  table = cbind (table, columns_extended)
  assign (table_name, table, globalenv())
}
# Now break the lists.

# Get rid of everything
rm (list = ls () [!ls () %in% ls (pattern = 'services_')])
# Get the categories
cats <- unique (get (ls ()[1])[, 'Category'])

services <- ls (pattern = 'services_')
for (service in services) {
  ds_name <- unlist (strsplit (service, split = '_'))[2]
  table <- get (service)
  for (category in cats) {
    indices <- which (table [, 'Category'] == category)
    new_table <- table [indices, ]
    cat_name <- sprintf ('%s_%s', category, ds_name)
    assign (cat_name, new_table, globalenv())
  }
}

rm (list = ls () [which (!ls () %in% ls (pattern = capture.output (cat(cats, sep = '|'))))])

functions <- file ('data/competitors-merged.dat', 'wb')
save (list = ls () [! ls () %in% 'functions'], file = functions)
close (functions)