# Script for loading all National Center for Health Statistics (NCHS)
# definitions: 1990, 2006, 2013, 2023

library(dplyr)
library(readr)

nchs_all_raw <- read_csv("https://ruraldefinitions.s3.us-east-1.amazonaws.com/raw/NCHSurb-rural-codes.csv")

nchs_all_clean <- nchs_all_raw %>%
  tidyr::pivot_longer(
    tidyr::starts_with("CODE"),
    names_to = "year",
    values_to = "rural_def"
  ) %>%
  mutate(
    year = as.numeric(stringr::str_replace_all(year, "CODE", "")),
    geoid = paste0(
      stringr::str_pad(STFIPS, 2, side = "left", pad = "0"),
      stringr::str_pad(CTYFIPS, 3, side = "left", pad = "0")
    ),
    is_rural = ifelse(
      rural_def > 4,
      "Rural",
      "Nonrural"
    ),
    rural_def = as.character(rural_def),
    rural_def = case_when(
      rural_def == "1" ~ "1. Large central metro",
      rural_def == "2" ~ "2. Large fringe metro",
      rural_def == "3" ~ "3. Medium metro",
      rural_def == "4" ~ "4. Small metro",
      rural_def == "5" ~ "5. Micropolitan",
      rural_def == "6" ~ "6. Noncore",
      TRUE ~ rural_def  # Keep other values unchanged
    ),
    name = "NCHS"
  ) %>%
  filter(!is.na(rural_def)) %>%
  select(geoid, name, year, rural_def, is_rural)

# Filter to specific years and create package data

# 2023
nchs_2023 <- nchs_all_clean %>%
  filter(year == 2023)
usethis::use_data(nchs_2023, overwrite = TRUE)

csv_buffer <- tempfile()
readr::write_csv(nchs_2023, csv_buffer)
cori.db::put_s3_object("ruraldefinitions", "download/nchs_2023.csv", file_path = csv_buffer)

# 2013
nchs_2013 <- nchs_all_clean %>%
  filter(year == 2013)
usethis::use_data(nchs_2013, overwrite = TRUE)

csv_buffer <- tempfile()
readr::write_csv(nchs_2013, csv_buffer)
cori.db::put_s3_object("ruraldefinitions", "download/nchs_2013.csv", file_path = csv_buffer)

# 2006
nchs_2006 <- nchs_all_clean %>%
  filter(year == 2006)
usethis::use_data(nchs_2006, overwrite = TRUE)

csv_buffer <- tempfile()
readr::write_csv(nchs_2006, csv_buffer)
cori.db::put_s3_object("ruraldefinitions", "download/nchs_2006.csv", file_path = csv_buffer)

# 1990

nchs_1990 <- nchs_all_clean %>%
  filter(year == 1990)
usethis::use_data(nchs_1990, overwrite = TRUE)

csv_buffer <- tempfile()
readr::write_csv(nchs_1990, csv_buffer)
cori.db::put_s3_object("ruraldefinitions", "download/nchs_1990.csv", file_path = csv_buffer)

