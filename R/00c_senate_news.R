rm(list=ls())

library(rtimes)
library(httr)

source('R/credentials.R')

# He should use the filter for persons
# https://lucene.apache.org/core/2_9_4/queryparsersyntax.html
obama <- as_search('congress',key = nytimes$search, fq='persons.contains:(+"lamar" +"obama")',
                   begin_date = '20120818', end_date = '20150818')
obama

# Search for the contents of combinations 
joint_search <- function(politics, key=nytimes$search, begin='20100818', end='20150818') {
  # Creating a combination between the two
  vecpol <- expand.grid(p1=politics,p2=politics)
  vecpol <- subset(vecpol,p1!=p2)
  
  name   <- with(vecpol,paste0(p1,'-',p2))
  
  vecpol <- with(vecpol,paste0('persons.contains:(+"',p1,'" +"',p2,'")'))
  
  n      <- length(vecpol)
  output <- vector('list',n)
  
  for(i in 1:n) {
    message('Getting data for ',name[i],'...',appendLF = FALSE)
    output[[i]] <- as_search('congress',key = key, fq=vecpol[i],
              begin_date = begin, end_date = end)$data
    message(' done.')
  }
  
  names(output) <- name
  output
}

set.seed(123)
samp <- tolower(gsub('[,].+','',sample(senators$name,size = 10)))
x<-joint_search(samp)
hist(sapply(x,length))
