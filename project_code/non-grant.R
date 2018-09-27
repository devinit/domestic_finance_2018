path<- "D:/git/digital-platform/country-year/"
setwd(path)

df <- read.csv("./domestic.csv",colClasses=c("character","numeric","character","character","character","character","character","character","character","numeric","numeric","numeric"), header = TRUE,sep=",",na.strings="",stringsAsFactors=FALSE)

totalRevGrants <- subset(df,l1=="total-revenue-and-grants" & is.na(l2))
grantPhrases <- c("grants","official-grants","total-grants")
totalGrants <- subset(df,l1=="total-revenue-and-grants" & (l2 %in% grantPhrases) & is.na(l3))
# setdiff(unique(totalRevGrants$id),unique(totalGrants$id))
# jmGrants <- subset(df,id=="JM" & l3=="grants" & is.na(l4))
# totalGrants <- rbind(totalGrants,jmGrants)
keep <- c("id","year","value.ppp","budget.type")
totalRevGrants <- totalRevGrants[keep]
totalGrants <- totalGrants[keep]

adv <- read.csv("D:/Documents/Gov finance/advanced.csv",na.strings="",as.is=TRUE,colClasses=c("character","numeric","numeric","character"))
mult <- read.csv("D:/git/digital-platform/reference/imf_weo_ncu_deflator.2015.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
names(mult)[3] <- c("deflator")
mult$deflator[which(mult$id=="SY")] <- 1

#Have a PPP conversion for every year, but equal to 2015 rate for all years for all countries except for Syria
ppp <- read.csv("D:/git/digital-platform/reference/current-ncu-to-current-ppp.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
names(ppp)[3] <- "ppp"
sy.ppp <- subset(ppp,id=="SY")
ppp <- subset(ppp,year==2015 & id!="SY")
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
usd <- subset(usd,year==2015 & id!="SY")
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
adv <- transform(adv,value.ng=value*mult.ppp,value.total=value*mult.ppp)
adv <- adv[c("id","year","value.ng","value.total","budget.type")]

dat <- merge(
  totalRevGrants
  ,totalGrants
  ,by=c("id","year","budget.type")
  ,suffix=c(".total",".grant")
  ,all.x=TRUE
  )
dat <- transform(dat,value.ng=(value.ppp.total-value.ppp.grant),value.total=value.ppp.total)
dat$value.ng[which(is.na(dat$value.ng) & !is.na(dat$value.ppp.total))] <- dat$value.ppp.total[which(is.na(dat$value.ng) & !is.na(dat$value.ppp.total))]
keep <- c("id","year","value.ng","value.total","budget.type")
dat <- dat[keep]
dat <- rbind(dat,adv)

pop <- read.csv("./weo-population-total.csv",colClasses=c("character","numeric","numeric"), header = TRUE,sep=",",na.strings="",stringsAsFactors=FALSE)
names(pop)[3] <- "pop"
dat <- merge(
  dat,
  pop,
  by=c("id","year"),
  all.x=TRUE
  )

dat <- transform(dat,value.ng.pc=value.ng/pop,value.total.pc=value.total/pop)

dat.ng <- dat[c("id","year","value.ng.pc","budget.type")]
names(dat.ng) <- c("id","year","value","budget-type")
dat.total <- dat[c("id","year","value.total.pc","budget.type")]
names(dat.total) <- c("id","year","value","budget-type")

write.csv(dat.ng,"./non-grant-revenue-ppp-capita.csv",row.names=FALSE,na="")
write.csv(dat.total,"./total-revenue-ppp-capita.csv",row.names=FALSE,na="")

