library(tidyverse)
library(tm)
library(Matrix)
library(glmnet)
library(ROCR)
library(caret)
library(broom)

########################################
# LOAD AND PARSE ARTICLES
########################################

# read in the business and world articles from files
# combine them both into one data frame called articles
business <- read_tsv('business.tsv', quote="\'")
world <- read_tsv('world.tsv', quote="\'")
articles <- rbind(business, world)

# create a corpus from the article snippets
# using the Corpus and VectorSource functions
corpus <- Corpus(VectorSource(articles$snippet))

# create a DocumentTermMatrix from the snippet Corpus
# remove stopwords, punctuation, and numbers
dtm <- DocumentTermMatrix(corpus, list(weighting=weightBin,
                                       stopwords=T,
                                       removePunctuation=T,
                                       removeNumbers=T))
# dtm[1,]

# convert the DocumentTermMatrix to a sparseMatrix
X <- sparseMatrix(i=dtm$i, j=dtm$j, x=dtm$v, dims=c(dtm$nrow, dtm$ncol), dimnames=dtm$dimnames)

# set a seed for the random number generator so we all agree
set.seed(42)

########################################
# YOUR SOLUTION BELOW
########################################

# create a train / test split
idx <- sample(1:nrow(X), nrow(X)*0.8, replace=FALSE)
train <- X[idx,]
sections_train <- articles$section_name[idx]
test <- X[-idx,]
sections_test <- as.data.frame(articles$section_name[-idx])



# cross-validate logistic regression with cv.glmnet (family="binomial"), measuring auc
# performing lasso (alpha=1) by default
model <- cv.glmnet(train, sections_train, family="binomial", type.measure="class")
# also try type.measure="class
summary(model)



# plot the cross-validation curve
plot(model)
# top row of numbers = number of words being used for classification



# evaluate performance for the best-fit model
# note: it's useful to explicitly cast glmnet's predictions
# use as.numeric for probabilities and as.character for labels for this
names(sections_test)[1] < -"actual"
sections_test$pred <- as.factor(predict(model, test, type="class"))
sections_test$prob <- as.numeric(predict(model, test, type="response"))
sections_test$raw <- as.numeric(predict(model, test))



# compute accuracy
mean(sections_test$actual == sections_test$pred)



# look at the confusion matrix
confusionMatrix(sections_test$pred, sections_test$actual)



# plot an ROC curve and calculate the AUC
# (see last week's notebook for this)

# create a ROCR object
pred <- prediction(sections_test$prob, sections_test$actual)

perf_nb <- performance(pred, measure='tpr', x.measure='fpr')
plot(perf_nb)
performance(pred, 'auc')



# show weights on words with top 10 weights for business
# use the coef() function to get the coefficients
# and tidy() to convert them into a tidy data frame

# based on the 'raw' predictions, more negative values correspond
# to business
tidy(coef(model)) %>% arrange(value) %>% head(10)
# values = how much the log odds are changing



# show weights on words with top 10 weights for world

# based on the 'raw' predictions, more positive values correspond
# to world
tidy(coef(model)) %>% arrange(desc(value)) %>% head(10)
