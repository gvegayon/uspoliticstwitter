library(RMySQL)
library(twitterreport)
library(ggmap)

# Loading the file credentials. It only has one line that looks like this
# sqlkey <- list(dbname='mydb', usr='myuser', host='myhost's ip')
source("R/credentials.R")

# Creating the connection
con <- dbConnect(RMySQL::MySQL(), dbname=sqlkey$dbname, username=sqlkey$usr,
                 host=sqlkey$host)

# Getting the data and writing the right format
tweets <- dbGetQuery(con, "SELECT * FROM tweets ORDER BY timestamp DESC LIMIT 10000")

# created_at
tweets$timestamp <- strptime(tweets$timestamp, "%a %b %d %T +0000 %Y")
n <- 2000
locations <- vector('list',n)
for (i in 1:n) {
  locations[[i]] <- tryCatch(geocode(tweets$location[i], ), error=function(e) e)
  if (!(i %% 20)) save.image('data/nailen_tweets.rdata')
  message(i,' out of ',n,' done.')
}
# geo <- lapply(tweets$location, function(x) {
#   y <- tryCatch(geocode(x), error=function(e) e)
#   if (inherits(y, 'error')) return(NULL)
#   y
# })

save.image('data/nailen_tweets.rdata')

# Coordinates
# test <- which(sapply(geo,is.null))
# geo[test] <- lapply(length(test), function(x) cbind(lon=NA,lat=NA))
# tweets <- cbind(tweets,do.call(rbind,geo))
# rm(test)
# 
# # Gender
# profiles <- lapply(tweets$user_name,tw_api_get_users_show,twitter_token=twkey)
# 
# with(tweets,plot(lon,lat))
# 
# 
# # Processing the data (dates and geo codes)
# # Getting the data
# 
# elements <- tw_extract(tweets$content)
# plot(tw_table(elements))
# 
# summary(con)

dbDisconnect(con)
