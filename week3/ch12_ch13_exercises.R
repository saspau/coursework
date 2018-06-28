### from IST
# Questions 12.1 & 13.1

library(tidyverse)

magnets <- read.csv('magnets.csv')


t.test(magnets$change[30:50])

t.test(magnets$score1 ~ magnets$active)

var.test(magnets$score1 ~ magnets$active)

t.test(magnets$score2 ~ magnets$active)

var.test(magnets$score2 ~ magnets$active)


# cohen's d
std <- sd(magnets$change)

magnets %>%
  group_by(active) %>%
  summarize(count = n(),
            mean = mean(change)) %>%
  summarize(cohensd = (first(mean) - last(mean))/ std)
### cohensd = 1.23 => pretty big effect


# plot the distribution of outcomes
magnets %>%
  ggplot(aes(fill = active)) + 
  geom_histogram(aes(change), bins = 20, position="dodge", alpha=0.4)

