wd <- "~/git/domestic_finance_2018/output"
setwd(wd)
completed_countries = c(
  "Afghanistan",
  "Angola",
  "Bangladesh",
  "Benin",
  "Bhutan",
  "Bolivia",
  "Burkina Faso",
  "Burundi",
  "Cape Verde",
  "Cambodia",
  "Central African Republic",
  "Chad",
  "Congo Rep.",
  "Democratic Republic of Congo",
  "Eritrea",
  "Ethiopia",
  "Gambia",
  "Ghana",
  "Guinea",
  "Guinea-Bissau",
  "Haiti",
  "Kenya",
  "Lesotho",
  "Liberia",
  "Madagascar",
  "Malawi",
  "Mali",
  "Micronesia",
  "Mozambique",
  "Nepal",
  "Niger",
  "Nigeria",
  "Pakistan",
  "Papua New Guinea",
  "Rwanda",
  "Senegal",
  "Somalia",
  "South Sudan",
  "Sudan",
  "Tanzania",
  "Togo",
  "Uganda",
  "Zambia"
)
df <- read.csv("./results.csv"
               , header = TRUE
               ,sep=","
               ,na.strings=c("","-","--")
               ,check.names=FALSE
               ,stringsAsFactors=FALSE
               ,colClasses = c("character","character","numeric",
                               "character","character","character",
                               "character","character","character",
                               "character","character","numeric")
               )
names(df)[names(df) == "iso"] <- "id"

mult <- read.csv("~/git/digital-platform/reference/imf_weo_ncu_deflator.2015.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
names(mult)[3] <- c("deflator")
mult$deflator[which(mult$id=="SY")] <- 1

#Have a PPP conversion for every year, but equal to 2015 rate for all years for all countries except for Syria
ppp <- read.csv("~/git/digital-platform/reference/current-ncu-to-current-ppp.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
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

usd <- read.csv("~/git/digital-platform/reference/current-ncu-to-current-usd.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
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
if("value-ncu" %in% colnames(df)){
  names(df)[names(df)=="value-ncu"] <- "value.ncu"
  df$value <- df$value.ncu
}else{
  df$value.ncu <- df$value
}
df <- merge(
  df
  ,mult
  ,by=c("id","year")
  ,all.x=TRUE
)
df <- transform(df,value.ppp=mult.ppp*value.ncu)
df <- transform(df,value=mult.usd*value.ncu)
df <- transform(df,l1=gsub(" ","-",tolower(gsub("[^[:alnum:] ]", "", l1))))
df <- transform(df,l2=gsub(" ","-",tolower(gsub("[^[:alnum:] ]", "", l2))))
df <- transform(df,l3=gsub(" ","-",tolower(gsub("[^[:alnum:] ]", "", l3))))
df <- transform(df,l4=gsub(" ","-",tolower(gsub("[^[:alnum:] ]", "", l4))))
df <- transform(df,l5=gsub(" ","-",tolower(gsub("[^[:alnum:] ]", "", l5))))
df <- transform(df,l6=gsub(" ","-",tolower(gsub("[^[:alnum:] ]", "", l6))))
keep <- c(1,2,5,6,7,8,9,10,11,12,13,16)
df <- df[keep]
names(df)[names(df) == "value.ncu"] <- "value-ncu"
names(df)[names(df) == "value.ppp"] <- "value-ppp"
names(df)[names(df) == "type"] <- "budget-type"
write.csv(df,"~/git/digital-platform/country-year/domestic-gha.csv",row.names=FALSE,na="")
names(df)
df <- read.csv("./results.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
levels <- df[c(6:11)]
levels <- reshape(
  levels
  ,varying=1:6
  ,sep=""
  ,direction="long")
levels <- levels[c(1,2)]
names(levels) <- c("level","name")
levels <- unique(levels)[complete.cases(levels),]
levels <- transform(levels,id=gsub(" ","-",tolower(gsub("[^[:alnum:] ]", "", name))))
levels$sectoral <- "FALSE"
levels <- levels[c(3,4,1,2)]
levels <- df[c(6:11)]
levels <- reshape(
  levels
  ,varying=1:6
  ,sep=""
  ,direction="long")
levels <- levels[c(1,2)]
names(levels) <- c("level","name")
levels <- unique(levels)[complete.cases(unique(levels)),]
levels <- transform(levels,id=gsub(" ","-",tolower(gsub("[^[:alnum:] ]", "", name))))
levels$sectoral <- "FALSE"
levels <- levels[c(3,4,1,2)]
old.levels <- read.csv("~/git/digital-platform/reference/domestic-budget-level.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
sectoral <- subset(old.levels,sectoral==TRUE)
old.levels <- old.levels[c(1,2,3,5)]
levels <- merge(
  levels
  ,old.levels
  ,by=intersect(names(levels),names(old.levels))
  ,all.x=TRUE
)
levels <- levels[order(levels$id)[!duplicated(sort(levels$id))],]
new.levels <- rbind(levels,sectoral)
new.levels <- unique(new.levels)
write.csv(new.levels,"~/git/digital-platform/reference/domestic-budget-level-gha.csv",row.names=FALSE,na="")
