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
totalExp <- subset(df,l1 %in% exp_names & !is.na(l2) & is.na(l3))
l2s = unique(totalExp[c("di_id","l2")])
setnames(l2s,"l2","id")

levels = read.csv("output/domestic-budget-level.csv")
levels = subset(levels,level==2)
levels$color = unfactor(levels$color)
levels$color[which(levels$color=="")] = "BLANK"
levels$sectoral = NULL
levels$level = NULL
levels$name = NULL

l2s = merge(l2s,levels)
l2s.m = melt(l2s,id.vars=c("di_id","id"))
l2s.l = dcast(l2s.m,di_id~id)
blanks <- apply(l2s.l[-1], 1, function(i) any(i[!is.na(i)]=="BLANK"))
blanks_count = apply(l2s.l[-1], 1, function(i) sum(i[!is.na(i)]=="BLANK"))
dups <- apply(l2s.l[-1], 1, function(i) any(duplicated(i[!is.na(i)])))
concat = apply(l2s.l[-1], 1, function(i) paste(i[!is.na(i)],collapse=", "))
totals = apply(l2s.l,2,function(i) length(i[which(!is.na(i) & i=="BLANK")]))
l2s.l$blanks = blanks
l2s.l$blanks_count = blanks_count
l2s.l$dups = dups
l2s.l$concat = concat
l2s.l = rbind(l2s.l,totals)

l2s.l = subset(l2s.l,dups|blanks)
l2s.l = subset(l2s.l,dups>0)
write.csv(l2s.l, "data_checks/expenditure_colors.csv",na="",row.names=F)