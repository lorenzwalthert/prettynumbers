
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)

<!-- README.md is generated from README.Rmd. Please edit that file -->

# prettynumbers

The goal of prettynumbers is to provide a pretty print method for
(large) numbers, primarily for the type vector . Before a more extended
autoprint is implemented in base R, we need to call `print` explicitly,
but hopefully this will be [resolved until R
3.6](https://twitter.com/_lionelhenry/status/1014078544086003712).

## Installation

You can install the development version from GitHub.

``` r
devtools::install_github("lorenzwalthert/prettynumbers") 
```

## Example

``` r
set.seed(4)
library(prettynumbers)
numbers <- c(1, 23, 1023.30, 38929381, runif(10, 0, 1e6))
numbers
#> [1]           1
#> [2]          23
#> [3]       1'023  (~1   thousand)
#> [4]  38'929'381  (~39  millions)
#> [5]     585'800  (~586 thousand)
#> [6]       8'945  (~9   thousand)
#> [7]     293'739  (~294 thousand)
#> [8]     277'374  (~277 thousand)
#> [9]     813'574  (~814 thousand)
#> [10]    260'427  (~260 thousand)
#> # And 4 more rows.
```

Note that because of autoprint for interactive usage is not implemented
as stated above, you need to call `print()` explicitly when used
interactively, e.g.

``` r
print(numbers, delim = ",", digits_after_decimal = 2)
#> [1]           1.00
#> [2]          23.00
#> [3]       1,023.29  (~1   thousand)
#> [4]  38,929,381.00  (~39  millions)
#> [5]     585,800.30  (~586 thousand)
#> [6]       8,945.79  (~9   thousand)
#> [7]     293,739.61  (~294 thousand)
#> [8]     277,374.95  (~277 thousand)
#> [9]     813,574.21  (~814 thousand)
#> [10]    260,427.77  (~260 thousand)
#> # And 4 more rows.
```

And see how this compares to the default printing method:

``` r
set.seed(4)
c(1, 23, 1023.30, 38929381, runif(10, 0, 1e6)) %>% print.default()
#>  [1]        1.000       23.000     1023.300 38929381.000   585800.305
#>  [6]     8945.796   293739.612   277374.958   813574.215   260427.771
#> [11]   724405.893   906092.151   949040.221    73144.469
```

## Features

Compared the default interger and numberic printing method, this package
offers.

  - Allign numbers by decimal point.
  - Print only one number per row to reduce distortion.
  - Add delimiters such as `'`.
  - Show rounded output in semi-verbatin for easier visual digestion.
  - limit number of printed elements.
