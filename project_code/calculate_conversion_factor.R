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
setnames(id.map,"imf_weo_country_code","weo_country_code")
dbDisconnect(con)

deflator = read.csv("output/usd_deflator_2014_2016_apr.csv",na="")

# Load data, removing na strings
data_url = "project_data/WEOApr2018all.xls"
weo = read.csv(data_url,sep="\t",na.strings=c("","n/a","--"))

#### constant.2016.usd.per.current.ncu ####

# Set our desired indicators with nice names
weo$indicator = NA
weo$indicator[which(weo$Subject.Descriptor== "Gross domestic product, current prices" & weo$Units == "U.S. dollars")] = "current_usd_gdp"
weo$indicator[which(weo$Subject.Descriptor== "Gross domestic product, current prices" & weo$Units == "National currency")] = "current_ncu_gdp"

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

# Currency devaluation adjustment
indicators.l$current_ncu_gdp[which(indicators.l$ISO=="BLR" & indicators.l$year>=2008 & indicators.l$year<=2013)] = indicators.l$current_ncu_gdp[which(indicators.l$ISO=="BLR" & indicators.l$year>=2008 & indicators.l$year<=2013)] * 10000
# Now that we're reordered, calculate exchange rate
indicators.l$usd.per.ncu = indicators.l$current_usd_gdp/indicators.l$current_ncu_gdp

# Drop unnecessary columns, rename, and write csv
keep = c("WEO.Country.Code","ISO","Country","year","usd.per.ncu")
indicators.l = indicators.l[,keep]
names(indicators.l) = c("weo_country_code","iso_alpha_3_code","country_name","year","usd.per.ncu")
indicators.l$weo_country_code = unfactor(indicators.l$weo_country_code)
deflator$iso_alpha_3_code=NULL
deflator$country_name=NULL
cf = merge(indicators.l,deflator,by=c("weo_country_code","year"))
cf$constant.2016.usd.per.current.ncu = cf$usd.per.ncu / (cf$deflator/100)

cf$deflator = NULL
cf$usd.per.ncu = NULL
# Somalia gets dropped
cf = merge(cf,id.map,by="weo_country_code")
write.csv(cf,"output/weo_current_ncu_to_constant_2016_usd_conversion_factor.csv",na="",row.names=F)

#### Population ####
pop = subset(weo, Subject.Descriptor == "Population")
keep = c("WEO.Country.Code","ISO","Country",paste0("X",c(1981:2023)))
pop = pop[,keep]

# Dataset has commas in numbers, which need to be removed and parsed as numbers
pop[,paste0("X",c(1981:2023))] = as.numeric(sapply(pop[,paste0("X",c(1981:2023))],gsub,pattern=",",replacement=""))

# From reshape2 package, melt turns dataset as long as it can go
pop.m = melt(pop,id.vars=c("WEO.Country.Code","ISO","Country"))
pop.m$year = substr(pop.m$variable,2,5)
pop.m$variable = NULL
pop.m$value = pop.m$value * 1000000

# Drop unnecessary columns, rename, and write csv
keep = c("WEO.Country.Code","ISO","Country","year","value")
pop.m = pop.m[,keep]
names(pop.m) = c("weo_country_code","iso_alpha_3_code","country_name","year","population")
pf = merge(pop.m,id.map,by="weo_country_code")
write.csv(pf,"output/weo_population.csv",na="",row.names=F)

#### constant.2011.ppp.per.current.ncu ITEP METHOD ####

# Set our desired indicators with nice names
weo$indicator = NA
weo$indicator[which(weo$Subject.Descriptor== "Gross domestic product, deflator" & weo$Units == "Index")] = "gdp.deflator"
weo$indicator[which(weo$Subject.Descriptor== "Implied PPP conversion rate" & weo$Units == "National currency per current international dollar")] = "ncu.per.ppp"

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

# Currency devaluation adjustment
indicators.l$ncu.per.ppp[which(indicators.l$ISO=="BLR" & indicators.l$year>=2008 & indicators.l$year<=2013)] = indicators.l$ncu.per.ppp[which(indicators.l$ISO=="BLR" & indicators.l$year>=2008 & indicators.l$year<=2013)] * 10000
# Reorder by country and year
indicators.l = indicators.l[order(indicators.l$WEO.Country.Code,indicators.l$year),]
# Now that we're reordered, calculate exchange rate
indicators.l.2011 = subset(indicators.l,year==2011)
indicators.l.2011$year = NULL
setnames(indicators.l.2011,"gdp.deflator","gdp.deflator.2011")
setnames(indicators.l.2011,"ncu.per.ppp","ncu.per.ppp.2011")
indicators.l = merge(indicators.l,indicators.l.2011)
indicators.l$gdp.deflator.base.2011 = indicators.l$gdp.deflator.2011/indicators.l$gdp.deflator
indicators.l$constant.2011.ppp.per.current.ncu = indicators.l$gdp.deflator.base.2011/indicators.l$ncu.per.ppp.2011

# Drop unnecessary columns, rename, and write csv
keep = c("WEO.Country.Code","ISO","Country","year","constant.2011.ppp.per.current.ncu")
indicators.l = indicators.l[,keep]
names(indicators.l) = c("weo_country_code","iso_alpha_3_code","country_name","year","constant.2011.ppp.per.current.ncu")
indicators.l$weo_country_code = unfactor(indicators.l$weo_country_code)

# Somalia gets dropped
pppf_itep = merge(indicators.l,id.map,by="weo_country_code")
write.csv(pppf_itep,"output/weo_current_ncu_to_constant_2011_ppp_conversion_factor_itep.csv",na="",row.names=F)