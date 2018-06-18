library(jsonlite)
library(tidyr)
#library(stringi)

#tidyverse<-left_join
library(tidyverse)

#library(lubridate)

#data <-fromJSON("https://power.larc.nasa.gov/cgi-bin/v1/DataAccess.py?request=execute&identifier=SinglePoint&parameters=PRECTOT,T2M,T2M_MAX,T2M_MIN&startDate=1981&endDate=2017&userCommunity=AG&tempAverage=INTERANNUAL&outputList=JSON,ASCII&lat=-33.05&lon=-60.55&user=anonymous%22")
#table<-data[["features"]][["properties"]][["parameter"]]
gps<-ggmap::geocode("Rosario, Santa Fe")
lati=gps$lat
long=gps$lon


url<-paste0("https://power.larc.nasa.gov/cgi-bin/v1/DataAccess.py?request=execute&identifier=SinglePoint&parameters=PRECTOT,T2M,T2M_MAX,T2M_MIN&startDate=1981&endDate=2017&userCommunity=AG&tempAverage=INTERANNUAL&outputList=JSON,ASCII&lat=",lati,"&lon=",long,"&user=anonymous%22")
json_data <- fromJSON(url)
table<-json_data[["features"]][["properties"]][["parameter"]]


tablePre<-table$PRECTOT %>%
gather( key = "date", value = "precipitation")

tableMax<-table$T2M_MAX %>%
  gather( key = "date", value = "temp_max")

tableMin<-table$T2M_MIN %>%
  gather( key = "date", value = "temp_min")

tableTemp<-table$T2M %>%
  gather( key = "date", value = "temp")

totalTable<-tablePre %>%
  left_join(tableTemp, by = "date")

totalTable<-totalTable %>%
  left_join(tableMax, by = "date")

totalTable<-totalTable %>%
  left_join(tableMin, by = "date")


#from string to date
#stri_sub(totalTable$year, 5, 4) <- "-"
#stri_sub(totalTable$year, 9, 8) <- "-01"
#totalTable$year<-as.Date(totalTable$year)

#from string to date
totalTable$date<-parse_date(totalTable$date, "%Y%m")

#add column "year"
totalTable$year<-format(totalTable$date, "%Y")

#add column "month"
totalTable$month<-format(totalTable$date, "%m")

#drop rows containing missing values
totalTable<-drop_na(totalTable)

totalTable<-totalTable %>%
  mutate(tmm = precipitation * 30.5)
totalTable$year<-as.numeric(totalTable$year)
totalTable$month<-as.numeric(totalTable$month)

filtredTable<-totalTable %>%
  filter( year >= "1999" )%>%
  filter( year <= "2000" )
filtredTable

ggplot(totalTable, aes(month, temp, group=year, color=as.numeric(year)))+
  geom_line(alpha=0.5)+
  theme(axis.line = element_line(color="orange", size=1))+scale_color_continuous()

#ENSO DATA

library(readxl)
DataENSO <- read_excel("C:/Users/pasqu/Dropbox/V. Amelia - Ensayos/ENSO/HistoricoEnso-Analisis.xlsx",
col_types = c("numeric", "numeric", "numeric",
"numeric", "numeric", "numeric",
"numeric", "numeric", "numeric",
"numeric", "numeric", "numeric",
"numeric"))


dataENSO<-DataENSO %>%
  gather(`1`, `2`,`3`,`4`,`5`,`6`,`7`,`8`,`9`,`10`,`11`,`12`, key = "month", value = "tempENSO")
dataENSO<-dataENSO %>%
  mutate(type=case_when(tempENSO>0.4 ~ "niño", tempENSO <= -0.5 ~ "niña", TRUE ~ "neutro" ))

dataENSO$year<-as.integer(dataENSO$year)
#dataENSO$year<-as.character.Date (dataENSO$year)
dataENSO$month<-as.integer(dataENSO$month)
#dataENSO$month<-as.character.Date(dataENSO$month)
#dataENSO$month<-format(dataENSO$month, "%m")

totalTable%>%
  left_join(dataENSO)
totalTable
