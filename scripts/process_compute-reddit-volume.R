#!/usr/bin/Rscript
library(tidyverse)
library(dplyr)
library(readr)
library (lubridate)
source("scripts/utils.R")

volume <- read_csv("data/reddit-volume-raw.csv")
reddit <- load_dataset(datasetname = "reddit")
w_links <- reddit %>% 
  select(-Domain) %>%
  summarise_all(sum)
  
columns <- colnames (reddit)
dates <- as.Date(columns, 'X%Y.%m.%d')



index <- 1
domains <- list ()

for (i in seq (1, length (dates))) {
	date <- dates [i]
	if (is.na (date)) {
		next
	}

	current_year <- year (date)
	current_month <- month (date)

	column <- sprintf ('X%02d.%02d.15', current_year, current_month)
	# links [index] = as.numeric (sum (reddit [, column]))
	domains [index] = as.numeric (length (which (reddit [, column] > 0)))

	index <- index + 1
}

reddit_volume <- cbind (volume, t (t (domains))) #, t (t (links)))
colnames (reddit_volume) [4] <- c ('domains') #, 'links')

reddit_volume <- as.data.frame(t (reddit_volume))

column_names <- sprintf ('%s-%02i', unlist(reddit_volume[1,]), as.numeric (unlist(reddit_volume[2,])) )

reddit_volume <- reddit_volume [-c (1, 2), ]
colnames (reddit_volume) <- column_names

reddit_volume <- rbind (reddit_volume, unlist (w_links))

rownames (reddit_volume) <- c ('total.comments', 'unique.domains', 'comments.with.links') #, '%.uniqueness.of.links')

reddit_volume <- reddit_volume [c ('total.comments', 'comments.with.links', 'unique.domains'),]

percentage_w_links <- round (unlist (reddit_volume ['comments.with.links',])/unlist (reddit_volume ['total.comments',])*100, digits = 2)

## compute mean number of links per domain
reddit[reddit == 0] <- NA
percentage_uniqueness <- 1 / colMeans(x = reddit[,-1], na.rm = T)

reddit_volume <- rbind (reddit_volume, percentage_w_links, percentage_uniqueness)
rownames (reddit_volume) [4:5] <- c ('%.with.links', '%.uniqueness.of.links')

## MAR: transform this into a long format, does not make sense like this
## also, for some reason, some columns are lists. Converting them.
foo <- data.frame(t(bind_rows(lapply(X = reddit_volume, FUN = function(x) as.numeric(x)))))
colnames(foo) <- rownames(reddit_volume)
foo <- foo %>%
  rownames_to_column(var = "Timeframe")
write_csv(x = foo, path = "data/reddit-volume-augmented.csv")
