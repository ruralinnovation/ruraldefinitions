library(dplyr)
library(sf)
library(readxl)
library(curl)
library(arrow)

url <- "https://ruraldefinitions.s3.us-east-1.amazonaws.com/raw/ruca00.xls"
tempfile <- tempfile(fileext = ".xls")

curl_download(url, tempfile)
ruca_raw <- read_excel(
  tempfile,
  sheet = "Data"
)

ruca_clean <- ruca_raw %>%
  rename(
    geoid = `State County Tract Code`
  ) %>%
  mutate(
    name = "RUCA",
    year = 2000,
    rural_def = as.character(`RUCA Primary Code 2000`),
    is_rural = ifelse(
      rural_def >= 4,
      "Rural",
      "Nonrural"
    ),
    rural_def = case_when(
      rural_def == "1" ~ "1. Metropolitan area core: primary flow within an urbanized area (UA)",
      rural_def == "2" ~ "2. Metropolitan area high commuting: primary flow 30% or more to a UA",
      rural_def == "3" ~ "3. Metropolitan area low commuting: primary flow 5% to 30% to a UA",
      rural_def == "4" ~ "4. Micropolitan area core: primary flow within an Urban Cluster of 10,000 to 49,999 (large UC)",
      rural_def == "5" ~ "5. Micropolitan high commuting: primary flow 30% or more to a large UC",
      rural_def == "6" ~ "6. Micropolitan low commuting: primary flow 10% to 30% to a large UC",
      rural_def == "7" ~ "7. Small town core: primary flow within an Urban Cluster of 2,500 to 9,999 (small UC)",
      rural_def == "8" ~ "8. Small town high commuting: primary flow 30% or more to a small UC",
      rural_def == "9" ~ "9. Small town low commuting: primary flow 10% to 30% to a small UC",
      rural_def == "10" ~ "10. Rural areas: primary flow to a tract outside a UA or UC",
      rural_def == "99" ~ "99. Not coded: Census tract has zero population and no rural-urban identifier information",
      TRUE ~ rural_def  # Keep other values unchanged
    )
  ) %>%
  select(geoid, name, year, rural_def, is_rural)

parquet_buffer <- tempfile()
write_parquet(ruca_clean, parquet_buffer)
cori.db::put_s3_object("ruraldefinitions", "clean/ruca_2000.parquet", file_path = parquet_buffer)
