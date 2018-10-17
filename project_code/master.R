# Set Working directory
setwd("~/git/domestic_finance_2018")

# Run Python script
system("python3 project_code/levels.py")

# Run R scripts
source("project_code/imf_deflator.R")
source("project_code/calculate_conversion_factor.R")
source("project_code/levels.R")
source("project_code/govrev.R")
source("project_code/grants-pct.R")
source("project_code/non-grant.R")
source("project_code/total-expend.R")