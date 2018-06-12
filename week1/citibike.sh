#!/bin/bash
#
# add your solution after each of the 10 comments below
#

# count the number of unique stations
cut -d, -f4 201402-citibike-tripdata.csv | tail -n +2 | sort | uniq -c | wc -l
#330
cut -d -f8 201402-citibike-tripdata.csv | tail -n +2 | sort | uniq -c | wc -l

# count the number of unique bikes
cut -d, -f12 201402-citibike-tripdata.csv | tail -n +2 | sort | uniq -c | wc -l

# count the number of trips per day
cut -d, -f2 201402-citibike-tripdata.csv |tail -n +2 | cut -d ' ' -f1 | sort | uniq -c 

# find the day with the most rides
cut -d, -f2 201402-citibike-tripdata.csv | tail -n +2 | sort | cut -d ' ' -f1 | sort | uniq -c | sort -rn | head -n1

# find the day with the fewest rides
cut -d, -f2 201402-citibike-tripdata.csv | tail -n +2 | sort | cut -d ' ' -f1 | sort | uniq -c | sort -rn | tail -n1

# find the id of the bike with the most rides
cut -d, -f12 201402-citibike-tripdata.csv | sort | uniq -c | sort -rn | head -n1

# count the number of rides by gender and birth year


# count the number of trips that start on cross streets that both contain numbers (e.g., "1 Ave & E 15 St", "E 39 St & 2 Ave", ...)

# compute the average trip duration
