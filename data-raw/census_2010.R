library(tigris)
library(sf)
library(dplyr)
library(here)
library(cori.utils)
library(httr)
library(arrow)

i_am("data-raw/census_2010.R")

state_id_crosswalk <- cori.utils::state_id_crosswalk

census_2010 <- tibble::tibble()

for (st_fips in state_id_crosswalk$state_fips) {

  url <- paste0(
    "https://ruraldefinitions.s3.us-east-1.amazonaws.com/raw/blocks_2019/tl_2019_",
    st_fips,
    "_tabblock10.zip"
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
      geoid = GEOID10,
      rural_def = UR10,
      urban_area_code = UACE10,
      aland = ALAND10,
      awater = AWATER10
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
      year = 2010
    ) %>%
    select(geoid, name, year, rural_def, is_rural)

  census_2010 <- bind_rows(census_2010, st_block_def)

  # Clean up temp files/dir
  unlink(tmp_zip)
  unlink(shp_file, force = TRUE)

}

parquet_buffer <- tempfile()
write_parquet(census_2010, parquet_buffer)
cori.db::put_s3_object("ruraldefinitions", "clean/census_2010.parquet", file_path = parquet_buffer)
