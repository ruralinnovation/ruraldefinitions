library(tigris)
library(dplyr)
library(sf)
library(readxl)
library(curl)
library(here)
library(arrow)
library(cori.db)

i_am("data-raw/cori_2020.R")

con <- connect_to_db("core_data")
ruca_raw <- read_db(con, "rural_definitions_tract_2020")
DBI::dbDisconnect(con)

ruca_clean <- ruca_raw %>%
  mutate(
    name = "RUCA",
    year = 2020,
    is_rural = ifelse(
      rural_def == 1,
      "Rural",
      "Nonrural"
    ),
    rural_def = ifelse(
      rural_cbsa_2019 == "Nonmetro",
      "Nonmetro county",
      ifelse(
        rural_cbsa_2019 == "Metro" & rural_ruca_flag_2020 == 1,
        "Rural tract in metro county",
        "Metro county"
      )
    )
  ) %>%
  select(geoid, name, year, rural_def, is_rural)

parquet_buffer <- tempfile()
write_parquet(ruca_clean, parquet_buffer)
cori.db::put_s3_object("ruraldefinitions", "clean/cori_2020.parquet", file_path = parquet_buffer)

# Make available via download
csv_buffer <- tempfile()
readr::write_csv(ruca_clean, csv_buffer)
cori.db::put_s3_object("ruraldefinitions", "download/cori_2020.csv", file_path = csv_buffer)
