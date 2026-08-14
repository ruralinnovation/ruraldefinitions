# Get definition from S3

Get definition from S3

## Usage

``` r
get_definition(name = c("census", "cori", "ruca"), year)
```

## Arguments

- name:

  Rural definition to retrieve. One of "census", "cori", or "ruca".

- year:

  Publication year of the desired definition. If omitted, defaults to
  the latest year available on S3 for name. Must be one of the years
  available on S3 for name.
