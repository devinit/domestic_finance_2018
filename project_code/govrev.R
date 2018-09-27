# dat <- read.csv("D:/Documents/weo_gdp_ncu.csv",na.strings='n/a')
# dat <- dat[c(1,6:28)]
# names(dat)[2:24] <- paste("gdp",c(1999:2021),sep=".")
# dat <- reshape(dat,direction="long",idvar="Country",varying=c(2:24),sep=".")
# write.csv(dat,"D:/Documents/weo_gdp_ncu_long.csv",row.names=FALSE,na="")

path<- "D:/git/digital-platform/country-year/"
setwd(path)

# df <- read.csv("C:/git/alexm-util/DevInit/budgetLevels/results_ncu.csv",colClasses=c("character","numeric","character","character","character","character","character","character","character","numeric","numeric","numeric"), header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
df <- read.csv("D:/git/digital-platform/country-year/domestic.csv",colClasses=c("character","numeric","character","character","character","character","character","character","character","numeric","numeric","numeric"), header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
adv <- read.csv("D:/Documents/Gov finance/advanced.csv",na.strings="",as.is=TRUE,colClasses=c("character","numeric","numeric","character"))
gdp <- read.csv("./gdp-current-ncu-fy.csv",colClasses=c("character","numeric","numeric"), header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
adv <- merge(adv,gdp,by=c("id","year"),suffixes=c(".adv",".gdp"))
adv <- transform(adv,value=(value.adv/value.gdp)*100)
adv$value.adv <- NULL
adv$value.gdp <- NULL

id <- c()
year <- c()
value <- c()
budget.type <- c()

for(i in 1:nrow(df)){
  row <- df[i,]
  dfid <- row[1][1,1]
  dfyear <- row[2][1,1]
  budget <- row[3][1,1]
  l1 <- row[4][1,1]
  l2 <- row[5][1,1]
  l3 <- row[6][1,1]
  dfvalue <- row[11][1,1]
  if(!is.na(l1) && !is.na(l2)){
    if(l1=="total-revenue-and-grants" && l2=="revenue" && is.na(l3)){
      id <- c(id,dfid)
      year <- c(year,dfyear)
      budget.type <- c(budget.type,budget)
      thisGDP <- gdp[which(gdp$id==dfid),]
      thisGDP <- thisGDP[which(thisGDP$year==dfyear),]
      if(nrow(thisGDP)>0){
        if(is.na(thisGDP$value[[1]])){
          value <- c(value,NA)
        }else{
          value <- c(value,(dfvalue/thisGDP$value[[1]])*100)
        }
      }else{
        value <- c(value,NA)
        print(paste("No multiplier for:",dfid,dfyear))
      }
    }
  }
}
newdf <- data.frame(id,year,value,budget.type)
newdf <- rbind(newdf,adv)
names(newdf)[4] <- "budget-type"
write.csv(newdf,"./gov-revenue-pc-gdp.csv",row.names=FALSE,na="")

id <- c()
year <- c()
value <- c()
budget.type <- c()

for(i in 1:nrow(df)){
  row <- df[i,]
  dfid <- row[1][1,1]
  dfyear <- row[2][1,1]
  budget <- row[3][1,1]
  l1 <- row[4][1,1]
  l2 <- row[5][1,1]
  l3 <- row[6][1,1]
  dfvalue <- row[11][1,1]
  if(!is.na(l1)){
    if(l1=="total-revenue-and-grants" && is.na(l2)){
      id <- c(id,dfid)
      year <- c(year,dfyear)
      budget.type <- c(budget.type,budget)
      thisGDP <- gdp[which(gdp$id==dfid),]
      thisGDP <- thisGDP[which(thisGDP$year==dfyear),]
      if(nrow(thisGDP)>0){
        if(is.na(thisGDP$value[[1]])){
          value <- c(value,NA)
        }else{
          value <- c(value,(dfvalue/thisGDP$value[[1]])*100)
        }
      }else{
        value <- c(value,NA)
        print(paste("No multiplier for:",dfid,dfyear))
      }
    }
  }
}
newdf <- data.frame(id,year,value,budget.type)
newdf <- rbind(newdf,adv)
names(newdf)[4] <- "budget-type"
write.csv(newdf,"./total-revenue-percent-gdp.csv",row.names=FALSE,na="")
