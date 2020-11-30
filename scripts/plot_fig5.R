#!/usr/bin/Rscript

source("scripts/utils.R")

library(lubridate)

## load the analysis data. If this file does not exist, run the script process_twelve-functions-competitors.R'
load ('data/competitors-merged.dat')

# build summary dataset from
datasets <- c ('twitter', 'reddit')
data <- list()

for (ds in datasets) {
	tables <- ls (pattern = ds)
	rows <- data.frame ()
	for (table in tables) {
		current_table <- get (table)
		rows <- rbind (rows, current_table)
	}
	column <- as.Date (colnames (current_table), 'X%Y.%m.%d')
	begin.index <- which (!is.na (column))[1]
	end.index <- ncol (current_table)
	colnames (rows) [begin.index:end.index] <- format (column) [begin.index:end.index]
	rows <- rows [, c (1, begin.index:end.index)]
	tbl <- data.frame(t (rows [,2:ncol (rows)]))
	names(tbl) <- unlist(rows['Company'])
	tbl[tbl==0] <- 0.001

	#remove spaces from front of some names
	i <- substr(names(tbl), 1,1)==" "
  names(tbl)[i] <- substring(names(tbl)[i], 2)

	ylim <- ymd(c("2006-01-01", "2020-01-01"))
	date <-  ymd(rownames(tbl))
	i <- date >= ylim[1] & date < ylim[2]
	data[[ds]] <- tbl[i,]
}

# Load grouping variables
competitors <- read.csv("data/competitors-across-12-functions.csv",
		stringsAsFactors = FALSE, check.names=FALSE, strip.white = T)[, c("Company","Website","Year","Category")]
groups <- split(competitors, competitors[["Category"]])

# sanity check -- check names in datasets match
all(sort(unique(names(data[[1]]), names(data[[2]]))) %in% competitors[["Company"]])

# colors for each group
colors <- get_colors(names(groups))

# do for each dataset
for (ds in datasets) {
	df <- data[[ds]]
	pdf (sprintf('plots/Fig5-%s.pdf', ds), height = 6, width=8)

	par(mar=c(5,5,1,6))

	x <- ymd(rownames(df))

	plot(x, rep(1, length(x)), type='n', log="y",
					 xlab = '', xaxs="i",
					 yaxt = 'n',  ylim=c(1, 1E7), xlim= ymd(c("2006-01-01","2020-01-01")), ylab = '')
	add_axis_log10(2)

	for(v in names(groups)){
		g <- groups[[v]]
		f <- g[["Company"]] %in% names(df)
		y <- rowSums(df[,g[["Company"]][f]])
		r <- lines_rolling_mean(x, y, n=3, col = colors[v], lwd=2)

		text(x=ymd("2019-12-31"), y=r$y[length(r$y)], labels = v, col = colors[v], las=1, cex=0.6, pos=4, xpd=NA)
	}

	mtext("Links (per month)", 2, cex=1.2, line=3)
	mtext("Year", 1, cex=1.2, line=3)
	dev.off ()
}

# Save table for paper

library(xtable)

print(xtable(competitors[, c("Category", "Website", "Company", "Year")]),
				file = "table.tex"
        , sanitize.text.function=I
        , include.rownames = FALSE
        , include.colnames = TRUE,
        only.contents=TRUE)

