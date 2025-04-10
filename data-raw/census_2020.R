library(tigris)
library(sf)
library(dplyr)
library(here)
library(cori.utils)
library(httr)
library(arrow)

i_am("data-raw/census_2020.R")

state_id_crosswalk <- cori.utils::state_id_crosswalk

census_2020 <- tibble::tibble()

for (st_fips in state_id_crosswalk$state_fips) {

  url <- paste0(
    "https://ruraldefinitions.s3.us-east-1.amazonaws.com/raw/blocks_2024/tl_2024_",
    st_fips,
    "_tabblock20.zip"
  )

  # Temp file to store the zip
  tmp_zip <- tempfile(fileext = ".zip")

  # Download the zip
  GET(url, write_disk(tmp_zip, overwrite = TRUE))

  # Unzip to temp directory
  tmp_dir <- tempdir()
  unzip(tmp_zip, exdir = tmp_dir)

  # Find the .shp file inside
  shp_file <- list.files(tmp_dir, pattern = "\\.shp$", full.names = TRUE)

  # Read with sf
  st_block_def <- st_read(shp_file) %>%
    sf::st_drop_geometry() %>%
    select(
      geoid = GEOID20,
      rural_def = UR20,
      urban_area_code = UACE20,
      housing_units = HOUSING20,
      pop = POP20,
      aland = ALAND20,
      awater = AWATER20
    ) %>%
    mutate(
      is_rural = ifelse(
        rural_def == "U",
        "Nonrural",
        ifelse(
          rural_def == "R",
          "Rural",
          NA
        )
      ),
      name = "Census",
      year = 2020
    ) %>%
    select(geoid, name, year, rural_def, is_rural)

  census_2020 <- bind_rows(census_2020, st_block_def)

  # Clean up temp files/dir
  unlink(tmp_zip)
  unlink(shp_file, force = TRUE)

}

parquet_buffer <- tempfile()
write_parquet(census_2020, parquet_buffer)
cori.db::put_s3_object("ruraldefinitions", "clean/census_2020.parquet", file_path = parquet_buffer)
