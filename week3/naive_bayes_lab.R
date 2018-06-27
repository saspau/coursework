### from https://rpubs.com/dvorakt/144238

library(e1071)

# with 1 predictor
train <- data.frame(class=c("spam","ham","ham","ham"), 
                    viagra=c("yes","no","no","yes"))
train

classifier <- naiveBayes(class ~ viagra,train)
classifier

test <- data.frame(viagra=c("yes"))
test

test$viagra <- factor(test$viagra, levels=c("no","yes"))

prediction <- predict(classifier, test ,type="raw")
prediction




# with 2 predictors
train <- data.frame(type=c("spam","ham","ham","ham"), 
                    viagra=c("yes","no","no","yes"),
                    meet=c("yes","yes","yes", "no"))
train

classifier <- naiveBayes(type ~ viagra + meet,train)
classifier

test <- data.frame(viagra=c("yes"), meet=c("yes"))
test$viagra <- factor(test$viagra, levels=c("no","yes"))
test$meet <- factor(test$meet, levels=c("no","yes"))
test

prediction <- predict(classifier, test ,type="raw")
prediction



#########################################################
# exercises
#########################################################

train <- data.frame(buy=c("yes","no","no","yes"), 
                    income=c("high","high","med","low"))
train

classifier <- naiveBayes(buy ~ income, train)
classifier
# conditional probabilities display:
# given that buy={no, yes}, the probability of
# income={high, low, med} is ___

test <- data.frame(income=c("high"))
test

test$income <- factor(test$income, levels=c("high","medium", "low"))

prediction <- predict(classifier, test ,type="raw")
prediction



train <- data.frame(buy=c("yes","no","no","yes"), 
                    income=c("high","high", "med","low"),
                    gender=c("male","female","female","male"))
train

# calculate the probability that a customer will buy your product
# given that he has high income and male.
### by hand, Pr = 1

classifier <- naiveBayes(buy ~ income + gender, train)
classifier

test <- data.frame(income=c("high"), gender=c("male"))
test

test$income <- factor(test$income, levels=c("high","medium", "low"))
test$gender <- factor(test$gender, levels=c("female","male"))

prediction <- predict(classifier, test ,type="raw")
prediction

