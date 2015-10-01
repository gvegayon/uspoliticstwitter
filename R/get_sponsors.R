# This script gets the co-sponsorship between us house of representatives
# http://developer.nytimes.com/docs/read/congress_api
# https://github.com/unitedstates/congress/wiki/bills

rm(list=ls())

library(stringr)
library(RCurl)
library(httr)

web <- getURL('http://www.house.gov/committees/')
committees <- str_match_all(web,'[<]a href="http:\\/\\/([a-z./]+)"[>]([a-zA-Z\\s]+)')[[1]][,-1]
as.data.frame(committees, stringsAsFactors = FALSE)

