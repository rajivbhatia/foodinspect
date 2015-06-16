library(dplyr)
library(leafletR)

mapdata <- toGeoJSON (restaurants, dest=tempdir(), lat.lon=c("latitude", "longitude"))

mapstyl <- styleGrad(prop="meanscore", breaks=c(0,75,80,85,90,95,100), style.val=heat.colors(6), leg="AverageRestaurant Score", fill.alpha=0.5, rad=4 )

map <- leaflet(data=mapdata, dest="maps", center= c(37.77694,-122.4314), zoom=14, style=mapstyl, title="Restaurant Scores", base.map="mqosm", popup=c("name", "meanscore", "interval"))
