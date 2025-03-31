library(dplyr)
library(readr)
library(curl)
library(readxl)

url <- "https://ruraldefinitions.s3.us-east-1.amazonaws.com/raw/ruralurbancodes1974.xls"
tempfile <- tempfile(fileext = ".xls")

curl_download(url, tempfile)
rucc_dta_raw <- read_excel(tempfile)

rucc_1974 <- rucc_dta_raw %>%
  rename(
    geoid = `FIPS Code`
  ) %>%
  mutate(
    is_rural = ifelse(
      `1974 Rural-urban Continuum Code` > 3,
      "Rural",
      "Nonrural"
    ),
    rural_def = `1974 Rural-urban Continuum Code`,
    name = "RUCC",
    year = 1974
  ) %>%
  filter(!is.na(is_rural)) %>%
  select(geoid, name, year, rural_def, is_rural)

usethis::use_data(rucc_1974, overwrite = TRUE)
