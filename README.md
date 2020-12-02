Online Diversity: Evolution of diversity and dominance of companies in
online activity
================

This repository contains code and data accompanying the publication
“Evolution of diversity and dominance of companies in online activity”
[\[McCarthy et al,
    ’20\]]().

# Reference:

    [McCarthy et al, '20] McCarthy, P. X., Gong, X., Eghbal, S., Falster, D. S., & Rizoiu, M.-A. (2020). 
    Evolution of diversity and dominance of companies in online activity.

# Reproducing analysis and results:

All the data and code to reproduce the analysis, the results and the
plots included in the main paper are found in this repository. We use
the `make` build system for running analysis and generating intermediary
results, as well as plotting figures. Usage examples:

  - `make fig1` – generates all the analysis required, and the figure
    `plots/Fig1.pdf`;
  - `make clean` – removes all generated files (`*.rds`, `*.dat`);
  - `make all` – reproduces all analysis and all plots. **WARNING**:
    this can take a while to execute, and might require a machine with
    significant memory.

**Note:** producing some of the figures requires `python`. We recommend
the [anaconda](https://anaconda.org/) installation. You can install all
required packages in a separate environment by using (in a terminal):

``` bash
# note: this will take a while to install
conda create --name online-diversity  -c mlgill powerlaw numpy plotly seaborn matplotlib pandas notebook backports.lzma
source activate online-diversity
```

# Repository content:

This repository contains the following code scripts:

  - `scripts/process_compute-reddit-volume.R` and
    `process_compute-twitter-volume.R` – R scripts that start the
    dataset files (`data/reddit.csv.xz`, `data/twitter.csv.1.xz` and
    `data/twitter.csv.2.xz`), and compute the number of posts, links,
    active domains, HHI and link uniqueness. Required for plotting
    `plots/Fig1.pdf`;
  - `scripts/process_diversity-decrease.R` – R scripts that start the
    dataset files and computes the diversity reduction indicators:
    skewness, kurtosis and PL fits. Required for plotting
    `plots/Fig1.pdf` and plotting `plots/Fig3.pdf` (**Note:** running
    this script requires significant memory);
  - `scripts/process_twelve-functions-competitors.R` – R scripts that
    start the dataset files and the list of competitors in the 12
    selected functions, and builds the volume of attention for each
    function. Required for `plots/Fig5.pdf`;
  - `scripts/process_temporal-analysis.R` – R scripts that start the
    dataset files and build the total volume of attention received by
    the temporal cohorts (domains that appear in particular years).
    Required for `plots/Fig6.pdf`;
  - `scripts/plot_fig1.R`, `scripts/plot_fig3.R`, `scripts/plot_fig5.R`,
    `scripts/plot_fig6.R` – R script to plot the different figures in
    the paper;
  - `scripts/utils.R` – additional functions for reading, writing data
    and plotting.

The following data and plots is also available:

  - `data/reddit.csv.xz` – contains the monthly counts of links towards
    domains in Reddit (CSV compressed using LZMA). Lines are domain
    names, columns are months.
  - `data/twitter.csv.1.xz` and `data/twitter.csv.2.xz` – contain the
    monthly counts of links towards domains in Twitter (CSV compressed
    using LZMA). Lines are domain names, columns are months. The data
    frame has been split into two halves to respect GitHub’s maximum
    file limits. The files need to be loaded individually, and
    concatenated at the level of rows. For example, in `R`
do:

<!-- end list -->

``` r
# note: this might take some time to run, and require quite a bit of memory
library(tidyverse)
dataset <- bind_rows(read_csv("data/twitter.csv.1.xz"),
                     read_csv("data/twitter.csv.2.xz") )
```

  - `data/commoncrawl1.csv.xz` and `data/commoncrawl2.csv.xz` – contain
    the PageRank for the top most linked **2.8 million websites**.
    Similar to the Twitter dataset, CommonCrawl has been split into two
    and can be merged
via:

<!-- end list -->

``` r
# note: this might take some time to run, and require quite a bit of memory
library(tidyverse)
dataset <- bind_rows(read_csv("data/commoncrawl1.csv.xz"),
                     read_csv("data/commoncrawl2.csv.xz") )
```

Here is an example of the generated Figure 1 from the main text,
obtained using `make fig1`: ![A static version of the Vocation
Map.](plots/Fig1.png)

# License

Both data set and code are distributed under the General Public License
v3 (GPLv3) license, a copy of which is included in this repository, in
the LICENSE file. If you require a different license and for other
questions, please contact us at <Marian-Andrei@rizoiu.eu>
