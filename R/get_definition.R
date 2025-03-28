#' Get definition from S3
#'
#' @param name Name of the rural definition
#' @param year Publication year of the desired definition
#' @export
get_definition <- function(name, year) {

  base_url <- "https://ruraldefinitions.s3.us-east-1.amazonaws.com/clean/"

  file_name <- paste0(
    tolower(name),
    "_",
    as.character(year),
    ".parquet"
  )

  definition_url <- paste0(base_url, file_name)

  result <- tryCatch({
    # Attempt to read the Parquet file from the URL
    df <- arrow::read_parquet(definition_url)
    return(df)
  }, error = function(e) {
    # Handle the error if the file doesn't exist or cannot be read
    message("Error: No file exists for that name and year combination")
    message("Details: ", e$message)
    return(NULL)
  }, finally = {
    message("Attempt to read the Parquet file completed.")
  })

  return(df)

}
