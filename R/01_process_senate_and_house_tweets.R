################################################################################
# Process the information collected from 0_get_senate_and_house_members....R
# Filters the data to a particular time range and merges it with the accounts
#
# In particular, we filter the data to
#  - US senate elections of 2014
#  - US house elections of 2014
# Both held in Tuesday, November 4, 2014. The data analysis is made between six
# months previous the election and the election day itself
################################################################################

# Set up
rm(list=ls())
library(dplyr)
library(twitterreport)

# Time window
ran <- c('2014-05-4','2014-11-04')
ran <- strptime(ran,'%Y-%m-%d',tz = 'UTC')

# Creating 3 equally lengthed time ranges
ranges <- round(seq(ran[1],ran[2],length.out = 4),'days')

load("data/tweets_senate.rdata")
load("data/senators_profile.rdata")

tweets_senate<-lapply(1:length(senators_profile$tw_id), function(i) 
  cbind(name=senators_profile$tw_name[i],tweets_senate[[i]]))
tweets_senate<-do.call(rbind,tweets_senate)

# Removing bad accounts
tweets_senate <- subset(tweets_senate, name!="NA")

# Filtering
senate_elect_2014 <- subset(
  tweets_senate, created_at >= ran[1] & created_at <= ran[2])
################################################################################
# Descriptive stats
time_group <- group_by(senate_elect_2014, screen_name)
table_freq_user <- summarise(time_group, 
          n=n(), 
          since=min(created_at),
          to=max(created_at))
table_freq_user$since <- round(table_freq_user$since,"days")
table_freq_user$to <- round(table_freq_user$to,"days")

################################################################################
# MENTION NETWORKS

# Filtering data
senate_t1 <- subset(senate_elect_2014, created_at < ranges[2])
senate_t2 <- subset(senate_elect_2014, created_at < ranges[3] & created_at >= ranges[2])
senate_t3 <- subset(senate_elect_2014, created_at >= ranges[3])

# Extracting components
elements_t1 <- tw_extract(senate_t1$text)
elements_t2 <- tw_extract(senate_t2$text)
elements_t3 <- tw_extract(senate_t3$text)

# Creating networks

# This will be used for creating networks later
data(senators)
groups <- data.frame(group=senators$party, name=senators_profile$tw_screen_name,
                     stringsAsFactors = TRUE)

senate_net_t1 <- tw_network(senate_t1$screen_name, elements_t1$mention,
                            only.from = TRUE, group = groups, min.interact = 2)

plot(senate_net_t1)

senate_net_t2 <- tw_network(senate_t2$screen_name, elements_t2$mention,
                            only.from = TRUE, group = groups, min.interact = 2)

plot(senate_net_t2)

senate_net_t3 <- tw_network(senate_t3$screen_name, elements_t3$mention,
                            only.from = TRUE, group = groups, min.interact = 2)

plot(senate_net_t3)
# library(igraph)
# 
# with(senate_net_t1,plot(graph_from_data_frame(links, vertices=nodes),
#                         vertex.size=1, layout=coords))

################################################################################
# Probability of mentioning an individual from a different party
elements <- tw_extract(tweets_senate$text, "mention")
senate_net <- tw_network(tweets_senate$screen_name, elements$mention, 
                         group = groups, only.from = TRUE)
net <- senate_net$links
colnames(net)[1] <- "id"
net <- left_join(net,senate_net$nodes)
colnames(net)[c(1,2,4,5)] <- c("source","id","source_name","source_group")
net <- left_join(net,senate_net$nodes)

# Reshaping the data
library(tidyr)
net$cross_ref <- with(net, as.numeric(source_group!=group))
net$dem <- as.numeric(net$source_group == "D")
net$rep <- as.numeric(net$source_group == "R")
net$ind <- as.numeric(net$source_group == "I")
summary(glm(cross_ref ~0+dem+rep+ind, data=net,family=binomial(link="probit")))
summary(lm(cross_ref ~0+dem+rep+ind, data=net))



################################################################################
# Probability of mentioning an individual from a different party
rm(list=ls())

load("data/tweets_house.rdata")
load("data/representatives_info.rdata")

groups <- data.frame(group=representatives$Party, name=representatives_profile$tw_screen_name,
                     stringsAsFactors = TRUE)

tweets_house<-bind_rows(tweets_house[-467])

# Filtering
house_elect_2014 <- filter(
  tweets_house, created_at >= ran[1] & created_at <= ran[2])

elements <- tw_extract(tweets_house$text, "mention")
house_net <- tw_network(tweets_house$screen_name, elements$mention, 
                         group = groups, only.from = TRUE)
net <- house_net$links
colnames(net)[1] <- "id"
net <- left_join(net,house_net$nodes)
colnames(net)[c(1,2,4,5)] <- c("source","id","source_name","source_group")
net <- left_join(net,house_net$nodes)

net$cross_ref <- with(net, as.numeric(source_group!=group))
net$dem <- as.numeric(net$source_group == "D")
net$rep <- as.numeric(net$source_group == "R")
net$ind <- as.numeric(net$source_group == "I")
summary(glm(cross_ref ~0+dem+rep+ind, data=net,family=binomial(link="probit")))
summary(lm(cross_ref ~0+dem+rep+ind, data=net))
