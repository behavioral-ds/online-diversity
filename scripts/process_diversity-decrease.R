## compute the data for Fig3, i.e. the diversity reduction indicators: skewness, kurtosis and PL fits
library("car")
library("parallel")
library("moments")
library("poweRlaw")
library("scales")
library("DescTools")
source("scripts/utils.R")

####### dataset selection and loading
# datasetname <- "reddit"
# datasetname <- "twitter"

for (datasetname in c("reddit", "twitter")){
  ## load dataset and extract the timeframes from attr names
  dataset <- load_dataset(datasetname = datasetname)
  dt <- get_dates(dataset = dataset)
  
  ###### done loading -- start analysis
  
  total <- colSums(dataset[, -1], na.rm = T)
  uniqueness <- colSums(dataset[, -1] > 0, na.rm = T) / total
  
  perc_1000 <- apply(X = dataset[, -1], MARGIN = 2, FUN = function(x) {
    pos <- order(x, decreasing = T)
    pos <- pos[1:1000]
    total_1000 <- sum(x[pos], na.rm = T)
    return(total_1000 / sum(x, na.rm = T))
  })
  gc()
  
  ## construct the datasetCopy, with only active domains (zeros replaced by NA).
  ## I want only active domains, because otherwise non-existing domains would influence measures of skewness and kurtosis.
  datasetCopy <- dataset[, -1] %>% na_if(0)
  
  ## distribution analysis - higly skewed distribution
  skew_series <- skewness(x = datasetCopy, na.rm = T)
  kurt_series <- kurtosis(x = datasetCopy, na.rm = T)
  
  first_dens <- 1 ; last_dens <- length(dt) ; middle_dens <- round( mean(c(first_dens, last_dens)))
  dens_first <- density(x = unlist(na.omit(datasetCopy[, first_dens])) ) #, bw = "SJ" ## maybe SJ is better, but it takes a crazy amount of time for my dataset size
  dens_middle <- density(x = unlist(na.omit(datasetCopy[, middle_dens]))) #, bw = "SJ" ## maybe SJ is better, but it takes a crazy amount of time for my dataset size
  dens_last <- density(x = unlist(na.omit(datasetCopy[, last_dens])) ) #, bw = "SJ" ## maybe SJ is better, but it takes a crazy amount of time for my dataset size
  
  ## compute HHI and Rosen
  HHI <- sapply(X = dataset[, -1], FUN = Herfindahl)
  Rosen <- sapply(X = dataset[, -1], FUN = Rosenbluth)
  
  ## fit a powerlaw for each timeframe
  .cl <- makeCluster(spec = min(detectCores(), length(names(dataset))))
  results <- parSapply(cl = .cl, X = dataset[,-1], FUN = function(series) {
    require("poweRlaw")
    
    series <- unlist(series)
    my_pl <- displ$new(unlist(series[series > 0]))
    est <- estimate_xmin(m = my_pl)
    # my_pl$setXmin(est)
    
    return( c(est$pars, est$xmin, est$gof))
  })
  stopCluster(.cl)
  
  results <- data.frame(t(results))
  names(results) <- c("alpha", "xmin", "gof")
  
  ############# save the data for plots, for Fig3
  colMeansDatasetCopy <- colMeans(datasetCopy, na.rm = T)
  save(datasetname, uniqueness, dt, colMeansDatasetCopy, perc_1000, skew_series, kurt_series, dens_last, dens_first, dens_middle, results, first_dens, middle_dens, last_dens, HHI,
       file = sprintf("data/%s-total-diversity-decline.dat", datasetname),  compress = "bzip2")
  
}