library(dplyr)
library(sf)
library(readxl)
library(curl)
library(arrow)

url <- "https://ruraldefinitions.s3.us-east-1.amazonaws.com/raw/ruca1990.xls"
tempfile <- tempfile(fileext = ".xls")

curl_download(url, tempfile)
ruca_raw <- read_excel(
  tempfile,
  sheet = "Data"
)

ruca_clean <- ruca_raw %>%
  rename(
    geoid = `FIPS state-county-tract code`
  ) %>%
  mutate(
    geoid = stringr::str_replace_all(geoid, "\\.", ""),
    name = "RUCA",
    year = 1990,
    rural_def = as.character(as.integer(`Rural-urban commuting area code`)),
    is_rural = ifelse(
      rural_def >= 4,
      "Rural",
      "Nonrural"
    ),
    rural_def = case_when(
      rural_def == "1" ~ "1. Metropolitan area core: primary flow within an urbanized area (UA)",
      rural_def == "2" ~ "2. Metropolitan area high commuting: primary flow 30% or more to a UA",
      rural_def == "3" ~ "3. Metropolitan area low commuting: primary flow 5% to 30% to a UA",
      rural_def == "4" ~ "4. Large town core: primary flow within a place of 10,000 to 49,999",
      rural_def == "5" ~ "5. Large town high commuting: primary flow 30% or more to a place of 10,000 to 49,999",
      rural_def == "6" ~ "6. Large town low commuting: primary flow 5% to 30% to a place of 10,000 to 49,999",
      rural_def == "7" ~ "7. Small town core: primary flow within a place of 2,500 to 9,999",
      rural_def == "8" ~ "8. Small town high commuting: primary flow 30% or more to a place of 2,500 to 9,999",
      rural_def == "9" ~ "9. Small town low commuting: primary flow 5% to 30% to a place of 2,500 to 9,999",
      rural_def == "10" ~ "10. Rural areas: primary flow to a tract without a place of 2,500 or more",
      rural_def == "99" ~ "99. Not coded: Tracts with little or no population and no commuting flows",
      TRUE ~ rural_def  # Keep other values unchanged
    )
  ) %>%
  select(geoid, name, year, rural_def, is_rural)

parquet_buffer <- tempfile()
write_parquet(ruca_clean, parquet_buffer)
cori.db::put_s3_object("ruraldefinitions", "clean/ruca_1990.parquet", file_path = parquet_buffer)
