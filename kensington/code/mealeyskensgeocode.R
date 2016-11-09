# code: mealeyskensgeocode.R
# purpose: take google geocoder json for mealey and kens, make shpaefile
# comments: hardcoded, yea yea yea....

setwd("/users/maxgrossman/github/maxgrossman/maps/kensington")
require(jsonlite)
require(rgdal)
require(raster)

# get lists of the jsons
stores <- list.files(".",".json")
stores <- lapply(stores,function(x) fromJSON(x))


# make them spatial polygons, attributes are name and amentiy type (store type basically)
stores <- lapply(stores,
                function(x)
                  SpatialPointsDataFrame(
                    SpatialPoints(
                      cbind(x$results$geometry$location$lng,x$results$geometry$location$lat),
                      CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")),
                    data=data.frame(address=x$results$formatted_address)))

# merge together, write to file
writeOGR(do.call(bind, stores),
         ".","mealeys_kens",driver="ESRI Shapefile",
         overwrite_layer = TRUE)

# make ports spdf

i_port <- SpatialPointsDataFrame(
  SpatialPoints(
    cbind(28.97834,41.0228),
    CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")),
  data=data.frame(port="Port of Istanbul"))
h_port <- SpatialPointsDataFrame(
  SpatialPoints(
    cbind(29.013889,41.003333),
    CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs")),
  data=data.frame(port="Port of Haydarpasa,"))

writeOGR(i_port,".","portIstanbul",driver="ESRI Shapefile",overwrite_layer = TRUE)
writeOGR(h_port,".","portHaydarpasa",driver="ESRI Shapefile",overwrite_layer = TRUE)
