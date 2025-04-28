# ruraldefinitions

A package for easily accessing and manipulating federal rural definitions

```r
# install.packages("devtools")
devtools::install_github("ruralinnovation/ruraldefinitions")
```

## Getting started

County-level rural definitions are loaded into the package and can be directly 
accessed (e.g., `ruraldefinitions::cbsa_2020`). Tract-level definitions and 
lower can be accessed using the `get_definition` function which requires a 
definition name and year as parameters. For instance, the 
2020 CORI definition can be accessed with `get_definition("cori", 2020)`.

Here are the definitions and years that are currently supported by the 
package:

| Name          | Year | Geographic Unit | Download |
|:--------------|:-----|:----------------|:---------|
| Census        | 2010 | Block           | Available through package |
| Census        | 2020 | Block           | Available through package |
| RUCA          | 1990 | Tract           | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/ruca_1990.csv) |
| RUCA          | 2000 | Tract           | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/ruca_2000.csv) |
| RUCA          | 2010 | Tract           | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/ruca_2010.csv) |
| CORI          | 2020 | Tract           | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/cori_2020.csv) |
| CBSA          | 2020 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/cbsa_2020.csv) |
| NCHS          | 1990 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/nchs_1990.csv) |
| NCHS          | 2006 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/nchs_2006.csv) |
| NCHS          | 2013 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/nchs_2013.csv) |
| NCHS          | 2023 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/nchs_2023.csv) |
| RUCC          | 1974 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/rucc_1974.csv) |
| RUCC          | 1983 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/rucc_1983.csv) |
| RUCC          | 1993 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/rucc_1993.csv) |
| RUCC          | 2003 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/rucc_2003.csv) |
| RUCC          | 2013 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/rucc_2013.csv) |
| RUCC          | 2023 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/rucc_2023.csv) |
| UIC           | 1993 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/uic_1993.csv) |
| UIC           | 2003 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/uic_2003.csv) |
| UIC           | 2013 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/uic_2013.csv) |
| UIC           | 2024 | County          | [CSV](https://ruraldefinitions.s3.us-east-1.amazonaws.com/download/uic_2024.csv) |


## Selecting a definition

If you are working with county data, we recommend using the CBSA or 
"Nonmetro" definition of rural. If you have access to Census tract data, 
we recommend using our rural definition which uses the Nonmetro and RUCA 
definitions to include rural tracts within metro counties.


If you'd like to read more about how we came to these decisions, we recommend 
reading our piece on [defining rural America](https://ruralinnovation.us/blog/defining-rural-america/) or 
our summary writeup in the Urban Institute's [Do No Harm Guide](https://www.urban.org/research/publication/do-no-harm-guide-crafting-equitable-data-narratives) on 
crafting equitable data narratives.

## Available rural definitions

**[CORI (Center on Rural Innovation)](https://ruralinnovation.us/about/the-definition-of-rural/)**  
Classifies Census tracts as rural if they are located within 
nonmetropolitan counties (based on the OMB definition) or if 
they score 4 or higher on the USDA’s Rural-Urban 
Commuting Area (RUCA) codes.

**[RUCA (Rural-Urban Commuting Area Codes)](https://www.ers.usda.gov/data-products/rural-urban-commuting-area-codes)**  
Classifies Census tracts into categories based on 
measures of economic integration, such as population 
density, urbanization, and commuting patterns. Published 
by the U.S. Department of Agriculture (USDA).

**[CBSA (Core-Based Statistical Areas)](https://www.census.gov/programs-surveys/metro-micro.html)**  
Designates counties as metropolitan, micropolitan, or 
noncore based on population size and the presence of 
urban centers. Micropolitan and noncore counties are 
considered nonmetropolitan. Defined by the Office of 
Management and Budget (OMB).

**[NCHS (National Center for Health Statistics)](https://www.cdc.gov/nchs/data-analysis-tools/urban-rural.html)**  
Subdivides the OMB definition into four metropolitan 
and two nonmetropolitan categories. Metropolitan 
counties with populations of 1 million or more are 
further classified as either central (e.g., inner cities) 
or fringe (e.g., suburbs).

**[RUCC (Rural-Urban Continuum Codes)](https://www.ers.usda.gov/data-products/rural-urban-continuum-codes)**  
Metropolitan counties are 
distinguished by population size, while nonmetropolitan 
counties are classified by degree of urbanization and 
proximity to a metropolitan area. Published by the USDA.

**[UIC (Urban Influence Codes)](https://www.ers.usda.gov/data-products/urban-influence-codes)**  
Classifications are based on population size, 
degree of urbanization, and adjacency to metropolitan areas. Published by the USDA.

**[Census (Census Bureau Rural Definition)](https://www.census.gov/programs-surveys/geography/guidance/geo-areas/urban-rural.html)**  
Defines rural areas as Census blocks not located within 
an urban area. Urban areas are determined using 
thresholds for population size and housing density.




