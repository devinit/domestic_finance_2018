list.of.packages <- c("data.table","ggplot2","Hmisc")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)

# Change WD to git repo if needed
wd = "~/git/domestic_finance_2018"
setwd(wd)

gov_rev = read.csv("data_checks/gov-revenue-percent-gdp_check.csv", na.strings = "")
gov_rev_large = subset(gov_rev, value > 110)
total_rev = read.csv("data_checks/total-revenue-percent-gdp_check.csv", na.strings = "")
total_rev_large = subset(total_rev, value > 110)
grants_pct = read.csv("output/grants-percent-total-revenue.csv", na.strings = "")
grants_pct_large = subset(grants_pct, value > 110)

gov_rev_large = gov_rev_large[order(-gov_rev_large$value),]
total_rev_large = total_rev_large[order(-total_rev_large$value),]
write.csv(gov_rev_large,"data_checks/gov_rev_large.csv")
write.csv(total_rev_large,"data_checks/total_rev_large.csv")

# Has every country got 3 l1s?

df <- read.csv("output/domestic.csv",colClasses=c("character","numeric","character","character","character","character","character","character","character","numeric","numeric","numeric"), header = TRUE,sep=",",na.strings="",stringsAsFactors=FALSE)
l1s = subset(df,!is.na(l1) & is.na(l2))
unique_l1s = unique(l1s[c("di_id","year","budget.type","l1","value.ncu")])

# # Per capita stuff
# 
# govt_spend_pc = read.csv("output/govt_spend_pc.csv", na.strings = "")
# non_grant_pc = read.csv("output/non-grant-revenue-ppp-capita.csv", na.strings="")
# total_rev_pc = read.csv("output/total-revenue-ppp-capita.csv", na.strings="")
