library(dplyr)
library(readxl)
library(curl)
library(arrow)

# Methodology notes vs. 2010 RUCA (source: USDA ERS documentation/users guide):
#   - Urban core threshold tightened: "a census tract was considered part of an
#     urban core only if at least half the tract's residents lived in a single
#     urban area" (2010 allowed >30% in a single UA OR >=50% across any UA)
#   - "The Census Bureau changed the criteria used to delineate urban areas
#     between 2010 and 2020, changing the minimum population threshold from
#     2,500 residents to 5,000 residents and adding an alternative minimum of
#     2,000 housing units" — eliminates Urban Clusters of 2,500-4,999
#   - "Census tracts with no residents...are coded based on their location:
#     metropolitan core, micropolitan core, small town core, or rural."
#     Code 99 reserved for water-only tracts (no land area, no population)
#   - "About 87 percent of locations had the same RUCA codes in both the
#     vintage 2010 and vintage 2020 data"; the two vintages are not directly
#     comparable due to the above methodological shifts

url <- "https://www.ers.usda.gov/media/5441/2020-rural-urban-commuting-area-codes-census-tracts.xlsx?v=39483"
tempfile_path <- tempfile(fileext = ".xlsx")

curl_download(url, tempfile_path)
ruca_raw <- read_excel(
  tempfile_path,
  sheet = 2,
  skip = 1
)

# Inspect column names to confirm structure before renaming
message("Column names: ", paste(names(ruca_raw), collapse = ", "))

ruca_clean <- ruca_raw %>%
  rename(
    geoid = 1,            # State-County-Tract FIPS Code (first column)
    ruca_code = 17         # Primary RUCA Code 2020 (seventeenth column)
  ) %>%
  mutate(
    geoid = as.character(geoid),
    # Pad to 11 characters to preserve leading zeros
    geoid = stringr::str_pad(geoid, width = 11, side = "left", pad = "0"),
    name = "RUCA",
    year = 2020,
    ruca_code = as.character(ruca_code),
    # Code 99 in 2020 = water-only tracts only; excluded from Rural
    is_rural = ifelse(
      ruca_code %in% c("4", "5", "6", "7", "8", "9", "10"),
      "Rural",
      "Nonrural"
    ),
    rural_def = case_when(
      ruca_code == "1"  ~ "1. Metropolitan area core: primary flow within an urbanized area (UA)",
      ruca_code == "2"  ~ "2. Metropolitan area high commuting: primary flow 30% or more to a UA",
      ruca_code == "3"  ~ "3. Metropolitan area low commuting: primary flow 10% to 30% to a UA",
      ruca_code == "4"  ~ "4. Micropolitan area core: primary flow within an Urban Cluster of 10,000 to 49,999 (large UC)",
      ruca_code == "5"  ~ "5. Micropolitan high commuting: primary flow 30% or more to a large UC",
      ruca_code == "6"  ~ "6. Micropolitan low commuting: primary flow 10% to 30% to a large UC",
      # UC minimum raised from 2,500 to 5,000; ERS defines code 7 as "urban area of 9,999 or fewer people"
      ruca_code == "7"  ~ "7. Small town core: primary flow within an urban area of 9,999 or fewer people (small UC)",
      ruca_code == "8"  ~ "8. Small town high commuting: primary flow 30% or more to a small UC",
      ruca_code == "9"  ~ "9. Small town low commuting: primary flow 10% to 30% to a small UC",
      ruca_code == "10" ~ "10. Rural areas: primary flow to a tract outside a UA or UC",
      ruca_code == "99" ~ "99. Not coded: Water-only Census tract",
      TRUE ~ ruca_code
    )
  ) %>%
  select(geoid, name, year, rural_def, is_rural)

parquet_buffer <- tempfile()
write_parquet(ruca_clean, parquet_buffer)
cori.data.s3::put_s3_object("ruraldefinitions", "clean/ruca_2020.parquet", file_path = parquet_buffer)

csv_buffer <- tempfile()
readr::write_csv(ruca_clean, csv_buffer)
cori.data.s3::put_s3_object("ruraldefinitions", "download/ruca_2020.csv", file_path = csv_buffer)
