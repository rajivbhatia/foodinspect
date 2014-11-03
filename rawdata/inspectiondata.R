require(stringr)
require(tidyr)
require(dplyr)    # devtools::install_github("hadley/dplyr")


message("Importing buisiness data")
business_tbl <-read.csv ("rawdata/sf/businesses.csv") %>% mutate(business=as.character(business_id)) %>% select(business, name,latitude,longitude)

message("Importing inspection data")
inspection_tbl <-read.csv ("rawdata/sf/inspections.csv") %>% mutate(business=as.character(business_id),score=Score,inspection=paste(as.character(business_id),date=as.character(date), sep="-"), type=strtrim(type,2)) %>%select(business,inspection,score,date,type)

message("Importing violation data")
violation_tbl <-read.csv ("rawdata/sf/violations.csv") %>% mutate(inspection=paste(as.character(business_id),date=as.character(date), sep="-"), violation=as.character(ViolationTypeID),risklevel=strtrim(risk_category,1))%>% select(inspection, violation, risklevel)

message("Saving data to `inspectiondata`")
save(business_tbl, 
     inspection_tbl, 
     violation_tbl, 
     file = file.path("data","inspectiondata.rdata"))
