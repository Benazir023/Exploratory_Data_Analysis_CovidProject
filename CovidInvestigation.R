
#Herein we seek to understand the trends in the covid-19 pandemic, to gain a better understanding of the same. 
#Our analysis seeks to find out the countries that had the highest number of positive cases against the number of tests. 
  
#Get & set the working directory

getwd()
WorkingDirectory <- setwd("D:/BENA/Data Analytics/Dataquest/Project1_CovidInvestigation")
getwd()

#Save Workspace

save.image("CovidInvestigation.Rdata")

#Save history

savehistory("CovidInvestigation.Rhistory")

#Load packages 

library(tidyverse)
library(readr)

#Import data

covid_df <- read_csv("D:/BENA/Data Analytics/Dataquest/Project1_CovidInvestigation/covid19.csv")

#Understanding the data

dim(covid_df)
vector_cols <- colnames(covid_df)
head(covid_df)
glimpse(covid_df)
View(covid_df)

#Filter data

covid_df_all_states <- covid_df %>%
  filter(Province_State == "All States") %>%
  select(-Province_State)

#Daily data

covid_df_all_states_daily <- covid_df_all_states %>%
  select(Date, Country_Region, active, hospitalizedCurr, daily_tested, daily_positive)

#Data aggregation

covid_df_all_states_daily_sum <- covid_df_all_states %>%
  group_by(Country_Region) %>%
  summarise(tested = sum(daily_tested),
            positive = sum(daily_positive),
            active = sum(active),
            hospitalized = sum(hospitalizedCurr)) %>%
  arrange(-tested)

#Extract top 10 countries

covid_top_10 <- head(covid_df_all_states_daily_sum, 10)

#Create vectors from covid_top_10

countries <- covid_top_10$Country_Region 
tested_cases <- covid_top_10$tested
positive_cases <- covid_top_10$positive
active_cases <- covid_top_10$active
hospitalized_cases <- covid_top_10$hospitalized 

#Name vectors

names(tested_cases) <- countries
names(positive_cases) <- countries
names(active_cases) <- countries 
names(hospitalized_cases) <- countries

#Positive_tested ratio

positivity_ratio <- covid_top_10 %>%
  mutate(positivity_ratio = positive_cases/tested_cases) %>%
  arrange(-positivity_ratio)

positive_tested_top3 <- c(0.113, 0.109, 0.0807)
positive_top3_countries <- c("United Kingdom", "United States", "Turkey")
names(positive_tested_top3) <-  positive_top3_countries

#Top3 matrix on positivity ratio

united_kingdom <- c(0.11, 1473672, 166909, 0, 0)
united_states <- c(0.10, 17282363, 1877179, 0, 0)
turkey <- c(0.08, 2031192, 163941, 2980960, 0)

covid_mat <- rbind(united_kingdom, united_states, turkey)
colnames(covid_mat) <- c("Ratio", "tested", "positive", "active", "hospitalized")

#others

deaths <- covid_df_all_states %>%
  arrange(-death) %>%
  group_by(Country_Region)

#Creating lists

question <- c("Which countries have had the highest number of positive cases against the number of tests?")
answer <- c("Positive tested cases" = positive_tested_top3)
data_structure_list <- list(covid_df=covid_df, covid_df_all_states=covid_df_all_states, covid_df_all_states_daily=covid_df_all_states_daily, covid_top_10=covid_top_10,covid_mat=covid_mat,vector_cols=vector_cols,countries=countries)

#Combine lists

covid_analysis_list <- list(question=question, answer=answer, data_structure_list=data_structure_list)

#Display the second element of this list
covid_analysis_list[[2]]
covid_analysis_list[2]




