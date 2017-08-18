library(ggplot2)
library(XML)
library(plyr)
library(maps)
library(mapproj)
library(ggmap)
library(dplyr)
library(stringr)
library(gridExtra)

setwd('C:/Users/admin/Desktop/Nanodegree/R/Project 5')
df <- read.csv('popden_county.csv')
levels(df$subregion) <- tolower(levels(df$subregion))

str(df)
df$subregion <- as.character(df$subregion)
df$area <- as.character(df$area)
df$density <- as.character(df$density)
str(df)

#Mapping USA
usa <- map_data("usa")
ggplot() + geom_polygon(data = usa, aes(x=long, y = lat, group = group)) + 
  coord_fixed(1.3)

#Mapping Washington State
states <- map_data("state")
washington <- subset(states, region %in% c("washington"))
ggplot(data = washington) + 
  geom_polygon(aes(x = long, y = lat, group = group), fill = "palegreen", color = "black") + 
  coord_fixed(1.3)

#divide by county
counties <- map_data("county")
wa_county <- subset(counties, region == "washington")
wa_base <- ggplot(data = wa_county, mapping = aes(x = long, y = lat, group = group)) + 
  coord_fixed(1.3) + geom_polygon(color = "black", fill = "gray")
wa_base + theme_nothing() + 
  geom_polygon(data = wa_county, fill = NA, color = "white") +
  geom_polygon(color = "black", fill = NA)

#mapping
ditch_the_axes <- theme(
  axis.text = element_blank(),
  axis.line = element_blank(),
  axis.ticks = element_blank(),
  panel.border = element_blank(),
  panel.grid = element_blank(),
  axis.title = element_blank()
)

str(wa_county)
str(df)

base <- inner_join(wa_county, df, by = "subregion")
no_comma_density <- gsub(",","",base$density)
no_comma_area <- gsub(",","",base$area)
base$density <- as.numeric(no_comma_density)
base$area <- as.numeric(no_comma_area)

base$population <- base$area*base$density

str(base)

eb1 <- wa_base +
  geom_polygon(data = base, aes(fill = population), color = "white") +
  geom_polygon(color = "black", fill = NA) +
  theme_bw() +
  ditch_the_axes

eb1

eb1_density <- wa_base +
  geom_polygon(data = base, aes(fill = density), color = "white") +
  geom_polygon(color = "black", fill = NA) +
  theme_bw() +
  ditch_the_axes

eb1_density + scale_fill_gradient(trans = "log10")

eb2_density <- eb1_density + scale_fill_gradientn(colours = rev(rainbow(7)),
                       breaks = c(2, 4, 10, 50, 100, 1000),
                       trans = "log10")
eb2_density

eb2_density + coord_fixed(xlim = c(-121, -123),  ylim = c(47, 48), ratio = 1.3)

bldg = read.csv('Building_Permit.csv')
str(bldg)

#Data Cleaning
bldg <- subset(bldg, Category != "")
bldg <- subset(bldg, Action.Type != "")
bldg <- subset(bldg, Status != "")
bldg$Value = as.numeric(gsub("[\\$,]", "", bldg$Value))
bldg$Value = log10(bldg$Value)

sbbox <- make_bbox(lon = bldg$Longitude, lat = bldg$Latitude, f=0.1)
sbbox

sq_map <- get_map(location = sbbox, maptype = "satellite", source = "google")
#ggmap(sq_map) + geom_point(data = bldg, mapping = aes(x = Longitude, y = Latitude, color=Permit.Type))
#  scale_color_discrete(colours = rev(rainbow(3)), breaks=c("Construction", "Demolition", "Site Development"))
ggmap(sq_map) + geom_point(data = bldg, mapping = aes(x = Longitude, y = Latitude, color=Value), alpha=1/10) +
  scale_colour_gradientn(colours = rev(rainbow(7)), breaks = c(1, 2, 3, 4, 6, 8))
#Permit.Type, Cateogry, Action.Type, Work.Type, Status
ggmap(sq_map) + stat_bin2d(aes(x=Longitude, y=Latitude, colour=Permit.Type), data=bldg,
                           size=1, bins=50, alpha=1)
#ggmap(sq_map) + stat_density2d(aes(x=Longitude, y=Latitude, fill=..level.., alpha=..level..), data=bldg,
#                           size=2, bins=4, geom='polygon')'
filtered_bldg <- bldg[bldg$Permit.Type == 'Construction',]
filtered_bldg_commercial <- filtered_bldg[filtered_bldg$Category == 'COMMERCIAL',]
ggmap(sq_map) + geom_point(data = filtered_bldg_commercial, mapping = aes(x = Longitude, y = Latitude, color=Action.Type))

filtered_bldg_multifamily <- filtered_bldg[filtered_bldg$Category == 'MULTIFAMILY',]
ggmap(sq_map) + geom_point(data = filtered_bldg_multifamily, mapping = aes(x = Longitude, y = Latitude, color=Action.Type))

filtered_bldg_industrial <- filtered_bldg[filtered_bldg$Category == 'INDUSTRIAL',]
ggmap(sq_map) + geom_point(data = filtered_bldg_industrial, mapping = aes(x = Longitude, y = Latitude, color=Action.Type))

filtered_bldg_single <- filtered_bldg[filtered_bldg$Category == 'SINGLE FAMILY / DUPLEX',]
ggmap(sq_map) + geom_point(data = filtered_bldg_single, mapping = aes(x = Longitude, y = Latitude, color=Action.Type))

filtered_bldg_institutional <- filtered_bldg[filtered_bldg$Category == 'INSTITUTIONAL',]
ggmap(sq_map) + geom_point(data = filtered_bldg_institutional, mapping = aes(x = Longitude, y = Latitude, color=Action.Type))


filtered_bldg_de <- bldg[bldg$Permit.Type == 'Demolition',]
filtered_bldg_commercial_de <- filtered_bldg_de[filtered_bldg$Category == 'COMMERCIAL',]
ggmap(sq_map) + geom_point(data = filtered_bldg_commercial_de, mapping = aes(x = Longitude, y = Latitude, color=Action.Type))

filtered_bldg_multifamily_de <- filtered_bldg_de[filtered_bldg_de$Category == 'MULTIFAMILY',]
ggmap(sq_map) + geom_point(data = filtered_bldg_multifamily, mapping = aes(x = Longitude, y = Latitude, color=Action.Type))

filtered_bldg_industrial_de <- filtered_bldg_de[filtered_bldg_de$Category == 'INDUSTRIAL',]
ggmap(sq_map) + geom_point(data = filtered_bldg_industrial_de, mapping = aes(x = Longitude, y = Latitude, color=Action.Type))

filtered_bldg_single_de <- filtered_bldg_de[filtered_bldg_de$Category == 'SINGLE FAMILY / DUPLEX',]
ggmap(sq_map) + geom_point(data = filtered_bldg_single_de, mapping = aes(x = Longitude, y = Latitude, color=Action.Type))

filtered_bldg_institutional_de <- filtered_bldg_de[filtered_bldg_de$Category == 'INSTITUTIONAL',]
ggmap(sq_map) + geom_point(data = filtered_bldg_institutional_de, mapping = aes(x = Longitude, y = Latitude, color=Action.Type))



