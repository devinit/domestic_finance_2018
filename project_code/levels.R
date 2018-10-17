list.of.packages <- c("data.table","varhandle")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)

wd <- "~/git/domestic_finance_2018"
setwd(wd)
source("project_code/connect.R")
old.levels = read.csv("https://raw.githubusercontent.com/devinit/datahub-cms/master/country-profile/domestic-budget-level.csv",na.strings="")
dbDisconnect(con)

wd <- "~/git/domestic_finance_2018/output"
setwd(wd)
fix_inequalities = T

domestic <- read.csv("./results.csv"
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
names(domestic)[names(domestic) == "iso"] <- "di_id"
domestic$di_id = toupper(domestic$di_id)

# Remove SS for 2017, 2018
domestic = subset(domestic,!(di_id=="SS" & year %in% c(2017,2018)))

# Fix small inequalities
domestic = data.table(domestic)
if(fix_inequalities){
  message("Fixing inequalities...")
  #L6
  l6 = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & !is.na(l4) & !is.na(l5) & !is.na(l6))
  l6$dup = duplicated(l6[,c("di_id","year","type","l1","l6"),with=F])
  message("L6 duplicates: ",sum(l6$dup))
  l6$dup = NULL
  #L5
  l5_parents = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & !is.na(l4) & !is.na(l5) & is.na(l6))
  l5_parents$dup = duplicated(l5_parents[,c("di_id","year","type","l1","l5"),with=F])
  message("L5 duplicates: ",sum(l5_parents$dup))
  l5_dups = subset(l5_parents,dup)
  l5_dups$dup = NULL
  l5_non_dups = subset(l5_parents,!dup)
  l5_non_dups$dup = NULL
  l5_dups$new_l5 = paste0(l5_dups$l4," - ",l5_dups$l5)
  l5_dups_for_merge = l5_dups[,c("di_id","year","l1","l2","l3","l4","l5","new_l5"),with=F]
  l5_children = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & !is.na(l4) & !is.na(l5) & !is.na(l6))
  l5_children = merge(l5_children,l5_dups_for_merge,all.x=T)
  if(typeof(l5_children$new_l5)=="NULL"){l5_children$new_l5=NA}
  l5_children$l5[which(!is.na(l5_children$new_l5))] = l5_children$new_l5[which(!is.na(l5_children$new_l5))]
  l5_dups$l5 = l5_dups$new_l5
  l5_dups$new_l5 = NULL
  l5_parents = rbind(l5_non_dups,l5_dups)
  miss_l5_parents = subset(l5_parents,is.na(value))
  non_miss_l5_parents = subset(l5_parents,!is.na(value))
  
  l5_children_agg = l5_children[,.(value=sum(value,na.rm=T)),by=.(di_id,year,type,l1,l2,l3,l4,l5)]
  setnames(l5_children_agg,"value","child.value.sum")
  l5_children_agg = subset(l5_children_agg,child.value.sum>0)
  
  non_miss_l5_parents = merge(non_miss_l5_parents,l5_children_agg,all.x=T)
  non_miss_l5_parents$value[which(!is.na(non_miss_l5_parents$child.value.sum))] = non_miss_l5_parents$child.value.sum[which(!is.na(non_miss_l5_parents$child.value.sum))]
  non_miss_l5_parents$child.value.sum = NULL
  
  l5 = rbind(miss_l5_parents,non_miss_l5_parents)
  #L4
  l4_parents = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & !is.na(l4) & is.na(l5) & is.na(l6))
  l4_parents$dup = duplicated(l4_parents[,c("di_id","year","type","l1","l4"),with=F])
  message("l4 duplicates: ",sum(l4_parents$dup))
  l4_dups = subset(l4_parents,dup)
  l4_dups$dup = NULL
  l4_non_dups = subset(l4_parents,!dup)
  l4_non_dups$dup = NULL
  l4_dups$new_l4 = paste0(l4_dups$l3," - ",l4_dups$l4)
  l4_dups$dup = duplicated(l4_dups[,c("di_id","year","type","l1","new_l4"),with=F])
  l4_dups_for_merge = l4_dups[,c("di_id","year","l1","l2","l3","l4","new_l4"),with=F]
  l4_dups$new_l4[which(l4_dups$dup)] = paste0(l4_dups$l2[which(l4_dups$dup)]," - ",l4_dups$l3[which(l4_dups$dup)]," - ",l4_dups$l4[which(l4_dups$dup)])
  l4_dups$dup = NULL
  l4_children = l5
  l4_children = merge(l4_children,l4_dups_for_merge,all.x=T)
  if(typeof(l4_children$new_l4)=="NULL"){l4_children$new_l4=NA}
  l4_children$l4[which(!is.na(l4_children$new_l4))] = l4_children$new_l4[which(!is.na(l4_children$new_l4))]
  l4_dups$l4 = l4_dups$new_l4
  l4_dups$new_l4 = NULL
  l4_parents = rbind(l4_non_dups,l4_dups)
  miss_l4_parents = subset(l4_parents,is.na(value))
  non_miss_l4_parents = subset(l4_parents,!is.na(value))
  
  l4_children_agg = l4_children[,.(value=sum(value,na.rm=T)),by=.(di_id,year,type,l1,l2,l3,l4)]
  setnames(l4_children_agg,"value","child.value.sum")
  l4_children_agg = subset(l4_children_agg,child.value.sum>0)
  
  non_miss_l4_parents = merge(non_miss_l4_parents,l4_children_agg,all.x=T)
  non_miss_l4_parents$value[which(!is.na(non_miss_l4_parents$child.value.sum))] = non_miss_l4_parents$child.value.sum[which(!is.na(non_miss_l4_parents$child.value.sum))]
  non_miss_l4_parents$child.value.sum = NULL
  
  l4 = rbind(miss_l4_parents,non_miss_l4_parents)
  #L3
  l3_parents = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & is.na(l4) & is.na(l5) & is.na(l6))
  l3_parents$dup = duplicated(l3_parents[,c("di_id","year","type","l1","l3"),with=F])
  message("l3 duplicates: ",sum(l3_parents$dup))
  l3_dups = subset(l3_parents,dup)
  l3_dups$dup = NULL
  l3_non_dups = subset(l3_parents,!dup)
  l3_non_dups$dup = NULL
  l3_dups$new_l3 = paste0(l3_dups$l2," - ",l3_dups$l3)
  l3_dups_for_merge = l3_dups[,c("di_id","year","l1","l2","l3","new_l3"),with=F]
  l3_children = l4
  l3_children = merge(l3_children,l3_dups_for_merge,all.x=T)
  if(typeof(l3_children$new_l3)=="NULL"){l3_children$new_l3=NA}
  l3_children$l3[which(!is.na(l3_children$new_l3))] = l3_children$new_l3[which(!is.na(l3_children$new_l3))]
  l3_dups$l3 = l3_dups$new_l3
  l3_dups$new_l3 = NULL
  l3_parents = rbind(l3_non_dups,l3_dups)
  miss_l3_parents = subset(l3_parents,is.na(value))
  non_miss_l3_parents = subset(l3_parents,!is.na(value))
  
  l3_children_agg = l3_children[,.(value=sum(value,na.rm=T)),by=.(di_id,year,type,l1,l2,l3)]
  setnames(l3_children_agg,"value","child.value.sum")
  l3_children_agg = subset(l3_children_agg,child.value.sum>0)
  
  non_miss_l3_parents = merge(non_miss_l3_parents,l3_children_agg,all.x=T)
  non_miss_l3_parents$value[which(!is.na(non_miss_l3_parents$child.value.sum))] = non_miss_l3_parents$child.value.sum[which(!is.na(non_miss_l3_parents$child.value.sum))]
  non_miss_l3_parents$child.value.sum = NULL
  
  l3 = rbind(miss_l3_parents,non_miss_l3_parents)
  #L2
  l2_parents = subset(domestic,!is.na(l1) & !is.na(l2) & is.na(l3) & is.na(l4) & is.na(l5) & is.na(l6))
  l2_parents$dup = duplicated(l2_parents[,c("di_id","year","type","l1","l2"),with=F])
  message("l2 duplicates: ",sum(l2_parents$dup))
  l2_dups = subset(l2_parents,dup)
  l2_dups$dup = NULL
  l2_non_dups = subset(l2_parents,!dup)
  l2_non_dups$dup = NULL
  l2_dups$new_l2 = paste0(l2_dups$l1," - ",l2_dups$l2)
  l2_dups_for_merge = l2_dups[,c("di_id","year","l1","l2","new_l2"),with=F]
  l2_children = l3
  l2_children = merge(l2_children,l2_dups_for_merge,all.x=T)
  if(typeof(l2_children$new_l2)=="NULL"){l2_children$new_l2=NA}
  l2_children$l2[which(!is.na(l2_children$new_l2))] = l2_children$new_l2[which(!is.na(l2_children$new_l2))]
  l2_dups$l2 = l2_dups$new_l2
  l2_dups$new_l2 = NULL
  l2_parents = rbind(l2_non_dups,l2_dups)
  miss_l2_parents = subset(l2_parents,is.na(value))
  non_miss_l2_parents = subset(l2_parents,!is.na(value))
  
  l2_children_agg = l2_children[,.(value=sum(value,na.rm=T)),by=.(di_id,year,type,l1,l2)]
  setnames(l2_children_agg,"value","child.value.sum")
  l2_children_agg = subset(l2_children_agg,child.value.sum>0)
  
  non_miss_l2_parents = merge(non_miss_l2_parents,l2_children_agg,all.x=T)
  non_miss_l2_parents$value[which(!is.na(non_miss_l2_parents$child.value.sum))] = non_miss_l2_parents$child.value.sum[which(!is.na(non_miss_l2_parents$child.value.sum))]
  non_miss_l2_parents$child.value.sum = NULL
  
  l2 = rbind(miss_l2_parents,non_miss_l2_parents)
  #L1
  l1_parents = subset(domestic,!is.na(l1) & is.na(l2) & is.na(l3) & is.na(l4) & is.na(l5) & is.na(l6))
  miss_l1_parents = subset(l1_parents,is.na(value))
  non_miss_l1_parents = subset(l1_parents,!is.na(value))
  l1_children = l2
  
  l1_children_agg = l1_children[,.(value=sum(value,na.rm=T)),by=.(di_id,year,type,l1)]
  setnames(l1_children_agg,"value","child.value.sum")
  l1_children_agg = subset(l1_children_agg,child.value.sum>0)
  
  non_miss_l1_parents = merge(non_miss_l1_parents,l1_children_agg,all.x=T)
  non_miss_l1_parents$value[which(!is.na(non_miss_l1_parents$child.value.sum))] = non_miss_l1_parents$child.value.sum[which(!is.na(non_miss_l1_parents$child.value.sum))]
  non_miss_l1_parents$child.value.sum = NULL
  
  l1 = rbind(miss_l1_parents,non_miss_l1_parents)
  
  df = data.frame(rbind(l1,l2,l3,l4,l5,l6))
}else{
  df = data.frame(domestic)
}
level_df = df

