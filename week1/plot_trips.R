########################################
# load libraries
########################################

# load some packages that we'll need
library(tidyverse)
library(scales)
library(lubridate)

# be picky about white backgrounds on our plots
theme_set(theme_bw())

# load RData file output by load_trips.R
load('trips.RData')


########################################
# plot trip data
########################################

# plot the distribution of trip times across all rides
trips %>%
  filter(tripduration/60 < 1000) %>%
  ggplot() + 
  geom_histogram(aes(x = tripduration/60), bins = 100) + 
  scale_x_log10(label = comma) +
  scale_y_continuous(label = comma) +
  xlab("Trip Duration (min)") +
  ylab("Number of Trips")

### throwing out 1% of data
filter(trips, tripduration < quantile(tripduration, .99)) %>%
  ggplot() + 
  geom_histogram(aes(x = tripduration/60), bins = 100) + 
  scale_x_log10(label = comma) +
  scale_y_continuous(label = comma) +
  xlab("Trip Duration (min)") +
  ylab("Number of Trips")

# plot the distribution of trip times by rider type
filter(trips, tripduration < quantile(tripduration, .99)) %>%
  ggplot() +
  geom_histogram(aes(x = tripduration/60), bins = 50) + 
  scale_x_log10(label = comma) + 
  scale_y_continuous(label = comma) +
  facet_wrap(~ usertype, ncol = 1, scale = "free_y") +
  xlab("Trip Duration (min)") +
  ylab("Number of Trips") 

filter(trips, tripduration < quantile(tripduration, .99)) %>%
  ggplot() +
  geom_histogram(aes(x = tripduration/60, fill = usertype), bins = 50, position="dodge") + 
  scale_x_log10(label = comma) + 
  scale_y_continuous(label = comma) +
  xlab("Trip Duration (min)") +
  ylab("Number of Trips") +
  guides(fill = guide_legend(title="Rider Type"))

# plot the total number of trips over each day
trips %>% 
  mutate(ymd = as.Date(starttime)) %>%
  group_by(ymd) %>%
  summarize(count = n()) %>%
  ggplot(aes(x = ymd, y = count)) + 
  geom_point() +
  scale_y_continuous(label = comma) +
  xlab("Date") +
  ylab("Number of Trips")

# plot the total number of trips (on the y axis) by age (on the x axis) and gender (indicated with color)
current <- 2018
trips %>%
  mutate(age = current - birth_year) %>%
  group_by(age, gender) %>%
  filter(!is.na(age)) %>%
  summarize(count = n()) %>%
  ggplot(aes(x = age, y = count, color = gender)) +
  geom_point(na.rm = TRUE) +
  scale_y_continuous(label = comma) +
  xlab("Age") +
  ylab("Number of Trips")

# plot the ratio of male to female trips (on the y axis) by age (on the x axis)
# hint: use the spread() function to reshape things to make it easier to compute this ratio
trips %>%
  mutate(age = current - birth_year) %>%
  group_by(gender, age) %>%
  summarize(count = n()) %>%
  filter(gender != "Unknown") %>%
  spread(gender, count) %>%
  ggplot(aes(x = age, y = Male/Female)) +
  geom_point(position = "jitter", color = "blue", alpha = .4) +
  xlab("Age") +
  ylab("Male : Female")

  # geom_point(position = "jitter") +
  # geom_smooth() +
  # summarize(ratio = first(count)/last(count))


########################################
# plot weather data
########################################
# plot the minimum temperature (on the y axis) over each day (on the x axis)
ggplot(data = weather) + 
  geom_point(aes(x = ymd, y = tmin), color="purple", alpha = 0.4) +
  xlab("Date") +
  ylab("Minimum Temperature (F)")

# plot the minimum temperature and maximum temperature (on the y axis, with different colors) over each day (on the x axis)
# hint: try using the gather() function for this to reshape things before plotting
weather %>% mutate(date = as.Date(ymd)) %>%
  gather(min_or_max, temp, tmin, tmax) %>%
  ggplot() +
  geom_point(aes(x = ymd, y = temp, color = min_or_max))

t_all <- weather %>% select(ymd, tmin, tmax) %>% gather(min_or_max, temp, -ymd) 
t_all %>% 
  ggplot() + 
  geom_point(aes(x = ymd, y = temp, color = min_or_max)) +
  xlab("Date") +
  ylab("Temperature (F)") +
  guides(color=guide_legend("")) +
  scale_color_discrete(labels=c("High","Low"))


t_all %>% mutate(month = month(ymd, label = TRUE), day = day(ymd)) %>%
  ggplot() + 
  geom_point(aes(x = day, y = temp, color = min_or_max)) +
  xlab("2014") +
  ylab("Temperature (F)") +
  facet_wrap(~ month) +
  guides(color=guide_legend("")) +
  scale_color_discrete(labels=c("High","Low"))


