require(stringr)
require(tidyr)
require(dplyr)    # devtools::install_github("hadley/dplyr")

#Import raw data files

message("Importing buisiness data")
business_tbl <-read.csv ("rawdata/sf/businesses.csv") %>%
  mutate(business=as.character(business_id), taxcode=as.character(TaxCode)) %>%
  filter(taxcode=="H24"|taxcode=="H25"|taxcode=="H26"|taxcode=="H28"|taxcode=="H29") %>%
  select(business, name, taxcode, latitude,longitude)

message("Importing inspection data")
inspection_tbl <-read.csv ("rawdata/sf/inspections.csv") %>%
  mutate(business=as.character(business_id),score=Score,inspection=paste(as.character(business_id),date=as.character(date), sep="-"), type=as.character(type)) %>%
  select(business,inspection,score,date,type)

message("Importing violation data")
violation_tbl <-read.csv ("rawdata/sf/violations.csv") %>%
  mutate(inspection=paste(as.character(business_id),date=as.character(date), sep="-"), violation=as.character(ViolationTypeID),risklevel=strtrim(risk_category,1))%>%
  select(inspection, violation, risklevel)

message("Retyping Inspections")

replace.type  <- function(pattern, replacement, x, ...) {
  if (length(pattern)!=length(replacement)) {
    stop("pattern and replacement do not have the same length.")
  }
  result <- x
  for (i in 1:length(pattern)) {
    result <- gsub(pattern[i], replacement[i], result, ...)
  }
  result
}

oldtypes <-as.character(unique (inspection_tbl$type))

newtypes<-c("reinspection", "routine", "complaint", "other", "reinspection", "other", "other", "routine","other", "other","other","other","other")

if (length(oldtypes)!=length(newtypes)) {
  stop("pattern and replacement do not have the same length.")}

inspection_tbl$type <- replace.type(oldtypes,newtypes,inspection_tbl$type)

# Save Inspection Data

message("Saving data to `inspectiondata`")
save(business_tbl,
     inspection_tbl,
     violation_tbl,
     file = file.path("data","inspectiondata.rdata"))