mult <- read.csv("weo_current_ncu_to_constant_2016_usd_conversion_factor.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
keep = c("di_id","year","constant.2016.usd.per.current.ncu")
mult = mult[keep]
mult2 <- read.csv("weo_current_ncu_to_constant_2011_ppp_conversion_factor_itep.csv", header = TRUE,sep=",",na.strings="",check.names=FALSE,stringsAsFactors=FALSE)
keep = c("di_id","year","constant.2011.ppp.per.current.ncu")
mult2 = mult2[keep]
mult = merge(mult,mult2)
# Not sure if this is still required
# mult$constant.2016.usd.per.current.ncu[which(mult$di_id=="SY")] <- 1
# mult$constant.2011.ppp.per.current.ncu[which(mult$di_id=="SY")] <- 1

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

levels <- level_df[c(6:11)]
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
# Color correction
new.levels$color = unfactor(new.levels$color)
new.levels$color[which(new.levels$id=="capital-expenditure" & new.levels$level==2)] = "orange-darker"
new.levels$color[which(new.levels$id=="capital-expenditure-and-net-lending" & new.levels$level==2)] = "yellow"
new.levels$color[which(new.levels$id=="current-expenditure" & new.levels$level==2)] = "red-light"
new.levels$color[which(new.levels$id=="capital-expenditures" & new.levels$level==2)] = "blue-light"
new.levels$color[which(new.levels$id=="recurrent-expenditures" & new.levels$level==2)] = "blue-darker"
new.levels$color[which(new.levels$id=="investment-expenditure" & new.levels$level==2)] = "green-light"
new.levels$color[which(new.levels$id=="contingency" & new.levels$level==2)] = "green-dark"
new.levels$color[which(new.levels$id=="interest" & new.levels$level==2)] = "grey"
new.levels$color[which(new.levels$id=="road-fund" & new.levels$level==2)] = "purple-dark"

new.levels$color[which(new.levels$id=="reserve-and-contingency-funds" & new.levels$level==2)] = "grey"
new.levels$color[which(new.levels$id=="other" & new.levels$level==2)] = "grey"
new.levels$color[which(new.levels$id=="social-protection-fund" & new.levels$level==2)] = "grey"
new.levels$color[which(new.levels$id=="public-service-restructuring" & new.levels$level==2)] = "grey"
new.levels$color[which(new.levels$id=="unidentified-measures" & new.levels$level==2)] = "grey"

new.levels$color[which(new.levels$id=="returned-letters-of-credit" & new.levels$level==2)] = "grey"
new.levels$color[which(new.levels$id=="investment-expenditures" & new.levels$level==2)] = "red-light"

new.levels$color[which(new.levels$id=="transfer-to-water-authority-of-jordan" & new.levels$level==2)] = "grey"
new.levels$color[which(new.levels$id=="transfer-to-national-electric-power-company" & new.levels$level==2)] = "red-light"

new.levels$color[which(new.levels$id=="donor-project" & new.levels$level==2)] = "grey"
new.levels$color[which(new.levels$id=="contingency-spending" & new.levels$level==2)] = "red-light"

new.levels$color[which(new.levels$id=="state-governments" & new.levels$level==2)] = "grey"
new.levels$color[which(new.levels$id=="municipal-governments" & new.levels$level==2)] = "red-light"
new.levels$color[which(new.levels$id=="federal-government" & new.levels$level==2)] = "green-light"

new.levels$color[which(new.levels$id=="social-security-transfers" & new.levels$level==2)] = "grey"
new.levels$color[which(new.levels$id=="reserves" & new.levels$level==2)] = "red-light"
new.levels$color[which(new.levels$id=="repayment-of-guarantees" & new.levels$level==2)] = "green-light"

new.levels$color[which(new.levels$id=="spending-from-excess-crude-account-sovereign-wealth-fund" & new.levels$level==2)] = "grey"
new.levels$color[which(new.levels$id=="state-and-local-government" & new.levels$level==2)] = "red-light"
new.levels$color[which(new.levels$id=="federal-government-expenditure" & new.levels$level==2)] = "green-light"

new.levels$color[which(new.levels$id=="special-accounts" & new.levels$level==2)] = "grey"
new.levels$color[which(new.levels$id=="road-and-special-funds" & new.levels$level==2)] = "red-light"
new.levels$color[which(new.levels$id=="restructuring-cost-of-public-enterprises" & new.levels$level==2)] = "green-light"
new.levels$color[which(new.levels$id=="petroleum-product-price-subsidies" & new.levels$level==2)] = "blue-light"
new.levels$color[which(new.levels$id=="capital-transfers" & new.levels$level==2)] = "blue-darker"

new.levels$color[which(new.levels$id=="sociocultural-expenditure-including-health-education" & new.levels$level==2)] = "grey"
new.levels$color[which(new.levels$id=="social-safety-net" & new.levels$level==2)] = "red-light"
new.levels$color[which(new.levels$id=="public-investment" & new.levels$level==2)] = "green-light"
new.levels$color[which(new.levels$id=="public-authorities-and-administration" & new.levels$level==2)] = "blue-light"
new.levels$color[which(new.levels$id=="interest-expenditure" & new.levels$level==2)] = "blue-darker"
new.levels$color[which(new.levels$id=="extrabudgetary-expenditure-financed-by-grants" & new.levels$level==2)] = "purple-light"

new.levels$color[which(new.levels$id=="subsidies-expense" & new.levels$level==2)] = "grey"
new.levels$color[which(new.levels$id=="social-benefits-expense" & new.levels$level==2)] = "red-light"
new.levels$color[which(new.levels$id=="other-expense" & new.levels$level==2)] = "green-light"
new.levels$color[which(new.levels$id=="interest-expense" & new.levels$level==2)] = "blue-light"
new.levels$color[which(new.levels$id=="grants-expense" & new.levels$level==2)] = "blue-darker"
new.levels$color[which(new.levels$id=="goods-and-services" & new.levels$level==2)] = "purple-dark"
new.levels$color[which(new.levels$id=="consumption-of-fixed-capital" & new.levels$level==2)] = "orange-darker"

write.csv(new.levels,"domestic-budget-level.csv",row.names=FALSE,na="")
