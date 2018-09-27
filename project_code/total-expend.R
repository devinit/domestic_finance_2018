path<- "D:/git/digital-platform/country-year/"
setwd(path)

df <- read.csv("./domestic.csv",colClasses=c("character","numeric","character","character","character","character","character","character","character","numeric","numeric","numeric"), header = TRUE,sep=",",na.strings="",stringsAsFactors=FALSE)

totalExp <- subset(df,l1=="total-expenditure" & is.na(l2))
keep <- c("id","year","value.ppp","budget.type")
totalExp  <- totalExp[keep]

adv <- read.csv("D:/Documents/Gov finance/adv_exp.csv",na.strings="",as.is=TRUE,colClasses=c("character","numeric","numeric","character"))
mult <- read.csv("D:/git/digital-platform/reference/imf_weo_ncu_deflator.2014.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
names(mult)[3] <- c("deflator")
mult$deflator[which(mult$id=="SY")] <- 1

#Have a PPP conversion for every year, but equal to 2015 rate for all years for all countries except for Syria
ppp <- read.csv("D:/git/digital-platform/reference/current-ncu-to-current-ppp.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
names(ppp)[3] <- "ppp"
sy.ppp <- subset(ppp,id=="SY")
ppp <- subset(ppp,year==2014 & id!="SY")
ppp$year <- NULL
somalia.ppp <- data.frame("id"="SO","ppp"=1)
ppp <- rbind(ppp,somalia.ppp)
years <- c(1980:2021)
ppp.frame <- data.frame("id"=sort(rep(ppp$id,length(years))),"year"=years)
ppp <- merge(ppp.frame,ppp,by="id")
ppp <- rbind(ppp,sy.ppp)

usd <- read.csv("D:/git/digital-platform/reference/current-ncu-to-current-usd.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
names(usd)[3] <- "usd"
sy.usd <- subset(usd,id=="SY")
usd <- subset(usd,year==2014 & id!="SY")
usd$year <- NULL
somalia.usd <- data.frame("id"="SO","usd"=1)
usd <- rbind(usd,somalia.usd)
years <- c(1980:2021)
usd.frame <- data.frame("id"=sort(rep(usd$id,length(years))),"year"=years)
usd <- merge(usd.frame,usd,by="id")
usd <- rbind(usd,sy.usd)

mult <- merge(mult,ppp,by=c("id","year"))
mult <- merge(mult,usd,by=c("id","year"))
mult$mult.ppp <- mult$deflator/mult$ppp
mult$mult.usd <- mult$deflator*mult$usd
mult$deflator <- NULL
mult$ppp <- NULL
mult$usd <- NULL

adv <- merge(adv,mult,by=c("id","year"))
adv <- transform(adv,value.ppp=value*mult.ppp)
# adv <- transform(adv,value.constant=value*mult.usd)
# write.csv(adv,"D:/Documents/Data/Ex/deflated_advanced_expenditure.csv",row.names=FALSE,na="")
adv <- adv[c("id","year","value.ppp","budget.type")]

dat <- rbind(totalExp,adv)

pop <- read.csv("./weo-population-total.csv",colClasses=c("character","numeric","numeric"), header = TRUE,sep=",",na.strings="",stringsAsFactors=FALSE)
names(pop)[3] <- "pop"
dat <- merge(
  dat,
  pop,
  by=c("id","year"),
  all.x=TRUE
)

dat <- transform(dat,value.ppp.pc=value.ppp/pop)

dat <- dat[c("id","year","value.ppp.pc","budget.type")]
names(dat) <- c("id","year","value","budget-type")

write.csv(dat,"./total-exp-ppp-per-capita.csv",row.names=FALSE,na="")
