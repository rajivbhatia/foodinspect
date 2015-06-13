library(dplyr)
library(leafletR)

.data <- toGeoJSON (.restaurants, dest=tempdir(), lat.lon=c("latitude", "longitude"))

styl <- styleGrad(prop="meanscore", breaks=c(0,75,80,85,90,95,100), style.val=heat.colors(6), leg="Average Restaurant Score", fill.alpha=0.5, rad=4 )

map <- leaflet(data=.data, dest=tempdir(), center= c(37.77694,-122.4314), zoom=14, style=styl, title="San Francisco Restaurant Scores", base.map="mqosm", popup=c("name", "meanscore", "interval"))
