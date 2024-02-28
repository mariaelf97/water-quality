library(tidyverse)
library(data.table)

# read the dataset
lab_results<-fread("Downloads/lab_results.csv")
# filtering San Diego and only needed columns
lab_results_summarised<- lab_results%>%filter(county_name == "San Diego")%>%
  filter(parameter%in% c("Conductance","Dissolved Calcium","Dissolved Fluoride",
                         "Dissolved Nitrate", "Dissolved Sodium","Total Alkalinity",
                         "Total Hardness", "Dissolved Silica (SiO2)")) %>%
  select(-c(sample_depth, sample_depth_units,station_name))

# check missing values
colSums(is.na(lab_results_summarised))
# remove missing values
lab_results_clean <- lab_results_summarised[complete.cases(lab_results_summarised),]
colSums(is.na(lab_results_clean))



