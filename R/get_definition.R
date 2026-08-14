#' Get definition from S3
#'
#' @import DBI
#' @importFrom cori.data.s3 connect_to_s3 list_s3_objects
#'
#' @param name Rural definition to retrieve. One of "census", "cori", or
#'   "ruca".
#' @param year Publication year of the desired definition. If omitted,
#'   defaults to the latest year available on S3 for name. Must be one of
#'   the years available on S3 for name.
#' @export
get_definition <- function(name = c("census", "cori", "ruca"), year) {

  name <- match.arg(tolower(name), choices = c("census", "cori", "ruca"))

  bucket <- "ruraldefinitions"

  objects <- cori.data.s3::list_s3_objects(bucket)
  year_pattern <- sprintf("^clean/%s_([0-9]{4})\\.parquet$", name)
  available_years <- as.integer(
    sub(year_pattern, "\\1", grep(year_pattern, objects$key, value = TRUE))
  )

  if (length(available_years) == 0) {
    stop(sprintf("No definitions found on S3 for name '%s'.", name), call. = FALSE)
  }

  if (missing(year)) {
    year <- max(available_years)
  } else if (!year %in% available_years) {
    stop(sprintf(
      "Invalid year %s for name '%s'. Available years: %s.",
      year, name, paste(sort(available_years), collapse = ", ")
    ), call. = FALSE)
  }

  file_name <- paste0(
    name,
    "_",
    as.character(year),
    ".parquet"
  )

  s3_path <- sprintf("s3://%s/clean/%s", bucket, file_name)

  con <- cori.data.s3::connect_to_s3(bucket)
  on.exit(DBI::dbDisconnect(con, shutdown = TRUE), add = TRUE)

  tryCatch({
    DBI::dbGetQuery(con, sprintf("SELECT * FROM read_parquet('%s')", s3_path))
  }, error = function(e) {
    message("Error: No file exists for that name and year combination")
    message("Details: ", e$message)
    NULL
  })

}
