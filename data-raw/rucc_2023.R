library(dplyr)
library(readr)
library(curl)
library(readxl)

url <- "https://ruraldefinitions.s3.us-east-1.amazonaws.com/raw/Ruralurbancontinuumcodes2023.xlsx"
tempfile <- tempfile(fileext = ".xlsx")

curl_download(url, tempfile)
rucc_dta_raw <- read_excel(
  tempfile,
  sheet = "Rural-urban Continuum Code 2023"
)

rucc_2023 <- rucc_dta_raw %>%
  rename(
    geoid = FIPS
  ) %>%
  mutate(
    is_rural = ifelse(
      RUCC_2023 > 3,
      "Rural",
      "Nonrural"
    ),
    rural_def = paste0(
      RUCC_2023,
      ". ",
      Description
    ),
    name = "RUCC",
    year = 2023
  ) %>%
  filter(!is.na(is_rural)) %>%
  select(geoid, name, year, rural_def, is_rural)

usethis::use_data(rucc_2023, overwrite = TRUE)
