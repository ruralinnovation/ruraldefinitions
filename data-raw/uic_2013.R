library(dplyr)
library(readr)
library(curl)
library(readxl)

url <- "https://ruraldefinitions.s3.us-east-1.amazonaws.com/raw/UrbanInfluenceCodes2013.xls"
tempfile <- tempfile(fileext = ".xls")

curl_download(url, tempfile)
uic_dta_raw <- read_excel(
  tempfile
)

uic_2013 <- uic_dta_raw %>%
  rename(
    geoid = FIPS
  ) %>%
  mutate(
    is_rural = ifelse(
      UIC_2013 > 7,
      "Rural",
      "Nonrural"
    ),
    rural_def = paste0(
      UIC_2013,
      ". ",
      Description
    ),
    name = "UIC",
    year = 2013
  ) %>%
  filter(!is.na(is_rural)) %>%
  select(geoid, name, year, rural_def, is_rural)

usethis::use_data(uic_2013, overwrite = TRUE)

csv_buffer <- tempfile()
readr::write_csv(uic_2013, csv_buffer)
cori.db::put_s3_object("ruraldefinitions", "download/uic_2013.csv", file_path = csv_buffer)
