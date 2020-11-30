#!/usr/bin/Rscript
library(tidyverse)
library(dplyr)
library(readr)
library (lubridate)
source("scripts/utils.R")


twitter <- load_dataset(datasetname = "twitter")
w_links <- twitter %>% 
  select(-Domain) %>%
  summarise_all(sum)

columns <- colnames (twitter)
dates <- as.Date(columns, 'X%Y.%m.%d')

volume <- read_csv("data/twitter-volume-raw.csv") %>%
  group_by(Year, Month) %>%
  summarise(TwitterVolume = sum(TwitterVolume), .groups = "drop") %>%
  mutate(date = as.Date(sprintf("X%d.%s.15", Year, Month), 'X%Y.%m.%d')) %>%
  filter(date %in% dates)

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
  # links [index] = as.numeric (sum (twitter [, column]))
  domains [index] = as.numeric (length (which (twitter [, column] > 0)))
  
  index <- index + 1
}

twitter_volume <- cbind (volume, t (t (domains))) #, t (t (links)))
colnames (twitter_volume) [5] <- c ('domains') #, 'links')

twitter_volume <- as.data.frame(t (twitter_volume))

column_names <- sprintf ('%s-%02i', unlist(twitter_volume[1,]), as.numeric (unlist(twitter_volume[2,])) )

twitter_volume <- twitter_volume [-c (1, 2, 4), ]
colnames (twitter_volume) <- column_names

# w_links <- list (volume_with_links [, 'TwitterVolume'])
twitter_volume <- rbind (twitter_volume, unlist (w_links))

rownames (twitter_volume) <- c ('total.comments', 'unique.domains', 'comments.with.links') #, '%.uniqueness.of.links')

twitter_volume <- twitter_volume [c ('total.comments', 'comments.with.links', 'unique.domains'),]

percentage_w_links <- round (unlist (twitter_volume ['comments.with.links',])/unlist (twitter_volume ['total.comments',])*100, digits = 2)

## compute mean number of links per domain
twitter[twitter == 0] <- NA
percentage_uniqueness <- 1 / colMeans(x = twitter[,-1], na.rm = T)

twitter_volume <- rbind (twitter_volume, percentage_w_links, percentage_uniqueness)
rownames (twitter_volume) [4:5] <- c ('%.with.links', '%.uniqueness.of.links')

## MAR: transform this into a long format, does not make sense like this
## also, for some reason, some columns are lists. Converting them.
foo <- data.frame(t(bind_rows(lapply(X = twitter_volume, FUN = function(x) as.numeric(x)))))
colnames(foo) <- rownames(twitter_volume)
foo <- foo %>%
  rownames_to_column(var = "Timeframe")
write_csv(x = foo, path = "data/twitter-volume-augmented.csv")
