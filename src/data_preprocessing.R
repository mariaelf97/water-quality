library(tidyverse)
library(data.table)

# read the dataset
stations <-fread("Downloads/stations.csv")
field_results<-fread("Downloads/field_results.csv")
lab_results<-fread("Downloads/lab_results.csv")
period_data<- fread("Downloads/period_of_record.csv")

# check missing values
colSums(is.na(lab_results))
colSums(is.na(field_results))
colSums(is.na(period_data))
# Merge lab results and field results
lab_field_merged <- lab_results%>%inner_join(field_results, by = "station_name")


