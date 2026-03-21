library(tigris)
library(dplyr)
library(sf)
library(arrow)
library(cori.db)

# CORI 2010: nonmetro counties per CBSA 2018 (OMB mid-decade update) +
# rural tracts in metro counties per RUCA 2010 (primary code >= 4)

# --- RUCA 2010 (tract-level) from S3 ---
ruca_2010 <- arrow::read_parquet(
  "https://ruraldefinitions.s3.us-east-1.amazonaws.com/clean/ruca_2010.parquet"
)

# --- CBSA 2018 (county-level) via tigris ---
cbsa_year <- 2018
tigris_counties <- tigris::counties(year = cbsa_year) %>%
  dplyr::select(GEOID, CBSAFP) %>%
  sf::st_drop_geometry()

tigris_cbsas <- tigris::core_based_statistical_areas(year = cbsa_year) %>%
  dplyr::select(LSAD, CBSAFP) %>%
  sf::st_drop_geometry()

cbsa_2018 <- dplyr::left_join(tigris_counties, tigris_cbsas, by = "CBSAFP") %>%
  dplyr::mutate(
    county_geoid = GEOID,
    cbsa_type = tidyr::replace_na(LSAD, "Non-CBSA"),
    cbsa_type = dplyr::case_when(
      cbsa_type == "M1" ~ "Metro",
      cbsa_type == "M2" ~ "Micro",
      TRUE              ~ "Non-CBSA"
    )
  ) %>%
  dplyr::select(county_geoid, cbsa_type)

# --- Join and apply CORI logic ---
cori_2010 <- ruca_2010 %>%
  dplyr::mutate(county_geoid = substr(geoid, 1, 5)) %>%
  dplyr::left_join(cbsa_2018, by = "county_geoid") %>%
  dplyr::mutate(
    name = "CORI",
    year = 2010,
    rural_def = dplyr::case_when(
      cbsa_type != "Metro"                    ~ "Nonmetro county",
      cbsa_type == "Metro" & is_rural == "Rural" ~ "Rural tract in metro county",
      TRUE                                    ~ "Metro county"
    ),
    is_rural = ifelse(rural_def == "Metro county", "Nonrural", "Rural")
  ) %>%
  dplyr::select(geoid, name, year, rural_def, is_rural)

# --- Push to S3 ---
parquet_buffer <- tempfile()
arrow::write_parquet(cori_2010, parquet_buffer)
cori.db::put_s3_object("ruraldefinitions", "clean/cori_2010.parquet", file_path = parquet_buffer)

csv_buffer <- tempfile()
readr::write_csv(cori_2010, csv_buffer)
cori.db::put_s3_object("ruraldefinitions", "download/cori_2010.csv", file_path = csv_buffer)
