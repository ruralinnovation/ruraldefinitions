library(dplyr)
library(readr)
library(curl)
library(readxl)

url <- "https://ruraldefinitions.s3.us-east-1.amazonaws.com/raw/cd8393.xls"
tempfile <- tempfile(fileext = ".xls")

curl_download(url, tempfile)
rucc_dta_raw <- read_excel(tempfile)

rucc_1983 <- rucc_dta_raw %>%
  rename(
    geoid = `FIPS`
  ) %>%
  mutate(
    is_rural = ifelse(
      `1983 Rural-urban Continuum Code` > 3,
      "Rural",
      "Nonrural"
    ),
    name = "RUCC",
    year = 1983,
    rural_def = `1983 Rural-urban Continuum Code`
  ) %>%
  filter(!is.na(is_rural)) %>%
  select(geoid, name, year, rural_def, is_rural)

rucc_1993 <- rucc_dta_raw %>%
  rename(
    geoid = `FIPS`
  ) %>%
  mutate(
    is_rural = ifelse(
      `1993 Rural-urban Continuum Code` > 3,
      "Rural",
      "Nonrural"
    ),
    name = "RUCC",
    year = 1993,
    rural_def = `1993 Rural-urban Continuum Code`
  ) %>%
  filter(!is.na(is_rural)) %>%
  select(geoid, name, year, rural_def, is_rural)

usethis::use_data(rucc_1983, overwrite = TRUE)
usethis::use_data(rucc_1993, overwrite = TRUE)
