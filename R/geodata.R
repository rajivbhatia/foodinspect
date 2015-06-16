library(tidyr)
library(dplyr)
library(sp)
library(leafletR)

## Count inspections by business

icounts <-inspection_tbl %>%
  group_by(business, type) %>%
  summarize(count=n()) %>%
  data.frame() %>%
  spread(type,count, fill=0) %>%
  select(business, routines =routine, reinspects=reinspection, complaints =complaint) %>%
  mutate(inspects=routines+reinspects+complaints, ratio=reinspects/routines) %>%
  data.frame()

## Count violations by inspections
vcounts <- violation_tbl %>%
  group_by(inspection, risklevel) %>%
  summarize(risk_count=n()) %>%  data.frame() %>%
  spread(risklevel,risk_count, fill=0)

## Join violation counts to the inspection table
routines <- inspection_tbl %>%
  left_join(vcounts, by="inspection") %>%
  filter(type=="routine") %>%
  select (-type)
routines[,5:8] [is.na(routines[,5:8])] <- 0

## Summarize the inspection history for each restaurant
grades <- routines %>%
  filter(score>=0&score<=100) %>%
  group_by(business) %>%
  summarize(meanscore=mean(score),highrisks=mean(H)) %>%
  data.frame()

##Calculate rountine inspection interval

intervals <- inspection_tbl %>%
  filter(type=="routine") %>%
  mutate(date = as.Date(as.character(date),"%Y%m%d")) %>%
  group_by(business) %>%
  summarize(count =n(), range=(max(date)-min(date)), interval=range/(count-1)) %>%
  filter(count>=2) %>%
  select (business, interval)

## Summarize restaurant history

restaurants <- business_tbl %>%
  inner_join (icounts, by="business") %>%
  inner_join (grades, by="business") %>%
  inner_join (intervals, by="business")

# format numerical values

restaurants[,"ratio"] <- round(restaurants[,"ratio"], 2)
restaurants[,"meanscore"] <- round(restaurants[,"meanscore"], 0)
restaurants[,"highrisks"] <- round(restaurants[,"highrisks"], 2)
restaurants[,"interval"] <- round(restaurants[,"interval"], 0)

# Create indicator variables and cumulative score

restaurants[,"c1"] <- as.numeric(restaurants[,"meanscore"] < quantile(restaurants[,"meanscore"],probs=0.2))
restaurants[,"c2"] <- as.numeric(restaurants[,"highrisks"] > 1)
restaurants[,"c3"] <- as.numeric(restaurants[,"ratio"] > 1)
restaurants[,"Score"] <- (4- (restaurants[,"c1"] + restaurants[,"c2"] + restaurants[,"c3"]))

# Save data as textfile

write.csv(restaurants, "/Users/rajivbhatia/Downloads/sfrestaurants.csv", row.names = FALSE)

# filter only geocoded data

restaurants  <- restaurants  %>%
  filter(latitude!="NA"&longitude!="NA")

# Save data as geojson file

toGeoJSON (restaurants, name="sfrestaurants", dest="/Users/rajivbhatia/Downloads/", lat.lon=c("latitude", "longitude"), overwrite=TRUE)
