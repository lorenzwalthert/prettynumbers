print.integer <- function(x, delim = "'",
                          digits_after_decimal = "auto",
                          ...) {
  cat_numbers(x, delim, digits_after_decimal, ...)
}

print.numeric <- function(x, delim = "'", digits_after_decimal = "auto", ...) {
  cat_numbers(x, delim, digits_after_decimal, ...)
}

#' Return a number with a returner function
#'
#' Different APIs might prove helpful:
#'
#' * return with [base::cat()] for interactive printing.
#' * ordinary return with [base::identity()] for further processing.
#' * print as string with [base::print()].
return_numbers <- function(x, delim = "'", digits_after_decimal = "auto",
                           max_length = 10,
                           ..., .returner = cat,
                           invisible = TRUE) {
  scale <- max(floor(log10(x))) + 2
  tabular <- purrr::map2_dfr(x, 1:length(x), return_number,
               delim = delim, digits_after_decimal = digits_after_decimal,
               max_length = max_length,
               ...
  )
  tabular
  max_chars_per_col <- purrr::map_int(tabular, ~max(nchar(.x)))
  tabular$exact <- fill_spaces(tabular$exact, max_chars_per_col["exact"])
  tabular$index <- fill_spaces(tabular$index, max_chars_per_col["index"], side = "trailing")
  length <- seq(1, min(length(x), max_length))
  tabular <- tabular[length, ]

  .returner(c(
    paste(tabular$index, tabular$exact, tabular$rounded),
    if (length(x) > max_length) paste("# And", length(x) - max_length, "more rows.")
  ), sep = "\n")
  if (invisible) {
    invisible(x)
  }
}

fill_spaces <- function(vec, nchar, side = "leading") {
  spaces <- purrr::map(nchar - nchar(vec), ~collapse(rep(" ", .x))) %>%
    purrr::flatten_chr()
  if (side == "leading") {
    paste0(spaces, vec)
  }  else {
    paste0(vec, spaces)
  }
}

return_number <- function(x, id, delim, digits_after_decimal,
                          ...) {
  long <- as_long(x)
  delim_positions <- elicit_delim_positions(x, long)
  long_with_ticks <- purrr::reduce(delim_positions, add_ticks, delim = delim,
                                   .init = long) %>%
    add_block(delim) %>%
    format_digits_after_decimal(digits_after_decimal)
  rounded <- elicit_rounded(long_with_ticks, delim_positions)
  x_pretty <- collapse(long_with_ticks$x)
  #.returner(collapse(x_pretty_with_index, rounded), ...)
  tibble::tibble(
    index = paste0("[", id, "]"),
    exact = collapse(long_with_ticks$x),
    rounded = rounded
  )
}

format_digits_after_decimal <- function(data, digits_after_decimal) {
  digits_after_decimal <- set_digits_after_decimal(data, digits_after_decimal)
  data <- data[data$n_after_decimal <= digits_after_decimal + 1,]
  data
}

set_digits_after_decimal <- function(data, digits_after_decimal) {
  if (checkmate::test_integerish(digits_after_decimal)) {
    digits_after_decimal
  } else {
    -1
  }
}

add_block <- function(data, delim) {
  data %>%
  tibble::add_column(
    block = ifelse(.$x == delim, -1, ifelse(
      .$x == ".", -2, cumsum(.$x == delim) + 1)
    ))
}

bare_numbers <- purrr::partial(return_numbers, .returner = identity)
cat_numbers <- purrr::partial(return_numbers, .returner = cat, .end = "\n")
print_numbers <- purrr::partial(return_numbers, .returner = print)

#' Derive the rounded version of a number
elicit_rounded <- function(long_with_ticks, delim_positions) {
  verbal <- purrr::when(delim_positions,
                        length(.) == 1 ~ "thousand",
                        length(.) == 2 ~ "millions",
                        length(.) == 3 ~ "billions",
                        ~ ""
  )
  first <- collapse(
    collapse(long_with_ticks$x[long_with_ticks$block %in% c(0, 1)]),
    ".",
    collapse(long_with_ticks$x[long_with_ticks$block > 1])
  ) %>%
    as.numeric()
  rounded_first <- round(first)
  if (first == rounded_first) {
    approximately <- " "
  } else {
    approximately <- "~"
  }
  if (length(delim_positions) > 0 ) {
    spaces <- collapse(rep(" ", 4 - nchar(rounded_first)))
    rounded <- c(" (", approximately, rounded_first, spaces, verbal, ")")
  } else {
    rounded <- ""
  }
  collapse(rounded)
}

#' Turn a number into a long tabular format
as_long <- function(x) {
  tibble::tibble(
    x= strsplit(as.character(formatC(x, format = "f")), "") %>%
      unlist(),
    ind = rlang::seq2(1, length(.data$x)),
    is_after_decimal = cumsum(x == "."),
    n_after_decimal = cumsum(is_after_decimal)
  )
}

#' Figure out where the big marks go
elicit_delim_positions <- function(x, long) {
  sharp_above_threshold <- floor(log10(x))
  if (sharp_above_threshold < 3) {
    return(integer(0))
  }
  n_ticks <- floor(sharp_above_threshold / 3)
  digits_before_decimal <- sum(1 - long$is_after_decimal)
  digits_before_decimal - seq(3, 3 * n_ticks, by = 3)
}

#' Add big marks to a number in long format
add_ticks <- function(long, after = 3, delim = "'") {
  long %>%
    tibble::add_row(
      x = delim, ind = NA, is_after_decimal = 0, n_after_decimal = 0,
      .after = after
    )
}

collapse <- function(...) {
  paste0(..., sep = "", collapse = "")
}
