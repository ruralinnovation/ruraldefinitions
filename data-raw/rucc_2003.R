library(dplyr)
library(readr)
library(curl)
library(readxl)

url <- "https://ruraldefinitions.s3.us-east-1.amazonaws.com/raw/ruralurbancodes2003.xls"
tempfile <- tempfile(fileext = ".xls")

curl_download(url, tempfile)
rucc_dta_raw <- read_excel(tempfile)

rucc_2003 <- rucc_dta_raw %>%
  rename(
    geoid = `FIPS Code`
  ) %>%
  mutate(
    is_rural = ifelse(
      `2003 Rural-urban Continuum Code` > 3,
      "Rural",
      "Nonrural"
    ),
    rural_def = paste0(
      `2003 Rural-urban Continuum Code`,
      ". ",
      `Description for 2003 codes`
    ),
    name = "RUCC",
    year = 2003
  ) %>%
  filter(!is.na(is_rural)) %>%
  select(geoid, name, year, rural_def, is_rural)

usethis::use_data(rucc_2003, overwrite = TRUE)
