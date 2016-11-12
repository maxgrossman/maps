# code: IstanbulPortStoreFinder.R
# purpose: take google place api results of stores near istanbul ports and make them shps
# comments: hardcoded, yea yea yea....

setwd("/Users/maxgrossman/github/maxgrossman/maps/istanbul/data/ShopDistrict_shops")
require(jsonlite)
require(rgdal)
require(raster)

# get lists of the jsons
shops <- list.files(".",".json")
shops <- lapply(shops,function(x) fromJSON(x))

# list with lists of shops I do not want for each json. I'll use this after
# I make my list spatial data frames to subset each spdf accordingly.

unwanted_shops <- lapply(shops,function(x) grepl(paste(
  c("restaurant","pharmacy","cafe","food"),
  collapse='|'),x$results$types))

# make them spatial polygons, attributes are name and amentiy type (store type basically)
shops <- lapply(shops,
                function(x)
                  SpatialPointsDataFrame(
                    SpatialPoints(
                      cbind(x$results$geometry$location$lng,x$results$geometry$location$lat),
                      CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")),
                    data=data.frame(name=x$results$name)))

# subset each spdf by those not returned as true in the unwanted_shops, or those
# that are not the unwanted shops, or also also also...also the wanted shops! ha!

for(i in seq(1,length(shops), by= 1)) {
  shops[i] <- shops[[i]][!unwanted_shops[[i]],]
}

# merge together, write to file
writeOGR(do.call(bind, shops),
         ".","ShopDistStores",driver="ESRI Shapefile",
         overwrite_layer = TRUE)
