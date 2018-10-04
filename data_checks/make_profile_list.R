list.of.packages <- c("data.table","ggplot2","Hmisc")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)

# Change WD to git repo if needed
wd <- "~/git/domestic_finance_2018"
setwd(wd)
source("project_code/connect.R")

all.entities <- ddw("reference.di_entity")
df <- read.csv("output/domestic.csv",colClasses=c("character","numeric","character","character","character","character","character","character","character","numeric","numeric","numeric"), header = TRUE,sep=",",na.strings="",stringsAsFactors=FALSE)

domestic_countries = unique(df$di_id)

domestic_entities = subset(all.entities, id %in% domestic_countries)
keep = c("id","name","slug")
domestic_entities = domestic_entities[keep]
domestic_entities$staging_url = paste0("http://212.111.41.68:8080/country/", domestic_entities$slug)
write.csv(domestic_entities,"data_checks/domestic_entities.csv")