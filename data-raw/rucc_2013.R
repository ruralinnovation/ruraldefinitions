library(dplyr)
library(readr)
library(curl)
library(readxl)

url <- "https://ruraldefinitions.s3.us-east-1.amazonaws.com/raw/ruralurbancodes2013.xls"
tempfile <- tempfile(fileext = ".xls")

curl_download(url, tempfile)
rucc_dta_raw <- read_excel(
  tempfile,
  sheet = "Rural-urban Continuum Code 2013"
)

rucc_2013 <- rucc_dta_raw %>%
  rename(
    geoid = FIPS
  ) %>%
  mutate(
    is_rural = ifelse(
      RUCC_2013 > 3,
      "Rural",
      "Nonrural"
    ),
    rural_def = paste0(
      RUCC_2013,
      ". ",
      Description
    ),
    name = "RUCC",
    year = 2013
  ) %>%
  filter(!is.na(is_rural)) %>%
  select(geoid, name, year, rural_def, is_rural)

usethis::use_data(rucc_2013, overwrite = TRUE)
