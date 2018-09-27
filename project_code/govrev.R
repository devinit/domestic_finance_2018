#### Startup ####

list.of.packages <- c("data.table","reshape2","varhandle")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)

# Change WD to git repo if needed
wd <- "~/git/domestic_finance_2018"
setwd(wd)

df <- read.csv("output/domestic.csv",colClasses=c("character","numeric","character","character","character","character","character","character","character","numeric","numeric","numeric"), header = TRUE,sep=",",na.strings="",stringsAsFactors=FALSE)

rev_names = c("total-revenue-and-grants","revenues")
totalRevGrants <- subset(df,(l1 %in% rev_names) & is.na(l2))
revPhrases <- c("revenue","oil","nonoil")
totalGrants <- subset(df,(l1 %in% rev_names) & (l2 %in% grantPhrases) & is.na(l3))
# setdiff(unique(totalRevGrants$di_id),unique(totalGrants$di_id))
keep <- c("di_id","year","value.ncu","budget.type")
totalRevGrants <- totalRevGrants[keep]
totalGrants <- totalGrants[keep]

dat <- merge(
  totalRevGrants
  ,totalGrants
  ,by=c("di_id","year","budget.type")
  ,suffix=c(".total",".grant"))
dat <- transform(dat,value=(value.ncu.grant/value.ncu.total)*100)

write.csv(newdf,"./gov-revenue-pc-gdp.csv",row.names=FALSE,na="")

write.csv(newdf,"./total-revenue-percent-gdp.csv",row.names=FALSE,na="")
