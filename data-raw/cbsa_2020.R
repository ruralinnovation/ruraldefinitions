library(tigris)
library(dplyr)
library(sf)

cbsa_year <- 2020
tigris_counties <- tigris::counties(year = cbsa_year) %>%
  dplyr::select(GEOID, CBSAFP) %>%
  sf::st_drop_geometry()

tigris_cbsas <- tigris::core_based_statistical_areas(year = cbsa_year) %>%
  dplyr::select(LSAD, CBSAFP) %>%
  sf::st_drop_geometry()

# Generate CBSA definition for 2020
cbsa_2020 <- dplyr::left_join(
    tigris_counties,
    tigris_cbsas,
    by = "CBSAFP"
  ) %>%
  dplyr::rename(
    geoid = GEOID,
    rural_def = LSAD
  ) %>%
  dplyr::select(geoid, rural_def) %>%
  mutate(
    name = "CBSA",
    year = cbsa_year,
    rural_def = tidyr::replace_na(rural_def, "Non-CBSA"),
    rural_def = ifelse(
      rural_def == "M1",
      "Metro",
      ifelse(
        rural_def == "M2",
        "Micro", "Non-CBSA"
      )
    ),
    is_rural = ifelse(rural_def == "Metro", "Nonrural", "Rural")
  ) %>%
  select(
    geoid, name, year, rural_def, is_rural
  )

usethis::use_data(cbsa_2020, overwrite = TRUE)


