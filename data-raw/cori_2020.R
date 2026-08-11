library(tigris)
library(dplyr)
library(sf)
library(arrow)
library(cori.data.s3)

# CORI 2020: nonmetro counties per CBSA 2023 (OMB 2020-boundary delineation) +
# rural tracts in metro counties per RUCA 2020 (primary code >= 4)
# Both CBSA 2023 and RUCA 2020 are anchored to 2020 Census boundaries.

# --- RUCA 2020 (tract-level) from S3 ---
ruca_2020 <- arrow::read_parquet(
  "https://ruraldefinitions.s3.us-east-1.amazonaws.com/clean/ruca_2020.parquet"
)

# --- CBSA 2023 (county-level) via tigris ---
cbsa_year <- 2023
tigris_counties <- tigris::counties(year = cbsa_year) %>%
  dplyr::select(GEOID, CBSAFP) %>%
  sf::st_drop_geometry()

tigris_cbsas <- tigris::core_based_statistical_areas(year = cbsa_year) %>%
  dplyr::select(LSAD, CBSAFP) %>%
  sf::st_drop_geometry()

cbsa_2023 <- dplyr::left_join(tigris_counties, tigris_cbsas, by = "CBSAFP") %>%
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
cori_2020 <- ruca_2020 %>%
  dplyr::mutate(county_geoid = substr(geoid, 1, 5)) %>%
  dplyr::left_join(cbsa_2023, by = "county_geoid") %>%
  dplyr::mutate(
    name = "CORI",
    year = 2020,
    rural_def = dplyr::case_when(
      cbsa_type != "Metro"                       ~ "Nonmetro county",
      cbsa_type == "Metro" & is_rural == "Rural" ~ "Rural tract in metro county",
      TRUE                                       ~ "Metro county"
    ),
    is_rural = ifelse(rural_def == "Metro county", "Nonrural", "Rural")
  ) %>%
  dplyr::select(geoid, name, year, rural_def, is_rural)

# --- Push to S3 ---
parquet_buffer <- tempfile()
arrow::write_parquet(cori_2020, parquet_buffer)
cori.data.s3::put_s3_object("ruraldefinitions", "clean/cori_2020.parquet", file_path = parquet_buffer)

csv_buffer <- tempfile()
readr::write_csv(cori_2020, csv_buffer)
cori.data.s3::put_s3_object("ruraldefinitions", "download/cori_2020.csv", file_path = csv_buffer)
