## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(rnassqs)

# returns a list of fields that you can query
nassqs_params()

## -----------------------------------------------------------------------------
nassqs_params("agg_level_desc", "source_desc")