########################################
# plot trip and weather data
########################################

# join trips and weather
trips_with_weather <- inner_join(trips, weather, by="ymd")

# plot the number of trips as a function of the minimum temperature, where each point represents a day
# you'll need to summarize the trips and join to the weather data to do this
trips_with_weather %>%
  group_by(ymd, tmin) %>%
  summarize(count = n()) %>%
  ggplot() +
  geom_point(mapping = aes(x = tmin, y = count)) +
  xlab("Minimum Temperature (F)") +
  ylab("Number of Trips")


# repeat this, splitting results by whether there was substantial precipitation or not
# you'll need to decide what constitutes "substantial precipitation" and create a new T/F column to indicate this
rainy <- quantile(trips_with_weather$prcp, c(.9))
trips_with_weather %>% 
  mutate(israiny = prcp >= rainy["90%"]) %>%
  group_by(ymd, tmin, israiny) %>%
  summarize(count = n()) %>%
  ggplot() +
  geom_point(mapping = aes(x = tmin, y = count, color = israiny)) +
  xlab("Minimum Temperature (F)") +
  ylab("Number of Trips") +
  guides(color=guide_legend("Rainy?")) +
  scale_color_discrete(labels=c("Not Really","Yes!"))


# add a smoothed fit on top of the previous plot, using geom_smooth
trips_with_weather %>% 
  mutate(israiny = prcp >= rainy["90%"]) %>%
  group_by(ymd, tmin, israiny) %>%
  summarize(count = n()) %>%
  ggplot() +
  geom_point(mapping = aes(x = tmin, y = count, color = israiny)) +
  geom_smooth(mapping = aes(x = tmin, y = count)) +
  xlab("Minimum Temperature (F)") +
  ylab("Number of Trips") +
  guides(color=guide_legend("Rainy?")) +
  scale_color_discrete(labels=c("Not Really","Yes!"))

# compute the average number of trips and standard deviation in number of trips by hour of the day
# hint: use the hour() function from the lubridate package
trips_with_weather %>%
  mutate(hour = hour(starttime)) %>%
  group_by(ymd, hour) %>%
  summarize(count = n()) %>%
  group_by(hour) %>%
  summarize(avg = mean(count), sd = sd(count))

  
# plot the above
trips_with_weather %>%
  mutate(hour = hour(starttime)) %>%
  group_by(ymd, hour) %>%
  summarize(count = n()) %>%
  group_by(hour) %>%
  summarize(avg = mean(count), sd = sd(count)) %>%
  ggplot(aes(x = hour, y = avg)) +
  geom_errorbar(aes(ymin = avg-sd, ymax = avg+sd), width = .3, alpha = 0.3) +
  geom_point(aes(x = hour, y = avg)) +
  xlab("Hour of Day") +
  ylab("Average Number of Trips")

trips_with_weather %>%
  mutate(hour = hour(starttime)) %>%
  group_by(ymd, hour) %>%
  summarize(count = n()) %>%
  group_by(hour) %>%
  summarize(avg = mean(count), sd = sd(count)) %>%
  ggplot(aes(x = hour, y = avg)) +
  geom_ribbon(aes(ymin = avg-sd, ymax = avg+sd), alpha = 0.3) +
  geom_line() +
  xlab("Hour of Day") +
  ylab("Average Number of Trips")


# repeat this, but now split the results by day of the week (Monday, Tuesday, ...) or weekday vs. weekend days
# hint: use the wday() function from the lubridate package
trips_with_weather %>%
  mutate(hour = hour(starttime),wday = wday(starttime, label = TRUE)) %>%
  group_by(ymd, wday, hour) %>%
  summarize(count = n()) %>%
  group_by(wday, hour) %>% 
  summarize(avg = mean(count), sd = sd(count)) %>%
  ggplot(aes(x = hour, y = avg)) +
  geom_errorbar(aes(ymin = avg-sd, ymax = avg+sd), width = .3, alpha = .3) +
  geom_point(aes(x = hour, y = avg), alpha = .5) +
  xlab("Hour of Day") +
  ylab("Average Number of Trips") +
  scale_y_continuous(label = comma) +
  facet_wrap(~ wday)

trips_with_weather %>%
  mutate(hour = hour(starttime),wday = wday(starttime, label = TRUE)) %>%
  group_by(ymd, wday, hour) %>%
  summarize(count = n()) %>%
  group_by(wday, hour) %>% 
  summarize(avg = mean(count), sd = sd(count)) %>%
  ggplot(aes(x = hour, y = avg)) +
  geom_ribbon(aes(ymin = avg-sd, ymax = avg+sd), alpha = 0.3) +
  geom_line() +
  xlab("Hour of Day") +
  ylab("Average Number of Trips") +
  scale_y_continuous(label = comma) +
  facet_wrap(~ wday)
