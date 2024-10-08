#' Get a count of number of records for given parameters.
#'
#' Returns the number of records that fit a set of parameters. 
#' Useful if your current parameter set returns more than the 50,000 
#' record limit.
#'
#' @export
#'
#' @param ... either a named list of parameters or a series of parameters to 
#'   form the query
#' @return integer that is the number of records that are returned from the 
#'   API in response to the query
#' @examples \dontrun{
#'   # Check the number of records returned for corn in 1995, Washington state
#'   params <- list(
#'     commodity_desc = "CORN",
#'     year = "2005",
#'     agg_level_desc = "STATE",
#'     state_name = "WASHINGTON"
#'   )
#'   
#'   records <- nassqs_record_count(params) 
#'   records  # returns 17
#' }
nassqs_record_count <- function(...) {
  params <- expand_list(...)
  nassqs_parse(nassqs_GET(params, api_path = "get_counts"))
}

#' Get yield records for a specified crop.
#'
#' Returns yields for other specified parameters. 
#' This function is intended to simplify common requests.
#'
#' @export
#'
#' @param ... either a named list of parameters or a series of parameters to 
#'   form the query
#' @return a data.frame of yields data
#' @examples \dontrun{
#'   # Get yields for wheat in 2012, all geographies
#'   params <- list(
#'     commodity_desc = "WHEAT", 
#'     year = "2012", 
#'     agg_level_desc = "STATE",
#'     state_alpha = "WA")
#'     
#'   yields <- nassqs_yields(params)
#'   head(yields)
#' }
nassqs_yields <- function(...) {
  params <- expand_list(...)
  params[['statisticcat_desc']] <- "YIELD"
  nassqs(params)
}


#' Get NASS Area given a set of parameters.
#'
#' @export
#'
#' @param ... either a named list of parameters or a series of parameters to 
#'   form the query
#' @param area the type of area to return. Default is all types.
#' @return a data.frame of acres data
#' @examples \dontrun{
#'   # Get Area bearing for Apples in Washington, 2012.
#'   params <- list(
#'     commodity_desc = "APPLES",
#'     year = "2012",
#'     state_name = "WASHINGTON",
#'     agg_level_desc = "STATE"
#'   )
#'   area <- nassqs_acres(params, area = "AREA BEARING")
#'   head(area)
#' }
nassqs_acres <- function(...,
                        area = c("AREA", "AREA PLANTED", "AREA BEARING", 
                                 "AREA BEARING & NON-BEARING",
                                 "AREA GROWN", "AREA HARVESTED", 
                                 "AREA IRRIGATED", "AREA NON-BEARING",
                                 "AREA PLANTED", "AREA PLANTED, NET")) {
  area <- match.arg(area, several.ok = TRUE)

  params <- expand_list(...)
  params[['unit_desc']] <- "ACRES"
  params[['statisticcat_desc']] <- area

  nassqs(params)
}


#' Allow querying for a given set of counties based on FIPS.
#' 
#' This wrapper allows specifying a list of counties by FIPS code.
#' It iterates over each state in the list of FIPS, downloading for each
#' separately and then concatenating.
#'
#' @export
#'
#' @param fips a list of 5-digit fips codes
#' @param ... either a named list of parameters or a series of parameters to 
#'   form the query
#' @return a data.frame of data for each fips code
#' @examples \dontrun{
#' nassqs_byfips(
#'   fips = c("19001", "17005", "17001"),
#'   commodity_desc = "CORN",
#'   year = 2019,
#'   statisticcat_desc = "YIELD")
#' }
nassqs_byfips <- function(fips, ...) {
  states <- unique(substr(fips, 1, 2))
  r <- lapply(states, function(st) {
    Sys.sleep(1)
    nassqs(
      state_fips_code = st,
      county_code = substr(grep(st, fips, value = TRUE), 3, 5),
      ...)
  })
  do.call("rbind", r)
}
