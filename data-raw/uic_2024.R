library(dplyr)
library(readr)
library(curl)
library(readxl)

url <- "https://ruraldefinitions.s3.us-east-1.amazonaws.com/raw/UrbanInfluenceCodes2024.xlsx"
tempfile <- tempfile(fileext = ".xlsx")

curl_download(url, tempfile)
uic_dta_raw <- read_excel(
  tempfile
)

uic_2024 <- uic_dta_raw %>%
  rename(
    geoid = FIPS
  ) %>%
  mutate(
    is_rural = ifelse(
      UIC_2024 > 6,
      "Rural",
      "Nonrural"
    ),
    rural_def = paste0(
      UIC_2024,
      ". ",
      Description
    ),
    name = "UIC",
    year = 2024
  ) %>%
  filter(!is.na(is_rural)) %>%
  select(geoid, name, year, rural_def, is_rural)

usethis::use_data(uic_2024, overwrite = TRUE)

# Make available via download
csv_buffer <- tempfile()
readr::write_csv(uic_2024, csv_buffer)
cori.db::put_s3_object("ruraldefinitions", "download/uic_2024.csv", file_path = csv_buffer)
