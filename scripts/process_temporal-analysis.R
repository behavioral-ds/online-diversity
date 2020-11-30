#!/usr/bin/Rscript
source("scripts/utils.R")
library ('DescTools')

datasets <- c("reddit", "twitter")
dir.create('data', showWarnings = FALSE)

DATE_AS_COLNAME <- 'X%Y.%m.%d'

for (fn_name in datasets) {
  # ds_loc <- datasets[2]
  current_function <- load_dataset(datasetname = fn_name)
  print (sprintf ('loaded %s... getting the table', fn_name))
  
  column_labels <- as.Date (colnames (current_function), DATE_AS_COLNAME)
  print (column_labels)
  first_date_index <- which (!is.na (column_labels))[1]
  
  last_date_index <- ncol (current_function)
  
  ## remove domains that never appear
  current_function$total <- rowSums(current_function[, first_date_index:last_date_index])
  current_function <- current_function[ current_function$total > 0,]
  
  rows_first_appearance_index <- apply (current_function [, first_date_index:last_date_index], 1, function (x) {which (x!=0)[1]})
  rows_first_appearance_index_absolute <- rows_first_appearance_index + first_date_index - 1
  
  # Every single column in which a species has appeared.
  unique_appearance_indices <- unique (rows_first_appearance_index)
  # Now we add the offset since our first appearance indices was starting from firsT_date_index
  unique_appearance_indices = unique_appearance_indices + first_date_index - 1
  # Years in which at least one species have appeared
  years <- format (as.Date (column_labels [unique_appearance_indices]), '%Y')
  unique_years <- unique (years)
  # Get rid of NAs
  print (unique_years)
  unique_years <- unique_years [!is.na (unique_years)]
  HHI_clusters <- list ()
  links_clusters <- list ()
  survival_clusters <- list ()
  active_species_clusters <- list ()
  survival_clusters2 <- list ()
  top_names <- list ()
  
  max_length <- 0
  print (unique_years)
  print (sort (unique_years))
  for (current_year in sort (unique_years)) {
    # current_year <- unique_years[1]
    # Indices of every species that has appeared in this year
    year_indices <- which (years == current_year)
    # - begin.index + 1 added for test
    # Our column indices plus the offset [begin.index]
    relative_appearance_indices <- unique_appearance_indices [year_indices] - first_date_index + 1
    
    first_appearance_column <- min (relative_appearance_indices) + first_date_index - 1
    # print (sprintf ("%i <- first col index", first_column_index))
    # Rows that appeared in current year for the first time. i.e. new-born species
    row_indices <- which (rows_first_appearance_index %in% relative_appearance_indices)
    
    HHI <- c ()
    links <- c ()
    # survival_rate <- c ()
    active_species <- c ()
    survival_rate2 <- c ()
    top_player <- c ()
    
    # Sanity check
    # Going through the columns, why is col 13 different?! New year, new data?!
    # library ('matrixStats')
    # > colCounts (current_function [row_indices, first_column_index:end.index] == 0)
    # + colCounts (current_function [row_indices, first_column_index:end.index] > 0)
    # will return the same thing
    
    ## get effectives per month
    effectives_month <- table(rows_first_appearance_index_absolute[row_indices])
    print (sprintf ("year --> %s", current_year))
    ## column_index is absolute
    for (column_index in first_appearance_column:last_date_index) {
      # column_index <- first_appearance_column
      
      # if (first_appearance_column+12 > last_date_index) next ## MAR: disabled because going back to observing the initial year
      print (sprintf ("%i <- current col index", column_index))
      # 			print (sprintf ("%i <- current col index", column_index - first_appearance_column + 1))
      ## get total number of domains in the cohort at current time
      no_domains <- length (row_indices)
      # Denominator set to all the domains come to live so far
      if (column_index %in% as.numeric(names(effectives_month)))
        no_domains <- sum (effectives_month[as.numeric (names (effectives_month)) <= column_index ])
      
      HHI = c (HHI, Herfindahl (x = unlist(current_function [row_indices, column_index])) )
      links = c (links, sum (current_function [row_indices, column_index]))
      no_of_active_domains <- sum (current_function [row_indices, column_index] > 0)
      # print (sprintf ("number of active domains %s", no_of_active_domains))
      active_species = c (active_species, no_of_active_domains)
      survival_rate2 = c (survival_rate2, no_of_active_domains/no_domains)
      print (sprintf ("active domains: %i/all domains:%i -> %f", no_of_active_domains,
                      no_domains, no_of_active_domains/no_domains))
      top_player = c (top_player, as.character (current_function$Domain[row_indices][which.max( unlist(current_function [row_indices, column_index]))])) 
      # print (sprintf ("%f <- survival rate 2", survival_rate2))
      # print (sprintf ("%i <- number of domains", no_domains))
      # print (no_of_active_domains/no_domains)
      # print (sprintf ("%i <- no of active domains", no_of_active_domains))
    }
    
    links_clusters [[current_year]] = as.vector (links)
    HHI_clusters [[current_year]] = as.vector (HHI)
    active_species_clusters [[current_year]] = as.vector (active_species)
    survival_clusters2 [[current_year]] = as.vector (survival_rate2)
    top_names [[current_year]] = as.vector (top_player)
    
    birth_indices <- apply (as.matrix (current_function [row_indices, first_appearance_column:last_date_index]), M = 1, function (x) head (which (x > 0), 1))
    death_indices <- apply (as.matrix (current_function [row_indices, first_appearance_column:last_date_index]), M = 1, function (x) tail (which (x > 0), 1))
    
    survival <- death_indices - birth_indices + 1
    max_survival <- max (survival)
    if (max_survival > max_length) max_length = max_survival
    # nrows <- length (survival)
    # survival_matrix <- matrix (data = FALSE, ncol = max_survival, nrow = nrows)
    population <- length (survival)
    
    # for (i in 1:max_survival) {
    # 	survival_rate <- c (survival_rate, length (which (survival >= i))/population)
    # }
    # # survival_clusters [[current_year]] <- as.vector (survival_rate)
  }
  max_columns <- max (unlist (lapply (FUN = length, HHI_clusters)))
  # assign ('survival_clusters1', survival_clusters, globalenv())
  for (i in 1:length (HHI_clusters)) {
    elem = HHI_clusters [[i]]
    remaining_zeros <- max_columns - length (elem)
    HHI_clusters [[i]] = c (elem, rep (NA, remaining_zeros))
    links_clusters [[i]] = c (links_clusters [[i]], rep (NA, remaining_zeros))
    active_species_clusters [[i]] = c(active_species_clusters [[i]], rep (NA, remaining_zeros))
    survival_clusters2 [[i]] = c(survival_clusters2 [[i]], rep (NA, remaining_zeros))
    # survival_clusters [[i]] = c (survival_clusters [[i]], rep (NA, max_length - length (survival_clusters [[i]])))
    top_names [[i]] = c (top_names [[i]], rep (NA, remaining_zeros))
  }
  
  column_names <- sprintf ("Month %i", seq (1, max_columns))
  HHI_clusters = do.call ('rbind', HHI_clusters)
  HHI_clusters = HHI_clusters [, 1:ncol (HHI_clusters)]
  links_clusters = do.call ('rbind', links_clusters)
  links_clusters = links_clusters [, 1:ncol (links_clusters)]
  active_species_clusters = do.call ('rbind', active_species_clusters)
  survival_clusters2 = do.call ('rbind', survival_clusters2)
  # assign ('survival_clusters2', survival_clusters, globalenv())
  # survival_clusters = do.call ('rbind', survival_clusters)
  # assign ('survival_clusters3', survival_clusters, globalenv())
  #	survival_clusters = survival_clusters [, 1:ncol (survival_clusters)]
  top_names = do.call ('rbind', top_names)
  
  max_hhi_x <- max (HHI_clusters, na.rm = TRUE)
  max_links_x <- max (links_clusters, na.rm = TRUE)
  # max_surivival_x <- max (survival_clusters, na.rm = TRUE)
  max_active_species <- max (active_species_clusters, na.rm = TRUE)
  max_surivival_x_2 <- max (survival_clusters2, na.rm = TRUE)
  
  colnames (HHI_clusters) <- column_names
  colnames (links_clusters) <- column_names
  # colnames (survival_clusters) <- column_names
  colnames (active_species_clusters) <- column_names
  colnames (survival_clusters2) <- column_names
  colnames (top_names) <- column_names
  
  colors <- unique (rainbow (nrow (HHI_clusters)))
  current_file <- file (sprintf('data/%s_cohort_analysis.dat', fn_name), 'wb')
  files_list <- c ('HHI_clusters', 'links_clusters', 'active_species_clusters', 'survival_clusters2', 'top_names')#, 'survival_clusters',)
  save (list = files_list, file = current_file)
  close (current_file)
}