list.of.packages <- c("data.table","ggplot2","Hmisc")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)

# Change WD to git repo if needed
wd = "~/git/domestic_finance_2018"
setwd(wd)

gov_rev = read.csv("output/gov-revenue-percent-gdp.csv", na.strings = "")
gov_rev_large = subset(gov_rev, value > 1.1)
total_rev = read.csv("output/total-revenue-percent-gdp.csv", na.strings = "")
total_rev_large = subset(total_rev, value > 1.1)
grants_pct = read.csv("output/grants-percent-total-revenue.csv", na.strings = "")
grants_pct_large = subset(grants_pct, value > 110)

write.csv(gov_rev_large,"data_checks/gov_rev_large.csv")
write.csv(total_rev_large,"data_checks/total_rev_large.csv")
