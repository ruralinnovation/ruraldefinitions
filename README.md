# ruraldefinitions

Package for easily accessing and manipulating federal rural definitions

```r
# install.packages("devtools")
devtools::install_github("ruralinnovation/ruraldefinitions")
```

## Getting started

County-level rural definitions are loaded into the package and can be directly 
accessed (e.g., `ruraldefinitions::cbsa_2020`). Tract-level definitions and 
lower can be accessed using the `get_definition` function which requires a 
definition name and year as parameters. For instance, the 
2020 CORI definition can be accessed with with `get_definition("cori", 2020)`.

Here are the definitions and years that are currently supported by the 
package:

| Name          | Year | Geographic Unit |
|:-------------|:----|:---------------|
| RUCA          | 2010 | Tract           |
| CORI          | 2020 | Tract           |
| CBSA          | 2020 | County          |
| NCHS          | 1990 | County          |
| NCHS          | 2006 | County          |
| NCHS          | 2013 | County          |
| NCHS          | 2023 | County          |
| RUCC          | 1974 | County          |
| RUCC          | 1983 | County          |
| RUCC          | 1993 | County          |
| RUCC          | 2003 | County          |
| RUCC          | 2013 | County          |
| RUCC          | 2023 | County          |
| UIC           | 1993 | County          |
| UIC           | 2003 | County          |
| UIC           | 2013 | County          |
| UIC           | 2024 | County          |

## Selecting a definition

If you are working with county data, we recommend using the CBSA or 
"Nonmetro" definition of rural. If you have access to Census tract data, 
we recommend using our rural definition which uses the Nonmetro and RUCA 
definitions to include rural tracts within metro counties.


If you'd like to read more about how we came to these decisions, we recommend 
reading our piece on [defining rural America](https://ruralinnovation.us/blog/defining-rural-america/) or 
our summary writeup in the Urban Institute's [Do No Harm Guide](https://www.urban.org/research/publication/do-no-harm-guide-crafting-equitable-data-narratives) on 
crafting equitable data narratives.

## Acronyms

- CORI: Center on Rural Innovation 
- RUCA: Rural-Urban Commuting Area Codes
- CBSA: Core-based Statistical Areas
- NCHS: National Center for Health Statistics
- RUCC: Rural-Urban Continuum Codes
- UIC: Urban Influence Codes




