# Geographic data
# ---------------
# Had to download geo data manually from
# Land:
# http://www.naturalearthdata.com/downloads/110m-physical-vectors/110m-land
# Countries:
# ... /downloads/110m-cultural-vectors/110m-admin-0-countries/
# Graticules:
# ... /downloads/110m-physical-vectors/110m-graticules/
#detach('package:rvest', unload=TRUE)
#remove.packages('rvest')
#install_github('hadley/rvest#119') # with my PR for rowspan
library(rvest)
library(dplyr)
library(stringr)

# Dmographic data
# Suicide:
suicide_url = 'https://en.wikipedia.org/wiki/List_of_countries_by_suicide_rate'
suicide_html <- read_html(suicide_url)
suicide_df <- suicide_html %>%
    html_nodes("table.wikitable") %>%
    .[[1]] %>% html_table(header=T, fill=T) %>%
    select(Country, `Both sexes`)
colnames(suicide_df)[2] <- 'Rate'
suicide_df$Country <- gsub('\\(more info\\)', '', suicide_df$Country) %>% 
    str_trim
# manual corrections
suicide_df$Country[which(suicide_df$Country=='Viet Nam')] <- 'Vietnam'
suicide_df$Country[which(suicide_df$Country=='Cabo Verde')] <- 'Cape Verde'
suicide_df$Country[which(suicide_df$Country=='Cote d\'Ivoire')] <- 'Ivory Coast'
suicide_df$Country[which(suicide_df$Country=='Republic of Macedonia')] <- 'Macedonia'

# Homicide:
homicide_url = 'https://en.wikipedia.org/wiki/List_of_countries_by_intentional_homicide_rate'
homicide_html <- read_html(homicide_url)
homicide_df_raw <- homicide_html %>%
    html_nodes("table.wikitable") %>%
    .[[3]] %>%
    html_table(header=F, fill=T)
homicide_df <- homicide_df_raw[4:nrow(homicide_df_raw),]
colnames(homicide_df) <- homicide_df_raw[2,]
colnames(homicide_df)[1] <- 'Country'
homicide_df <- homicide_df %>% select(Country, Rate)

# Merge the data
colnames(homicide_df)[2] <- 'Homicide Rate'
homicide_df$`Homicide Rate` <- as.numeric(homicide_df$`Homicide Rate`)
colnames(suicide_df)[2] <- 'Suicide Rate'
suicide_df$`Suicide Rate` <- as.numeric(suicide_df$`Suicide Rate`)
killed_df <- merge(homicide_df, suicide_df, all.x=T, all.y=T)

# Get Country codes
killed_df$Country <- gsub('\\(.*\\)', '', killed_df$Country)
killed_df$Country <- gsub('St\\.', 'Saint', 
                          killed_df$Country, ignore.case=T)
killed_df$Country <- gsub('United States', 'US', 
                          killed_df$Country, ignore.case=T) %>% str_trim
killed_df$Country <- gsub('French Ginea', 'Guinea', 
                          killed_df$Country, ignore.case=T) %>% str_trim
killed_df$Country <- gsub('South Korea', 'Korea, Rep.', 
                          killed_df$Country, ignore.case=T) %>% str_trim
killed_df$Country <- gsub('North Korea', 'Korea, Dem. Rep.', 
                          killed_df$Country, ignore.case=T) %>% str_trim
killed_df$Country <- gsub('Cape Verde', 'Cabo Verde', killed_df$Country, ignore.case=T) %>% str_trim
killed_df$Country <- gsub('democratic', 'Dem.', killed_df$Country, ignore.case=T) %>% str_trim
killed_df$Country <- gsub('republic', 'Rep.', killed_df$Country, ignore.case=T) %>% str_trim
killed_df$Country <- gsub('Iran', 'Iran, Islamic Rep.', killed_df$Country, ignore.case=T) %>% str_trim
killed_df$Country <- gsub('Russia', 'Russian Federation', killed_df$Country, ignore.case=T) %>% str_trim


library(RCurl)
dat_url <- getURL("https://gist.githubusercontent.com/hrbrmstr/7a0ddc5c0bb986314af3/raw/6a07913aded24c611a468d951af3ab3488c5b702/pop.csv")
pop <- read.csv(text=dat_url, stringsAsFactors=FALSE, header=TRUE)
pop_name <- gsub('\\(U\\.S\\.\\)', 'US', pop$Country.Name)
pop_name <- gsub('\\(.*\\)', '', pop_name)
pop_name <- gsub('St\\.', 'Saint ', pop_name, ignore.case=T)
pop_name <- gsub('United States', 'US', pop_name, ignore.case=T)
pop_name <- gsub('democratic', 'Dem.', pop_name, ignore.case=T) %>% str_trim
pop_name <- gsub('republic', 'Rep.', pop_name, ignore.case=T) %>% str_trim
pop$pop_name <- pop_name

source('match_words.R')
matches <- match_wordsets(killed_df$Country, pop_name,  bijective=T)
killed_df <- killed_df %>% 
    filter(Country %in% matches$word1) %>%
    left_join(matches[, c('word1', 'word2')], by=c('Country'='word1'))
killed_df <- killed_df %>%
    left_join(pop[, c('pop_name', 'Country.Code')], by=c('word2'='pop_name')) %>%
    mutate(word2=NULL)

# new vars
killed_df$hom_ge <- killed_df$`Homicide Rate` >= killed_df$`Suicide Rate` 

# So, there are countries for which we have a homicide rate
# but no suiceide rate but not vice-versa. Saving.
save(killed_df, file = "killed.RData")
rm(list=ls())
