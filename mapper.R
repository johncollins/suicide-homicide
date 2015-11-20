library(ggplot2)
library(ggvis)
library(maptools)
library(dplyr)
library(rgdal)
library(rgeos) # for gCentroid
library(rvest)

wmap <- readOGR(dsn="data/geo/ne_110m_land", 
                layer="ne_110m_land") # convert to dataframe
wmap_df <- fortify(wmap)

# create a blank ggplot theme
theme_opts <- list(theme(panel.grid.minor = element_blank(),
                         panel.grid.major = element_blank(),
                         panel.background = element_blank(),
                         plot.background = element_rect(fill="#e6e8ed"),
                         panel.border = element_blank(),
                         axis.line = element_blank(),
                         axis.text.x = element_blank(),
                         axis.text.y = element_blank(),
                         axis.ticks = element_blank(),
                         axis.title.x = element_blank(),
                         axis.title.y = element_blank(),
                         plot.title = element_text(size=22)))

# reproject from longlat to robinson
wmap_robin <- spTransform(wmap, CRS("+proj=robin"))
wmap_df_robin <- fortify(wmap_robin)

# graticules help defining lakes
grat <- readOGR("data/geo/ne_110m_graticules_all", 
                layer="ne_110m_graticules_15") 
grat_df <- fortify(grat)

bbox <- readOGR("data/geo/ne_110m_graticules_all", 
                layer="ne_110m_wgs84_bounding_box") 
bbox_df<- fortify(bbox)

grat_robin <- spTransform(grat, CRS("+proj=robin"))  # reproject graticule
grat_df_robin <- fortify(grat_robin)
bbox_robin <- spTransform(bbox, CRS("+proj=robin"))  # reproject bounding box
bbox_robin_df <- fortify(bbox_robin)

# add country borders
countries <- readOGR("data/geo/ne_110m_admin_0_countries", 
                     layer="ne_110m_admin_0_countries") 
countries_robin <- spTransform(countries, CRS("+init=ESRI:54030"))
countries_robin_df <- fortify(countries_robin)

# load the demographic data and merge
load('killed.RData')
country.codes <- countries[[10]]
country.map <- data.frame(cid=seq(0, 176))
country.map$cid <- as.character(country.map$cid)
rownames(country.map) <- as.character(country.codes)
killed_df$id <- country.map[killed_df$Country.Code, ]
countries_robin_df <- left_join(countries_robin_df, killed_df, by='id')
colnames(countries_robin_df)[9:10] <- c('homicide', 'suicide')
save(list=c('countries_robin_df', 'bbox_robin_df', 'grat_df_robin', 
       'theme_opts'), file = "mapping.RData")
rm(list=ls())

