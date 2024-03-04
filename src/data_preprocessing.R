library(tidyverse)
library(data.table)

# read the dataset
lab_results<-fread("Downloads/lab_results.csv",stringsAsFactors = FALSE)
stations <- fread("Downloads/stations.csv")
# filtering San Diego and only needed columns
lab_results_summarised<- lab_results%>%
  filter(parameter%in% c("Conductance","Dissolved Calcium","Dissolved Fluoride",
                         "Dissolved Nitrate", "Dissolved Sodium","Total Alkalinity")) %>%
  select(-c(sample_depth, sample_depth_units,station_name))

# check missing values
colSums(is.na(lab_results_summarised))
lab_results_summarised<-replace(lab_results_summarised,lab_results_summarised=="",NA)
# remove missing values
lab_results_clean <- lab_results_summarised[complete.cases(lab_results_summarised),]
colSums(is.na(lab_results_clean))
lab_results_clean<-replace(lab_results_clean,lab_results_clean=="< R.L.",0)
lab_results_clean<-replace(lab_results_clean,lab_results_clean=="< MDL, MDL = 0.040",0)


lab_results_clean$result <- as.numeric(as.character(lab_results_clean$result))
aggregated_results <- as.data.frame(lab_results_clean%>%
  group_by(station_id,parameter)%>%
  summarise(mean_parameter = mean(result)))

aggregated_results<- aggregated_results%>% mutate(parameter_quality = case_when(
  parameter == "Conductance" & mean_parameter == 50000 | mean_parameter > 50000 ~ "too_high",
  parameter == "Conductance" & mean_parameter < 50000 & mean_parameter >10000 ~ "moderate_high",
  parameter == "Conductance" & mean_parameter == 10000 | mean_parameter < 10000 | mean_parameter >2000 ~ "moderate_low",
  parameter == "Conductance" & mean_parameter == 2000 | mean_parameter < 2000 ~ "low",
  parameter == "Dissolved Calcium" & mean_parameter == 15 | mean_parameter <15 ~ "low",
  parameter == "Dissolved Calcium" & mean_parameter > 15 & mean_parameter <100 ~ "moderate",
  parameter == "Dissolved Calcium" & mean_parameter == 100 | mean_parameter >100 ~ "high",
  parameter == "Dissolved Fluoride" & mean_parameter == 10 | mean_parameter > 10 ~ "high",
  parameter == "Dissolved Fluoride" & mean_parameter < 10 & mean_parameter >1.2 ~ "moderate",
  parameter == "Dissolved Fluoride" & mean_parameter == 1.2 | mean_parameter < 1.2 ~ "low",
  parameter == "Dissolved Sodium" & mean_parameter == 30000 | mean_parameter > 30000 ~ "high",
  parameter == "Dissolved Sodium" & mean_parameter < 30000 & mean_parameter > 15000 ~ "moderate_high",
  parameter == "Dissolved Sodium" & mean_parameter == 15000 | mean_parameter > 15000 & mean_parameter > 9 ~ "moderate_low",
  parameter == "Dissolved Sodium" & mean_parameter == 9 | mean_parameter < 9 ~ "low",
  parameter == "Total Alkalinity" & mean_parameter == 400 | mean_parameter > 400 ~ "high",
  parameter == "Total Alkalinity" & mean_parameter < 400 & mean_parameter > 100 ~ "moderate",
  parameter == "Total Alkalinity" & mean_parameter == 100 | mean_parameter < 100 ~ "low",
  parameter == "Dissolved Nitrate" & mean_parameter == 5 | mean_parameter > 5 ~  "high",
  parameter == "Dissolved Nitrate" & mean_parameter < 5 & mean_parameter > 3.1 ~ "moderate",
  parameter == "Dissolved Nitrate" & mean_parameter == 3.1 | mean_parameter < 3.1 ~ "low",
))
aggregated_geo_location<-stations%>%select(station_id,longitude,latitude,county_name)%>%
  inner_join(aggregated_results,by="station_id")

aggregated_geo_location<-aggregated_geo_location%>%
  group_by(county_name,parameter_quality)%>%mutate(qual_cnt =n())
aggregated_geo_location%>%write.csv("Downloads/aggregated_results.csv")

water_borne_diseases <- fread("Downloads/674474eb-e093-42de-aef3-da84fd2ff2d8.csv")
