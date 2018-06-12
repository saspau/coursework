#!/bin/bash
#
# add your solution after each of the 10 comments below
#

# count the number of unique stations
cut -d, -f9 201402-citibike-tripdata.csv | tail -n +2 | sort | uniq -c | wc -l
#330

# count the number of unique bikes
cut -d, -f12 201402-citibike-tripdata.csv | tail -n +2 | sort | uniq -c | wc -l

# count the number of trips per day

# find the day with the most rides

# find the day with the fewest rides

# find the id of the bike with the most rides

# count the number of rides by gender and birth year

# count the number of trips that start on cross streets that both contain numbers (e.g., "1 Ave & E 15 St", "E 39 St & 2 Ave", ...)

# compute the average trip duration
