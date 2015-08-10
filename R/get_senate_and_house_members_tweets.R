################################################################################
# This script collects the last 3200 tweets from US congress man and 
# representatives using the R package 'twitterreport'. You can download this
# package at http://github.com/gvegayon/twitterreport.
################################################################################

rm(list=ls())

library(twitterreport)
source("R/credentials.R")

# Loading data
data("senators_profile")
load("data/congress_info.RData")

# Getting the data for the senate
accounts_senate <- senators_profile$tw_screen_name
n               <- length(accounts_senate)
tweets_senate   <- vector("list",n)
for (i in 1:n) {
  tweets_senate[[i]] <- tw_api_get_statuses_user_timeline(
    accounts_senate[i], key, count = 3200)
  save(tweets_senate, file = 'data/tweets_senate.rdata', compress = 'xz')
}

# Getting the data for the congress
accounts_house <- unlist(twitter_accounts_house)
n              <- length(accounts_house)
tweets_house   <- vector("list",n)
for (i in 1:n) {
  tweets_house[[i]] <- tw_api_get_statuses_user_timeline(
    accounts_house[i], key, count = 3200)
  save(tweets_house, file = 'data/tweets_house', compress = 'xz')
}

