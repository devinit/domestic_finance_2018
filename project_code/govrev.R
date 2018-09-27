#### Startup ####

list.of.packages <- c("data.table","reshape2","varhandle")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)

# Change WD to git repo if needed
wd <- "~/git/domestic_finance_2018"
setwd(wd)
source("project_code/connect.R")
id.map = ddw("dimension.imf_weo_country_to_di_id_map")
som = data.frame(imf_weo_country_code=726,di_id="SO")
id.map = rbind(id.map,som)
setnames(id.map,"imf_weo_country_code","weo_country_code")
dbDisconnect(con)

df <- read.csv("output/domestic.csv",colClasses=c("character","numeric","character","character","character","character","character","character","character","numeric","numeric","numeric"), header = TRUE,sep=",",na.strings="",stringsAsFactors=FALSE)

total_rev_names = c("total-revenue-and-grants","revenues")
totalRevGrants <- subset(df,(l1 %in% total_rev_names) & is.na(l2))
revPhrases <- c("revenue","oil","nonoil")
totalRevs <- subset(df,(l1 %in% total_rev_names) & (l2 %in% revPhrases) & is.na(l3))
keep <- c("di_id","year","value.ncu","budget.type")
totalRevGrants <- totalRevGrants[keep]
totalRevs <- totalRevs[keep]

dat <- merge(
  totalRevGrants
  ,totalRevs
  ,by=c("di_id","year","budget.type")
  ,suffix=c(".total",".rev"))

# Load data, removing na strings
data_url = "project_data/WEOApr2018all.xls"
weo = read.csv(data_url,sep="\t",na.strings=c("","n/a","--"))

#### Advanced econ revenues ####

# Set our desired indicators with nice names
weo$indicator = NA
weo$indicator[which(weo$Subject.Descriptor== "General government revenue" & weo$Units == "National currency")] = "value.ncu"
weo$indicator[which(weo$Subject.Descriptor== "Gross domestic product, constant prices" & weo$Units == "National currency")] = "gdp.current.ncu"

# Grab just those indicators and relevant columns
indicators = subset(weo,!is.na(indicator))
keep = c("WEO.Country.Code","ISO","Country","indicator",paste0("X",c(1981:2023)))
indicators = indicators[,keep]

# Dataset has commas in numbers, which need to be removed and parsed as numbers
indicators[,paste0("X",c(1981:2023))] = as.numeric(sapply(indicators[,paste0("X",c(1981:2023))],gsub,pattern=",",replacement=""))

# From reshape2 package, melt turns dataset as long as it can go
indicators.m = melt(indicators,id.vars=c("WEO.Country.Code","ISO","Country","indicator"))

# dcast takes a molten dataframe and reshapes it given a formula, here we're recasting long
indicators.l = dcast(indicators.m,WEO.Country.Code+ISO+Country+variable~indicator)

# Remove the leading X now that year is no longer a variable name
indicators.l$year = substr(indicators.l$variable,2,5)
indicators.l$variable = NULL

# Reorder by country and year
indicators.l = indicators.l[order(indicators.l$WEO.Country.Code,indicators.l$year),]

keep = c("WEO.Country.Code","ISO","Country","year","value.ncu","gdp.current.ncu")
indicators.l = indicators.l[,keep]
names(indicators.l) = c("weo_country_code","iso_alpha_3_code","country_name","year","value.ncu","gdp.current.ncu")
indicators.l$weo_country_code = unfactor(indicators.l$weo_country_code)
adv = merge(indicators.l,id.map,by="weo_country_code")
adv$value.ncu = adv$value.ncu * 1000000000
adv$gdp.current.ncu = adv$gdp.current.ncu * 1000000000
gdp = adv[c("di_id","year","gdp.current.ncu")]
adv$budget.type = "actual"
adv.rev = adv[c("di_id","year","value.ncu","budget.type")]
adv.rev = subset(adv.rev, !(di_id %in% unique(totalRevGrants$di_id)))

totalRevGrants <- rbind(totalRevGrants,adv.rev)
totalRevs <- rbind(totalRevs,adv.rev)

totalRevGrants = merge(totalRevGrants,gdp,by=c("di_id","year"))
totalRevs = merge(totalRevs,gdp,by=c("di_id","year"))

totalRevGrants$value = totalRevGrants$value.ncu/totalRevGrants$gdp.current.ncu
totalRevs$value = totalRevs$value.ncu/totalRevs$gdp.current.ncu

keep = c("di_id","year","value","budget.type")
totalRevGrants = totalRevGrants[,keep]
totalRevs = totalRevs[,keep]

write.csv(totalRevGrants,"./total-revenue-percent-gdp.csv",row.names=FALSE,na="")
write.csv(totalRevs,"./gov-revenue-percent-gdp.csv",row.names=FALSE,na="")
