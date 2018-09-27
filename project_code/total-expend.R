#### Startup ####

list.of.packages <- c("data.table","reshape2","varhandle")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)

# Change WD to git repo if needed
wd <- "~/git/domestic_finance_2018"
setwd(wd)

df <- read.csv("output/domestic.csv",colClasses=c("character","numeric","character","character","character","character","character","character","character","numeric","numeric","numeric"), header = TRUE,sep=",",na.strings="",stringsAsFactors=FALSE)

exp_names = c("total-expenditure","expenditure")
totalExp <- subset(df,l1 %in% exp_names & is.na(l2))
keep <- c("di_id","year","value.ppp","budget.type")
totalExp  <- totalExp[,keep]

# Load data, removing na strings
data_url = "project_data/WEOApr2018all.xls"
weo = read.csv(data_url,sep="\t",na.strings=c("","n/a","--"))

#### Advanced econ expenditure ####

# Set our desired indicators with nice names
weo$indicator = NA
weo$indicator[which(weo$Subject.Descriptor== "General government total expenditure" & weo$Units == "National currency")] = "total.exp.ncu"

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

keep = c("WEO.Country.Code","ISO","Country","year","total.exp.ncu")
indicators.l = indicators.l[,keep]
names(indicators.l) = c("weo_country_code","iso_alpha_3_code","country_name","year","total.exp.ncu")
indicators.l$weo_country_code = unfactor(indicators.l$weo_country_code)

mult <- read.csv("output/weo_current_ncu_to_constant_2011_ppp_conversion_factor_itep.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
keep = c("weo_country_code","di_id","year","constant.2011.ppp.per.current.ncu")
mult = mult[keep]

adv = merge(indicators.l,mult,by=c("weo_country_code","year"))
adv$total.exp.ncu = adv$total.exp.ncu * 1000000000
adv$value.ppp = adv$total.exp.ncu * adv$constant.2011.ppp.per.current.ncu
keep = c("di_id","year","value.ppp")
adv = adv[keep]
adv$budget.type = "actual"

dat <- rbind(totalExp,adv)

pop <- read.csv("output/weo_population.csv",colClasses=c("character","character","character","character","numeric","character"), header = TRUE,sep=",",na.strings="",stringsAsFactors=FALSE)
pop$year = as.numeric(pop$year)
keep = c("di_id","year","population")
pop = pop[keep]
names(pop)[3] <- "pop"
dat <- merge(
  dat,
  pop,
  by=c("di_id","year"),
  all.x=TRUE
)

dat <- transform(dat,value.ppp.pc=value.ppp/pop)

dat <- dat[c("di_id","year","value.ppp.pc","budget.type")]
names(dat) <- c("di_id","year","value","budget-type")

write.csv(dat,"output/total-exp-ppp-per-capita.csv",row.names=FALSE,na="")
