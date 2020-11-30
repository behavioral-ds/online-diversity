#!/usr/bin/Rscript

source("scripts/utils.R")

# Crappy slow inefficient script. And did I mention slow?! Works on our small datasets
datasets <- c ('reddit', 'twitter') #, 'wikilinks')

# This is merely to sort the rows
# Not really needed
# for (ds_name in ds) {
# 	fn_list <- load (sprintf ('data/%s_cohort_analysis.dat', ds_name))
# 	for (table_name in fn_list) {
# 		if (table_name == 'ds')
# 			next
# 		table <- get (table_name)
# 		table = table [order (rownames (table)), ]
# 		assign (x = table_name, value = table, pos = -1)
# 	}
# 	current_file <- file (sprintf ('data/%s_cohort_analysis.dat', ds_name), 'wb')
# 	save (list = fn_list, file = current_file)
# 	close (current_file)
# 	rm (list = fn_list)
# }

# Let's convert the horizontal axis to date
library ('lubridate')

change_tables_dates <- function (datatable) {
	rows <- rownames (datatable)
	dates <- as.Date (sprintf ('%s/01/15', rows))
	
	colnames_union <- list ()
	for (row in rows) {
		current_row <- datatable [row, ]
		# colnames_union = union (current_row, colnames_union)
		column_names <- list ()
		column_names [1] <- format (dates [match (row, rows)], '%Y-%m')
		for (column in 2:length (current_row)) {
			if (is.na (current_row [column])) {
				column = column - 1
				break
			}
			current_col_name <- as.Date (sprintf 
										 ('%s-01', column_names [column - 1]))
			month (current_col_name) = month (current_col_name) + 1
			column_names [column] <- format (current_col_name,
											 '%Y-%m')
		}
		current_row = current_row [1:column]
		column_names <- unlist (column_names, use.names = FALSE)
		names (current_row) <- column_names
		colnames_union = union (column_names, colnames_union)
		assign (x = row, value = current_row, pos = -1)
	}
	new_table <- list ()
	for (row in rows) {
		current_row <- get (row)
		new_colnames <- setdiff (unlist (colnames_union), names (current_row))
		current_row [new_colnames] = NA
		current_row = current_row [sort (names (current_row))]
		if (length (new_table) == 0) {
			new_table <- current_row
		} else {
			new_table = rbind (new_table, current_row)
		}
	}
	rownames (new_table) <- rows
	return (new_table)
}

# 
# # No death date assumed. Based only on current activities 
# pdf ('fig4_b.pdf')
# for (ds in datasets) {
# 	fn_list <- load (sprintf ('data/%s_cohort_analysis.dat', ds))
# 	colors <-  unique (rainbow (nrow (HHI_clusters)))
# 	survival_clusters2 <- change_tables_dates (survival_clusters2)
# 	for (row in rownames (survival_clusters2)) {
# 		plot (survival_clusters2 [row, ], col = colors [which (rownames (survival_clusters2) == row)]
# 			  ,xlab = '', ylab = '', xaxt = 'n', ylim = c (0, 1), type = 'l')
# 		par (new = TRUE)
# 	}
# 	axis (side = 1, at = seq (1, ncol (survival_clusters2), by = 4),
# 		  labels = colnames (survival_clusters2)[seq (1, ncol (survival_clusters2), by = 4)], las = 2, cex.axis = 0.7)
# 	
# 	legend("topleft", legend = rownames (survival_clusters2), lty= 1, #rep (nrow (survival_clusters2), 1),
# 		   col = colors [seq (1, nrow (survival_clusters2))])
# 	mtext (side = 2, text = 'Survival rate (V2.0)', line = 2.0)
# 	mtext (side = 1, text = 'Age (month)', line = 3.5)
# 	mtext (sprintf ('Survival (V2.0 - active/domains born in timespan) over age - %s', ds))
# 	par (new = FALSE)	
# 	rm (list = fn_list)
# }
# dev.off ()



for (ds in datasets) {
  pdf (sprintf('plots/Fig6-%s.pdf', ds))
  
  data <- load (sprintf ('data/%s_cohort_analysis.dat', ds))
  survival_clusters2 <- change_tables_dates (survival_clusters2)
  
  colors <- get_colors(seq_len(nrow (HHI_clusters)))
  j <- seq_len(ncol(survival_clusters2))
  
  plot(NA, xlab = 'Age (years)', ylab = 'Proportion of domains active', ylim = c (0, 1), xlim=c(0,max(rowSums(!is.na(survival_clusters2)))/12))
  for (i in seq_len(nrow(survival_clusters2))) {
    start <- min(which(!is.na(survival_clusters2[i, ])))
    end <- max(which(!is.na(survival_clusters2[i, ])))
    x <- (j-start)/12
    points (x, survival_clusters2[i, ], col = colors[i], type = 'l', lwd = 2)
    text((end-start)/12, survival_clusters2[i, end], rownames(survival_clusters2)[i], col = colors[i], pos=1, cex=1)
  }
  rm (list = data)
  dev.off ()
}

# pdf (sprintf('plots/Extra_link-volume-cohort.pdf', ds))
# for (ds in datasets) {
#   data <- load (sprintf ('data/%s_cohort_analysis.dat', ds))
#   links_clusters <- change_tables_dates (links_clusters)
#   
#   colors <- get_colors(seq_len(nrow (HHI_clusters)))
#   j <- seq_len(ncol(links_clusters))
#   
#   plot(NA, xlab = 'Age (years)', ylab = 'Proportion of domains active', ylim = c (0, max(links_clusters, na.rm = T)), xlim=c(0, max(j)/12))
#   for (i in seq_len(nrow(links_clusters))) {
#     start <- min(which(!is.na(links_clusters[i, ])))
#     end <- max(which(!is.na(links_clusters[i, ])))
#     x <- j/12
#     points (x, links_clusters[i, ], col = colors[i], type = 'l', lwd = 2)
#     text(length(j)/12, links_clusters[i, end], rownames(links_clusters)[i], col = colors[i], pos=1, cex=1)
#   }
#   rm (list = data)
# }
# dev.off ()