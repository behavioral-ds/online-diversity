#!/usr/local/bin/Rscript

library(lubridate)
library(tidyverse)
library(png)
source("scripts/utils.R")

mylabel <- function(txt) label(txt, -0.2, 1.15, xpd=NA, cex=1.5)
as.date1 <- function(txt) {ymd(sprintf("%s-01", names(txt)))}
as.date2 <- function(txt) {ymd(names(txt))}
as.date3 <- function(txt) {ymd(gsub("X", "", names(txt)))}

cols <- c("#0084b4", "#ff4500")
names(cols) <- c('twitter', 'reddit')

pdf ('plots/Fig1.pdf', height=8, width=8)
# png(filename = 'plots/Fig1.png', width = 800, height = 800, units = "px")
par(mfrow=c(2,2), oma=c(4,2,0,1), mar=c(2,6,4,0))

reddit_volume <- read_csv(file = "data/reddit-volume-augmented.csv")
twitter_volume <- read_csv(file = "data/twitter-volume-augmented.csv")
posts <- full_join(x = reddit_volume[,c("Timeframe", "total.comments")], y = twitter_volume[,c("Timeframe", "total.comments")], by = "Timeframe")
names(posts) <- c("Timeframe", "reddit", "twitter")
posts <- posts %>%
  pivot_longer(cols = -Timeframe) %>%
  pivot_wider(names_from = Timeframe) %>%
  column_to_rownames(var = "name")

posts ["twitter", '2011-09'] = NA
posts ["twitter", '2011-12'] = NA
posts ["twitter", '2015-03'] = NA
posts ["twitter", '2018-05'] = NA
posts ["twitter", '2018-06'] = NA

plot(as.date1(posts ['reddit', ]), posts ['reddit', ], type = 'l', ylab = '', xlab = '', yaxt = 'n', col = cols['reddit'], log = "y",
			ylim = c (1e3, 2e8), lty = "dashed", lwd=2)
points (as.date1(posts ["twitter", ]),  posts ["twitter", ], type = 'l',  col = cols["twitter"], lty = "dashed", lwd=2)
add_axis_log10(2)

domains <- full_join(x = reddit_volume[,c("Timeframe", "unique.domains")], y = twitter_volume[,c("Timeframe", "unique.domains")], by = "Timeframe")
names(domains) <- c("Timeframe", "reddit", "twitter")
domains <- domains %>%
  pivot_longer(cols = -Timeframe) %>%
  pivot_wider(names_from = Timeframe) %>%
  column_to_rownames(var = "name")

links <- full_join(x = reddit_volume[,c("Timeframe", "comments.with.links")], y = twitter_volume[,c("Timeframe", "comments.with.links")], by = "Timeframe")
names(links) <- c("Timeframe", "reddit", "twitter")
links <- links %>%
  pivot_longer(cols = -Timeframe) %>%
  pivot_wider(names_from = Timeframe) %>%
  column_to_rownames(var = "name")


# # Get rid of abnormal data
domains ['twitter', '2011-12'] = NA
domains ['twitter', '2011-10'] = NA
domains ['twitter', '2015-03'] = NA
domains ['twitter', '2011-09'] = NA
domains ["twitter", '2018-05'] = NA
domains ["twitter", '2018-06'] = NA

links ['twitter', '2015-03'] = NA
links ['twitter', '2011-09'] = NA
links ["twitter", '2011-12'] = NA
links ["twitter", '2018-05'] = NA
links ["twitter", '2018-06'] = NA

points (as.date1(links ['reddit',]), links ['reddit',], col = cols[2], type = 'l', lwd=2)
points (as.date1(links ['twitter',]), links ['twitter',], col = cols[1], type = 'l', lwd=2)

x <- 0.05
y <- 0.9
rasterImage_percent(readPNG("assets/twitter.png"), x + c(0, 0.05), y + c(0, 0.05))
text(percent_x(x + 0.03), percent_y(y + 0.02), "Twitter", pos=4)
rasterImage_percent(readPNG("assets/reddit.png"), x + c(0, 0.05), y - 0.075 + c(0, 0.06))
text(percent_x(x + 0.03), percent_y(y - 0.075 + 0.02), "Reddit", pos=4)
mtext("Number (per month)", 2, cex=0.9, line=3)

mylabel("A - Number of posts & links")

plot (as.date1(domains ['reddit', ]), domains ['reddit', ], log = "y", col = cols[2], yaxt = 'n', ylim = c (1e3, 7e5), ylab = '', xlab = '', type = 'l', lwd=2)
points (as.date1(domains ['twitter', ]), domains ['twitter', ], col = cols[1], type = 'l', lwd=2)
add_axis_log10(2)
mtext("Number", 2, cex=0.9, line=3)
mylabel("B - Active domains")

# par(mar=c(2,6,4,2))
load(file = "data/reddit-total-diversity-decline.dat")
plot (as.date3(HHI), HHI, log = "", col = cols[2], las=1, ylim = c (0, 0.2), ylab = '', xlab = '', type = 'l', lwd=2)
reddit_dates <- as.date3(HHI)
load(file = "data/twitter-total-diversity-decline.dat")
HHI ['X2015.03.15'] = NA
HHI ['X2011.09.15'] = NA
HHI ['X2011.12.15'] = NA
HHI ['X2018.05.15'] = NA
HHI ['X2018.06.15'] = NA
HHI ['X2018.07.15'] = NA
newHHI <- rep(x = NA, times = length(reddit_dates))
names(newHHI) <- reddit_dates
newHHI[reddit_dates %in% as.date3(HHI)] <- HHI
par(new = T)
plot(as.date3(newHHI), newHHI, col = cols[1], type = 'l', lwd=2,axes=F, xlab=NA, ylab=NA,  ylim = c (0, max(HHI, na.rm = T)))
axis(side = 4, las=1)
mtext("Year", 1, cex=1.2, line=3)
mtext("HHI (Reddit)", 2, cex=0.9, line=3)
mtext("HHI (Twitter)", 4, cex=0.9, line=-1)
mylabel("C - HHI/Simpson's diversity index")

uniqueness <- full_join(x = reddit_volume[,c("Timeframe", "%.uniqueness.of.links")], y = twitter_volume[,c("Timeframe", "%.uniqueness.of.links")], by = "Timeframe")
names(uniqueness) <- c("Timeframe", "reddit", "twitter")
uniqueness <- uniqueness %>%
  pivot_longer(cols = -Timeframe) %>%
  pivot_wider(names_from = Timeframe) %>%
  column_to_rownames(var = "name")

plot (as.date1(uniqueness ['reddit', ]), uniqueness ['reddit', ], col = cols[2], las=1, ylim = c (0, 0.7), ylab = '', xlab = '', type = 'l', lwd=2)
points(as.date1(uniqueness ['twitter', ]),uniqueness ['twitter', ], col = cols[1],  type = 'l', lwd=2)
mtext("Domains per link", 2, cex=0.9, line=2)
mylabel("D - Uniqueness of links")
mtext("Year", 1, cex=1.2, line=3)

dev.off()
