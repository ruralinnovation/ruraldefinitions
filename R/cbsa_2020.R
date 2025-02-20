#' Core-Based Statistical Areas 2020 rural definition
#'
#' County-level rural classification
#'
#' @format A tibble with 3234 rows and 5 variables:
#' \describe{
#'   \item{geoid}{string County GEOID code}
#'   \item{name}{string Name of the rural definition}
#'   \item{year}{dbl Year the definition was released}
#'   \item{rural_def}{string Detailed rural classification if relevant}
#'   \item{is_rural}{string Value of either Rural or Nonrural}
#' }
#' @source \url{https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.2020.html#list-tab-790442341}
"cbsa_2020"
