#' National Center for Health Statistics 1990 rural definition
#'
#' County-level rural classification
#'
#' @format A tibble with 3132 rows and 5 variables:
#' \describe{
#'   \item{geoid}{string County GEOID code}
#'   \item{name}{string Name of the rural definition}
#'   \item{year}{dbl Year the definition was released}
#'   \item{rural_def}{string Detailed rural classification if relevant}
#'   \item{is_rural}{string Value of either Rural or Nonrural}
#' }
#' @source \url{https://www.cdc.gov/nchs/data-analysis-tools/urban-rural.html}
"nchs_1990"
