#' 1993 Urban Influence Codes
#'
#' County-level rural classification
#'
#' @format A tibble with 3233 rows and 5 variables:
#' \describe{
#'   \item{geoid}{string County GEOID code}
#'   \item{name}{string Name of the rural definition}
#'   \item{year}{dbl Year the definition was released}
#'   \item{rural_def}{string Detailed rural classification if relevant}
#'   \item{is_rural}{string Value of either Rural or Nonrural}
#' }
#' @source \url{https://www.ers.usda.gov/data-products/urban-influence-codes}
"uic_1993"
