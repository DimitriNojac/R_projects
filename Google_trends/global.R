library(tidyverse)
library(shiny)
library(rAmCharts)
library(rsconnect)
library(plotly)
library(DT)
library(leaflet)
library(sf)
library(bslib)



#Load data
Trends <- readr::read_csv("data/trends.csv")
Monde <- st_read("data/CNTR_RG_10M_2020_4326.shp", quiet=TRUE)


