rm(list=ls())

library(RCurl)
library(XML)
library(stringr)
library(twitterreport)
library(dplyr)

################################################################################
# Data base from house.gov
################################################################################
# Key to Room Codes
# CHOB: Cannon House Office Building
# LHOB: Longworth House Office Building
# RHOB: Rayburn House Office Building

# Getting the table
ca_assembly <- readHTMLTable("http://assembly.ca.gov/assemblymembers",stringsAsFactors=FALSE)
ca_assembly <- bind_rows(ca_assembly)

# Andling names
colnames(ca_assembly) <- tolower(str_replace_all(colnames(ca_assembly), '(^\\s+|\\s+$)', ''))
colnames(ca_assembly) <- str_replace_all(colnames(ca_assembly), '[ ]+', '_')
colnames(ca_assembly) <- str_replace_all(colnames(ca_assembly), '&', 'and')

# Getting the info (URLS)
ass_members <- getURLContent("http://assembly.ca.gov/assemblymembers")

website <- sapply(ca_assembly$name, function(x,...) {
  z <- str_replace(str_extract(ass_members,paste0('(?<=href[=]).+>',x)), x, '')
  str_extract(z, '(?<=["]).+(?=["])')
  }
)

ca_assembly$website <- website
rm(website)

################################################################################
# Getting twitter accounts
################################################################################
# Loop
twitter_accounts_ca_assembly <- vector("list",nrow(ca_assembly))
n <- length(twitter_accounts_ca_assembly)
for (i in 1:n) {
  twitter_accounts_ca_assembly[[i]] <- tw_get_tw_account(ca_assembly$website[i],quiet = FALSE)
  if (!(i %% 10)) save.image("data/ca_assembly_info.rdata")
}

save.image("data/ca_assembly_info.rdata")
