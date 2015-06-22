library(dplyr)
library(leafletR)

# Create geojson file from restaurant point data if needed
# mapdata <- toGeoJSON (restaurants, dest=tempdir(), lat.lon=c("latitude", "longitude"))

mapdata<- "data-out/sfrestaurants.geojson"

# Create map style
mapstyl <- styleGrad(prop="meanscore", breaks=c(0,75,80,85,90,95,100), style.val=heat.colors(6), leg="Average Restaurant Safety Score 2012-2014", fill.alpha=0.5, rad=2.5 )


# Create webmap in temporary directory
map <- leaflet(data=mapdata, dest="maps", center= c(37.77694,-122.4314), zoom=14, style=mapstyl, title="Restaurant Safety Scores", base.map="mqosm", popup=c("name","routines", "meanscore","highrisks","interval"), overwrite=TRUE)
