library(tidyr)
library(dplyr)
library(sp)
library(leafletR)

## Count inspections by business

.icounts <-inspection_tbl %>%
  group_by(business, type) %>%
  summarize(count=n()) %>%
  data.frame() %>%
  spread(type,count, fill=0) %>%
  select(business, routines =routine, reinspects=reinspection, complaints =complaint) %>%
  mutate(inspects=routines+reinspects+complaints, ratio=reinspects/routines) %>%
  data.frame()

## Count violations by inspections
.vcounts <- violation_tbl %>%
  group_by(inspection, risklevel) %>%
  summarize(risk_count=n()) %>%  data.frame() %>%
  spread(risklevel,risk_count, fill=0)

## Join violation counts to the inspection table
.routines <- inspection_tbl %>%
  left_join(.vcounts, by="inspection") %>%
  filter(type=="routine") %>%
  select (-type)
.routines[,5:8] [is.na(.routines[,5:8])] <- 0

## Summarize the inspection history for each restaurant
.grades <- .routines %>%
  filter(score>=0&score<=100) %>%
  group_by(business) %>%
  summarize(meanscore=mean(score),highrisks=mean(H)) %>%
  data.frame()

##Calculate rountine inspection interval

.intervals <- inspection_tbl %>%
  filter(type=="routine") %>%
  mutate(date = as.Date(as.character(date),"%Y%m%d")) %>%
  group_by(business) %>%
  summarize(count =n(), range=(max(date)-min(date)), interval=range/(count-1)) %>%
  filter(count>=2) %>%
  select (business, interval)

## Summarize restaurant history

.restaurants <- business_tbl %>%
  inner_join (.icounts, by="business") %>%
  inner_join (.grades, by="business") %>%
  inner_join (.intervals, by="business")

# format numerical values

.restaurants[,"ratio"] <- round(.restaurants[,"ratio"], 2)
.restaurants[,"meanscore"] <- round(.restaurants[,"meanscore"], 0)
.restaurants[,"highrisks"] <- round(.restaurants[,"highrisks"], 2)
.restaurants[,"interval"] <- round(.restaurants[,"interval"], 0)


# filter geocoded data

.restaurants  <- .restaurants  %>%
  filter(latitude!="NA"&longitude!="NA")


# Save restaurant safety data as .csv file

write.csv(.restaurants, "/Users/rajivbhatia/Downloads/sfrestaurantsafety.csv", row.names = FALSE)


toGeoJSON (.restaurants, name="sfrestaurantsafety", dest="/Users/rajivbhatia/Downloads/", lat.lon=c("latitude", "longitude"), overwrite=TRUE)
