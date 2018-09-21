wd <- "~/git/domestic_finance_2018"
setwd(wd)
source("project_code/connect.R")
old.levels = ddw("reference.di_domestic_budget_level")
old.levels$row_id = NULL
dbDisconnect(con)

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
  "Cameroon",
  "Central African Republic",
  "Chad",
  "Comoros",
  "Congo Rep.",
  "Cote D'Ivoire",
  "Djibouti",
  "Democratic Republic of Congo",
  "Egypt",
  "El Salvador",
  "Ethiopia",
  "Gambia",
  "Georgia",
  "Ghana",
  "Guinea",
  "Guinea-Bissau",
  "Haiti",
  "Honduras",
  "India",
  "Indonesia",
  "Kenya",
  "Kiribati",
  "Kosovo",
  "Kyrgyz",
  "Laos",
  "Lesotho",
  "Liberia",
  "Madagascar",
  "Malawi",
  "Mali",
  "Mauritania",
  "Micronesia",
  "Moldova",
  "Mongolia",
  "Morocco",
  "Mozambique",
  "Myanmar",
  "Nepal",
  "Nicaragua",
  "Niger",
  "Nigeria",
  "Pakistan",
  "Papua New Guinea",
  "Philippines",
  "Rwanda",
  "Sao Tome and Principe",
  "Senegal",
  "Sierra Leone",
  "Solomon Islands",
  "Somalia",
  "South Sudan",
  "Sri Lanka",
  "Sudan",
  "Swaziland",
  "Tajikistan",
  "Tanzania",
  "Timor-Leste",
  "Togo",
  "Tunisia",
  "Uganda",
  "Ukraine",
  "Uzbekistan",
  "Vanuatu",
  "Vietnam",
  "Zambia",
  "Albania",
  "Algeria",
  "Armenia",
  "Azerbaijan",
  "Belarus",
  "Botswana",
  "Brazil",
  "Colombia",
  "Costa Rica",
  "Ecuador",
  "Equatorial Guinea",
  "Fiji",
  "Gabon",
  "Guatemala",
  "Guyana",
  "Iran",
  "Jamaica",
  "Jordan",
  "Lebanon",
  "Malaysia",
  "Maldives",
  "Mauritius",
  "Turkmenistan",
  "Tuvalu",
  "Venezuela"
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
names(df)[names(df) == "iso"] <- "di_id"
setdiff(completed_countries,unique(df$country))

mult <- read.csv("weo_current_ncu_to_constant_2016_usd_conversion_factor.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
keep = c("di_id","year","constant.2016.usd.per.current.ncu")
mult = mult[keep]
mult2 <- read.csv("weo_current_ncu_to_constant_2011_ppp_conversion_factor_itep.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
keep = c("di_id","year","constant.2011.ppp.per.current.ncu")
mult2 = mult2[keep]
mult = merge(mult,mult2)
# Not sure if this is still required
mult$constant.2016.usd.per.current.ncu[which(mult$di_id=="SY")] <- 1
mult$constant.2011.ppp.per.current.ncu[which(mult$di_id=="SY")] <- 1

if("value-ncu" %in% colnames(df)){
  names(df)[names(df)=="value-ncu"] <- "value.ncu"
  names(df)[names(df)=="value-ppp"] <- "value.ppp"
  df$value <- df$value.ncu
}else{
  df$value.ncu <- df$value
}
df <- merge(
  df
  ,mult
  ,by=c("di_id","year")
  ,all.x=TRUE
)
df <- transform(df,value=constant.2016.usd.per.current.ncu*value.ncu)
df <- transform(df,value.ppp=constant.2011.ppp.per.current.ncu*value.ncu)
df <- transform(df,l1=gsub(" ","-",tolower(gsub("[^[:alnum:] ]", "", l1))))
df <- transform(df,l2=gsub(" ","-",tolower(gsub("[^[:alnum:] ]", "", l2))))
df <- transform(df,l3=gsub(" ","-",tolower(gsub("[^[:alnum:] ]", "", l3))))
df <- transform(df,l4=gsub(" ","-",tolower(gsub("[^[:alnum:] ]", "", l4))))
df <- transform(df,l5=gsub(" ","-",tolower(gsub("[^[:alnum:] ]", "", l5))))
df <- transform(df,l6=gsub(" ","-",tolower(gsub("[^[:alnum:] ]", "", l6))))
keep <- c(1,2,5,6,7,8,9,10,11,12,13,16)
df <- df[,keep]
names(df)[names(df) == "value.ncu"] <- "value-ncu"
names(df)[names(df) == "value.ppp"] <- "value-ppp"
names(df)[names(df) == "type"] <- "budget-type"
write.csv(df,"domestic.csv",row.names=FALSE,na="")
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
write.csv(new.levels,"domestic-budget-level.csv",row.names=FALSE,na="")
