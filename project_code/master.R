# Set Working directory
setwd("/home/alex/git/domestic_finance_2018")

# Run Python script
system("python3 project_code/levels.py")

# Run R scripts
source("/home/alex/git/domestic_finance_2018/project_code/imf_deflator.R");rm(list=ls());
source("/home/alex/git/domestic_finance_2018/project_code/calculate_conversion_factor.R");rm(list=ls());
source("/home/alex/git/domestic_finance_2018/project_code/levels.R");rm(list=ls());
source("/home/alex/git/domestic_finance_2018/project_code/govrev.R");rm(list=ls());
source("/home/alex/git/domestic_finance_2018/project_code/grants-pct.R");rm(list=ls());
source("/home/alex/git/domestic_finance_2018/project_code/non-grant.R");rm(list=ls());
source("/home/alex/git/domestic_finance_2018/project_code/total-expend.R");rm(list=ls())