### from https://rpubs.com/dvorakt/255527


library(dplyr)
library(stargazer)
library(caret)

loan <- read.csv("https://www.dropbox.com/s/89g1yyhwpcqwjn9/lending_club_cleaned.csv?raw=1")
summary(loan)


### estimating a logistic regression

logit1 <- glm(good ~ fico, data = loan, family = "binomial")
# family = "binomial" indicates we want to fit a logistic function
summary(logit1)
# "The coefficient on fico is positive and statistically significant. 
# It tells us that a one point increase in fico score raises the log of odds 
# ratio by 0.01"

exp(coef(logit1))
# "The exponential of the slope coefficient tells us the factor by which odds 
# increase if the independent variable increases by one. So, if a fico score 
# increases by 1 point, the odds ratio of loan being good increases by factor 
# of 1.012 which means odds increase 1.2 percent"



### interpreting coefficients in terms of probability

# we want to know the effect of fico going from 700 to 750 on the probability 
# of loan being good
test <- data.frame(fico=c(700,750))
test$pred <- predict(logit1, test, type="response")
test

# "The fico score going from 700 to 750 increases the probability of 
# a good loan by seven percentage points"




### interpreting coefs in a multiple regression
logit2 <- glm(good ~ fico + loan_amnt, data = loan, family = "binomial")
summary(logit2)

exp(coef(logit2))


### working with categorial/factor variables
logit3 <- glm(good ~ fico + loan_amnt + purpose, data = loan, family = "binomial")
summary(logit3)

round(exp(coef(logit3)),3)
# "The coefficients show that the odds of a loan being good are lower for educational 
# loans relative to debt consolidation loans by a factor of 0.57, or about 43% lower. 
# As another example, let's take vacation and wedding loans.These have shockingly 12% 
# higher odds of being good than debt consolidation loans."


# reordering factors by number of observations rather than alphabetical order
loan <- loan %>% group_by(purpose) %>% mutate(nobs=n()) 
loan$purpose <-  reorder(loan$purpose, -loan$nobs)
levels(loan$purpose)



### dealing with missing values
logit4 <- glm(good ~ fico + loan_amnt + income + purpose, data = loan, family = "binomial")
summary(logit4)





### testing log reg model out of sample
set.seed(364)
sample <- sample(nrow(loan),floor(nrow(loan)*0.8))
train <- loan[sample,]
test <- loan[-sample,]

logit4 <- glm(good ~ fico + dti+ loan_amnt + purpose, data = train, family = "binomial")
test$pred <- predict(logit4, test, type="response")

test$good_pred <- ifelse(test$pred > 0.80, "good", "bad")
test$good_pred <- factor(test$good_pred, levels=c("bad", "good"))
confusionMatrix(test$good_pred, test$good)
# accuracy: 75%
# we detect bad loans in 34% of cases
# we label good loans as good in 83% of cases




###########################################################
# exercises
###########################################################

# Let's load the Titanic training data. What are the odds of surviving the shipwreck?
titanic_train <- read.csv('titanic_train.csv')
mean(titanic_train$Survived)



# Using the logit model, estimate how much lower are the odds of survival for men relative to women?
logit <- glm(Survived ~ Sex, data = titanic_train, family = "binomial")
summary(logit)
exp(coef(logit))
# Sexmale = 0.0809
# Odds of survival for a male are lower related to the odds of survival
# relative for a female by a factor of 0.08 (92% lower)



# Controlling for gender, does age have a statistically significant effect 
# on the odds of survival? If so, what is the magnitude of that effect?
logit <- glm(Survived ~ Sex + Age, data = titanic_train, family = "binomial")
summary(logit)
exp(coef(logit))



# Controlling for gender, does passenger class have a statistically 
# significant effect on the odds of survival? If so, what is the magnitude 
# of that effect?
logit <- glm(Survived ~ Sex + Pclass, data = titanic_train, family = "binomial")
summary(logit)
exp(coef(logit))



# Controlling for gender, estimate the effect of being in the second 
# class relative to first class, and the effect of being in the third 
# relative to first.
logit <- glm(Survived ~ Sex + factor(Pclass), data = titanic_train, family = "binomial")
summary(logit)
exp(coef(logit))
# 57% lesser chance of surviving if in 2nd class, relative to 1st
# 86% lesser chance of surviving if in 3rd class, relative to 1st



# Add fare to the regression you estimated above. Is fare a significant 
# determinant of survival controlling for gender and passenger class? 
# Do you think that if we regressed survival on just gender and fare, fare
# would be significant? Explain.
logit <- glm(Survived ~ Sex + factor(Pclass) + Fare, data = titanic_train, family = "binomial")
summary(logit)
exp(coef(logit))



### Jack traveled in the third class and paid 5 pounds. 
# Rose traveled in the first class and paid 500 for her ticket.
# What is the probability that Jack will survive? What is the probability 
# that Rose will survive?

test <- data.frame(Name = c("Jack","Rose"),
                   Sex = c("male","female"),
                   Pclass = c("3","1"),
                   Fare = c(5, 500))

test$pred <- predict(logit, test, type="response")
test
# Jack has a 9.46% chance of survival; Rose has a 95.5% chance of survival



### Create your own logistic model and make predictions for passengers 
# in the Titanic test data set. Keep in mind that you must make predictions 
# for all passengers in the test data (even those with missing values). 
# Use your own probability cut off for predicting survival (0.5 is a natural 
# start). 
set.seed(364)
sample <- sample(nrow(titanic_train),floor(nrow(titanic_train)*0.8))
train <- titanic_train[sample,]
test <- titanic_train[-sample,]

logit <- glm(Survived ~ Sex + factor(Pclass) + SibSp, data = titanic_train, family = "binomial")
# summary(logit)

test$pred <- predict(logit, test, type="response")

test$good_pred <- ifelse(test$pred > 0.50, 1, 0)
confusionMatrix(factor(test$good_pred), factor(test$Survived))

