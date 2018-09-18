list.of.packages <- c("data.table")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)

wd <- "~/git/domestic_finance_2018/output"
setwd(wd)

domestic = read.csv("domestic.csv",na.strings="")
domestic$value = domestic$value.ncu
domestic$value.ncu = NULL
domestic$value.ppp = NULL
domestic = data.table(domestic)

domestic = domestic[order(domestic$di_id,domestic$year,domestic$budget.type,domestic$l1,domestic$l2,domestic$l3,domestic$l4,domestic$l5,domestic$l6),]


inequal.list = list()

#L5 check
parents = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & !is.na(l4) & !is.na(l5) & is.na(l6))
parents = subset(parents,!is.na(value))
children = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & !is.na(l4) & !is.na(l5) & !is.na(l6))

children_agg = children[,.(value=sum(value,na.rm=T)),by=.(di_id,year,budget.type,l1,l2,l3,l4,l5)]
setnames(children_agg,"value","child.value.sum")

parents = merge(parents,children_agg)
inequalities = subset(parents,round(value)!=round(child.value.sum))
inequal.list[["L5"]] = inequalities
message("L5 inequalities: ",nrow(inequalities))

#L4 check
parents = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & !is.na(l4) & is.na(l5) & is.na(l6))
parents = subset(parents,!is.na(value))
children = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & !is.na(l4) & !is.na(l5) & is.na(l6))

children_agg = children[,.(value=sum(value,na.rm=T)),by=.(di_id,year,budget.type,l1,l2,l3,l4)]
setnames(children_agg,"value","child.value.sum")

parents = merge(parents,children_agg)
inequalities = subset(parents,round(value)!=round(child.value.sum))
inequal.list[["L4"]] = inequalities
message("L4 inequalities: ",nrow(inequalities))

#L3 check
parents = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & is.na(l4) & is.na(l5) & is.na(l6))
parents = subset(parents,!is.na(value))
children = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & !is.na(l4) & is.na(l5) & is.na(l6))

children_agg = children[,.(value=sum(value,na.rm=T)),by=.(di_id,year,budget.type,l1,l2,l3)]
setnames(children_agg,"value","child.value.sum")

parents = merge(parents,children_agg)
inequalities = subset(parents,round(value)!=round(child.value.sum))
inequal.list[["L3"]] = inequalities
message("L3 inequalities: ",nrow(inequalities))

#L2 check
parents = subset(domestic,!is.na(l1) & !is.na(l2) & is.na(l3) & is.na(l4) & is.na(l5) & is.na(l6))
parents = subset(parents,!is.na(value))
children = subset(domestic,!is.na(l1) & !is.na(l2) & !is.na(l3) & is.na(l4) & is.na(l5) & is.na(l6))

children_agg = children[,.(value=sum(value,na.rm=T)),by=.(di_id,year,budget.type,l1,l2)]
setnames(children_agg,"value","child.value.sum")

parents = merge(parents,children_agg)
inequalities = subset(parents,round(value)!=round(child.value.sum))
inequal.list[["L2"]] = inequalities
message("L2 inequalities: ",nrow(inequalities))

#L1 check
parents = subset(domestic,!is.na(l1) & is.na(l2) & is.na(l3) & is.na(l4) & is.na(l5) & is.na(l6))
parents = subset(parents,!is.na(value))
children = subset(domestic,!is.na(l1) & !is.na(l2) & is.na(l3) & is.na(l4) & is.na(l5) & is.na(l6))

children_agg = children[,.(value=sum(value,na.rm=T)),by=.(di_id,year,budget.type,l1)]
setnames(children_agg,"value","child.value.sum")

parents = merge(parents,children_agg)
inequalities = subset(parents,round(value)!=round(child.value.sum))
inequal.list[["L1"]] = inequalities
message("L1 inequalities: ",nrow(inequalities))

all.inequalities = rbindlist(inequal.list)
all.inequalities = subset(all.inequalities,child.value.sum>0)
write.csv(all.inequalities,"inequalities.csv",na="",row.names=F)
