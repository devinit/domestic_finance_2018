list.of.packages <- c("data.table")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)

wd <- "~/git/domestic_finance_2018"
setwd(wd)
source("project_code/connect.R")
old.levels = ddw("reference.di_domestic_budget_level")
old.levels$row_id = NULL
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

# Fix small inequalities
domestic = data.table(domestic)
if(fix_inequalities){
  message("Fixing inequalities...")
  #L6
  l6 = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & !is.na(l4) & !is.na(l5) & !is.na(l6))
  #L5
  l5_parents = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & !is.na(l4) & !is.na(l5) & is.na(l6))
  miss_l5_parents = subset(l5_parents,is.na(value))
  non_miss_l5_parents = subset(l5_parents,!is.na(value))
  l5_children = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & !is.na(l4) & !is.na(l5) & !is.na(l6))
  
  l5_children_agg = l5_children[,.(value=sum(value,na.rm=T)),by=.(di_id,year,type,l1,l2,l3,l4,l5)]
  setnames(l5_children_agg,"value","child.value.sum")
  l5_children_agg = subset(l5_children_agg,child.value.sum>0)
  
  non_miss_l5_parents = merge(non_miss_l5_parents,l5_children_agg,all.x=T)
  non_miss_l5_parents$value[which(!is.na(non_miss_l5_parents$child.value.sum))] = non_miss_l5_parents$child.value.sum[which(!is.na(non_miss_l5_parents$child.value.sum))]
  non_miss_l5_parents$child.value.sum = NULL
  
  l5 = rbind(miss_l5_parents,non_miss_l5_parents)
  #L4
  l4_parents = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & !is.na(l4) & is.na(l5) & is.na(l6))
  miss_l4_parents = subset(l4_parents,is.na(value))
  non_miss_l4_parents = subset(l4_parents,!is.na(value))
  l4_children = l5
  
  l4_children_agg = l4_children[,.(value=sum(value,na.rm=T)),by=.(di_id,year,type,l1,l2,l3,l4)]
  setnames(l4_children_agg,"value","child.value.sum")
  l4_children_agg = subset(l4_children_agg,child.value.sum>0)
  
  non_miss_l4_parents = merge(non_miss_l4_parents,l4_children_agg,all.x=T)
  non_miss_l4_parents$value[which(!is.na(non_miss_l4_parents$child.value.sum))] = non_miss_l4_parents$child.value.sum[which(!is.na(non_miss_l4_parents$child.value.sum))]
  non_miss_l4_parents$child.value.sum = NULL
  
  l4 = rbind(miss_l4_parents,non_miss_l4_parents)
  #L3
  l3_parents = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & is.na(l4) & is.na(l5) & is.na(l6))
  miss_l3_parents = subset(l3_parents,is.na(value))
  non_miss_l3_parents = subset(l3_parents,!is.na(value))
  l3_children = l4
  
  l3_children_agg = l3_children[,.(value=sum(value,na.rm=T)),by=.(di_id,year,type,l1,l2,l3)]
  setnames(l3_children_agg,"value","child.value.sum")
  l3_children_agg = subset(l3_children_agg,child.value.sum>0)
  
  non_miss_l3_parents = merge(non_miss_l3_parents,l3_children_agg,all.x=T)
  non_miss_l3_parents$value[which(!is.na(non_miss_l3_parents$child.value.sum))] = non_miss_l3_parents$child.value.sum[which(!is.na(non_miss_l3_parents$child.value.sum))]
  non_miss_l3_parents$child.value.sum = NULL
  
  l3 = rbind(miss_l3_parents,non_miss_l3_parents)
  #L2
  l2_parents = subset(domestic,!is.na(l1) & !is.na(l2) & is.na(l3) & is.na(l4) & is.na(l5) & is.na(l6))
  miss_l2_parents = subset(l2_parents,is.na(value))
  non_miss_l2_parents = subset(l2_parents,!is.na(value))
  l2_children = l3
  
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
