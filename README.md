# ruraldefinitions

Package for easily accessing and manipulating federal rural definitions

```r
# install.packages("devtools")
devtools::install_github("ruralinnovation/ruraldefinitions")
```

## Getting started

County-level rural definitions are loaded into the package and can be directly 
accessed using `ruraldefinitions::cbsa_2020`. Tract-level definitions and 
lower can be accessed using the `get_definition` function which requires a 
definition name and year as parameters. For instance, the 
2020 CORI definition can be accessed with with `get_definition("cori", 2020)`.

Here are the definitions and years that are currently supported by the 
package:

| Name          | Year | Geographic Unit |
| ------------- | ---- | --------------- |
| RUCA          | 2010 | Tract           |
| CORI          | 2020 | Tract           |
| CBSA          | 2020 | County          |


