library(dplyr)
library(readr)
library(curl)
library(readxl)

url <- "https://ruraldefinitions.s3.us-east-1.amazonaws.com/raw/UrbanInfluenceCodes.xls"
tempfile <- tempfile(fileext = ".xls")

curl_download(url, tempfile)
uic_dta_raw <- read_excel(
  tempfile,
  sheet = "Urban Influence Codes"
)

uic_1993 <- uic_dta_raw %>%
  rename(
    geoid = `FIPS Code`
  ) %>%
  mutate(
    is_rural = ifelse(
      `1993 Urban Influence Code` > 6,
      "Rural",
      "Nonrural"
    ),
    rural_def = paste0(
      `1993 Urban Influence Code`,
      ". ",
      `1993 Urban Influence Code description`
    ),
    name = "UIC",
    year = 1993
  ) %>%
  filter(!is.na(is_rural)) %>%
  select(geoid, name, year, rural_def, is_rural)


uic_2003 <- uic_dta_raw %>%
  rename(
    geoid = `FIPS Code`
  ) %>%
  mutate(
    is_rural = ifelse(
      `2003 Urban Influence Code` > 7,
      "Rural",
      "Nonrural"
    ),
    rural_def = paste0(
      `2003 Urban Influence Code`,
      ". ",
      `2003 Urban Influence Code description`
    ),
    name = "UIC",
    year = 2003
  ) %>%
  filter(!is.na(is_rural)) %>%
  select(geoid, name, year, rural_def, is_rural)

usethis::use_data(uic_1993, overwrite = TRUE)
usethis::use_data(uic_2003, overwrite = TRUE)

csv_buffer <- tempfile()
readr::write_csv(uic_1993, csv_buffer)
cori.db::put_s3_object("ruraldefinitions", "download/uic_1993.csv", file_path = csv_buffer)


csv_buffer <- tempfile()
readr::write_csv(uic_2003, csv_buffer)
cori.db::put_s3_object("ruraldefinitions", "download/uic_2003.csv", file_path = csv_buffer)
