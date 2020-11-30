## these are common functions related to online diversity
library("RcppRoll")
library(tidyverse)

#' Given a dataset name, this function loads it and put it into the common
#' format, ready to be used by analysis functions
load_dataset <- function(datasetname = "reddit") {
  print(sprintf("--> Loading dataset '%s' ...", datasetname))
  
  ####### dataset selection and loading
  ## Wikipedia dataset
  switch(datasetname,
         # wikilinks = { ## obsolete, no longer in usage
         #   load("data/wikipedia.dat") ; dataset <- wikipedia ; rm(wikipedia)
         #   outliers <- c()
         # },
         reddit = {
           if (file.exists("data/reddit.rds")) {
             ## we have the binary version
             dataset <- read_rds(path = "data/reddit.rds")
           } else {
             ## need to read from the CSV and create the RDS
             dataset <- read_csv(file = "data/reddit.csv.xz")
             write_rds(x = dataset, path = "data/reddit.rds", compress = "bz2")
           }
           outliers <- c()
         },
         twitter = {
           if (file.exists("data/twitter.rds")) {
             ## we have the binary version
             dataset <- read_rds(path = "data/twitter.rds")
           } else {
             ## need to read from the CSV and create the RDS
             dataset <- bind_rows(read_csv("data/twitter.csv.1.xz"),
                                  read_csv("data/twitter.csv.2.xz") )
             write_rds(x = dataset, path = "data/twitter.rds", compress = "bz2")
           }          
           
           # load("data/binary_datasets/twitter.dat") ; datasetname <- "twitter" ; dataset <- twitter ; rm(twitter) ; 
           outliers <- c() 
         },
         {
           stop(sprintf("Unknown dataset name '%s'.", datasetname))
         })
  
  ## remove domains that never appear (some bug in code? in dataset construction?)
  effectives <- rowSums(dataset[,-1]) > 0
  ## remove outliers
  dataset <- dataset[effectives, ! names(dataset) %in% outliers]
  
  return(dataset)  
}

#' Given a dataset, this function returns the series of dates corresponding to
#' the columns.
get_dates <- function(dataset) {
  ## extract the timeframes from attr names
  dt <- names(dataset)[-1]
  dt <- gsub(pattern = "X", replacement = "", x = dt)
  dt <- as.Date(dt, "%Y.%m.%d")
  
  return(dt)
}

add_axis_log10 <- function(side=1, labels=TRUE, las=1, ...){
  at <- -20:20
  if(labels)
    lab <- do.call(expression, lapply(at, function(i) bquote(10^.(i))))
  else
    lab=""
  axis(side, at = 10^at, labels = lab, las=las,...)
}


label <- function(text, px=0.03, py=NULL, ..., adj=c(0, 1)) {
  if (is.null(py)) {
    fin <- par("fin")
    r <- fin[[1]] / fin[[2]]
    if (r > 1) { # x is longer.
      py <- 1 - px
      px <- (1 - py) / r
    } else {
      py <- 1 - px * r
    }
  }

  usr <- par("usr")
  x <- usr[1] + px*(usr[2] - usr[1])
  y <- usr[3] + py*(usr[4] - usr[3])

  ## NOTE: base 10 log:
  if (par("xlog")) {
    x <- 10^x
  }
  if (par("ylog")) {
    y <- 10^y
  }

  text(x, y, text, adj=adj, xpd=NA, ...)
}

rasterImage_percent <- function(img, px, py, ...) {
  rasterImage(img, percent_x(px[1]), percent_y(py[1]), percent_x(px[2]), percent_y(py[2]),...)
}


percent_x <- function(p) {
  usr <- par("usr")
  x <- usr[1] + p*(usr[2] - usr[1])

  ## NOTE: base 10 log:
  if (par("xlog")) {
    x <- 10^x
  }
  x
}

percent_y <- function(p) {
  usr <- par("usr")
  y <- usr[3] + p*(usr[4] - usr[3])

  ## NOTE: base 10 log:
  if (par("ylog")) {
    y <- 10^y
  }
  y
}

label <- function(text, px=0.03, py=NULL, ..., adj=c(0, 1)) {
  if (is.null(py)) {
    fin <- par("fin")
    r <- fin[[1]] / fin[[2]]
    if (r > 1) { # x is longer.
      py <- 1 - px
      px <- (1 - py) / r
    } else {
      py <- 1 - px * r
    }
  }
  usr <- par("usr")
  x <- usr[1] + px*(usr[2] - usr[1])
  y <- usr[3] + py*(usr[4] - usr[3])

  ## NOTE: base 10 log:
  if (par("xlog")) {
    x <- 10^x
  }
  if (par("ylog")) {
    y <- 10^y
  }

  text(x, y, text, adj=adj, xpd=NA, ...)
}


col.lots <- function(n) {
  # returns up to 80 unique, nice colors, generated using
  # http://tools.medialab.sciences-po.fr/iwanthue/ Starts repeating after 80
  c("#75954F", "#D455E9", "#E34423", "#4CAAE1", "#451431", "#5DE737",
                "#DC9B94", "#DC3788", "#E0A732", "#67D4C1", "#5F75E2",
                "#A8313C", "#8D6F96", "#5F3819", "#D8CFE4", "#BDE640", "#DAD799", "#D981DD",
                "#61AD34", "#B8784B", "#892870", "#445662", "#493670", "#3CA374", "#E56C7F",
                "#5F978F", "#BAE684", "#DB732A", "#7148A8", "#867927", "#918C68", "#98A730",
                "#DDA5D2", "#456C9C", "#2B5024", "#E4D742", "#D3CAB6", "#946661", "#9B66E3",
                "#AA3BA2", "#A98FE1", "#9AD3E8", "#5F8FE0", "#DF3565", "#D5AC81", "#6AE4AE",
                "#652326", "#575640", "#2D6659", "#26294A", "#DA66AB", "#E24849", "#4A58A3",
                "#9F3A59", "#71E764", "#CF7A99", "#3B7A24", "#AA9FA9", "#DD39C0", "#604458",
                "#C7C568", "#98A6DA", "#DDAB5F", "#96341B", "#AED9A8", "#55DBE7", "#57B15C",
                "#B9E0D5", "#638294", "#D16F5E", "#504E1A", "#342724", "#64916A", "#975EA8", "#1A3125", "#65E689",
                "#9D641E", "#59A2BB", "#7A3660", "#64C32A")[seq_len(n)]
}

get_colors<- function(x) {
  x <- unlist(x)
  cols <- col.lots(length(x))
  names(cols) <- x
  cols
}

lines_rolling_mean <- function(x, y, n,...){
  yr <- roll_mean(y, n=n)
  xr <- roll_mean(x, n=n)
  lines(xr, yr, ...)
  invisible(list(x=xr, y=yr))
}
