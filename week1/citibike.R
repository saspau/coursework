library(tidyverse)
library(lubridate)

########################################
# READ AND TRANSFORM THE DATA
########################################

# read one month of data
trips <- read_csv('201402-citibike-tripdata.csv')

# replace spaces in column names with underscores
names(trips) <- gsub(' ', '_', names(trips))

# convert dates strings to dates
# trips <- mutate(trips, starttime = mdy_hms(starttime), stoptime = mdy_hms(stoptime))

# recode gender as a factor 0->"Unknown", 1->"Male", 2->"Female"
trips <- mutate(trips, gender = factor(gender, levels=c(0,1,2), labels = c("Unknown","Male","Female")))


########################################
# YOUR SOLUTIONS BELOW
########################################

# count the number of trips (= rows in the data frame)
nrow(trips)

# find the earliest and latest birth years (see help for max and min to deal with NAs)
### EARLIEST
select(trips,birth_year) %>% filter(birth_year == max(birth_year))
select(trips,birth_year) %>% arrange(desc(birth_year))
### LATEST

# use filter and grepl to find all trips that either start or end on broadway
filter(trips, grepl("Broadway",start_station_name) | grepl("Broadway",end_station_name))

# do the same, but find all trips that both start and end on broadway
filter(trips, grepl("Broadway",start_station_name), grepl("Broadway",end_station_name))
### can also use & instead of , between the grepl()'s

# find all unique station names
trips %>% select(start_station_name) %>% group_by(start_station_name)

# count the number of trips by gender
trips %>% group_by(gender) %>% summarize(count = n())

# compute the average trip time by gender
# comment on whether there's a (statistically) significant difference
trips %>% group_by(gender) %>% summarize(count = n(), avg_trip_duration = mean(tripduration))

# find the 10 most frequent station-to-station trips
trips %>% 
  select(start_station_name,end_station_name) %>% 
  group_by(start_station_name,end_station_name) %>% 
  summarize(count = n()) %>% arrange(desc(count)) %>% 
  head(10)

# find the top 3 end stations for trips starting from each start station
trips %>% 
  group_by(start_station_name,end_station_name) %>% 
  summarize(count = n()) %>% 
  filter(rank(desc(count)) < 4) %>% 
  arrange(start_station_name, desc(count))

# find the top 3 most common station-to-station trips by gender

# find the day with the most trips
# tip: first add a column for year/month/day without time of day (use as.Date or floor_date from the lubridate package)

# compute the average number of trips taken during each of the 24 hours of the day across the entire month
# what time(s) of day tend to be peak hour(s)?
