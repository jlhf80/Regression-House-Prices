##############################################
# James Henson
# CIS 508: Data Mining I
# House Prices: Advanced Regression Techniques
# filename: HousePriceEDA.R
#
# The purpose of the assignment is to submit a prediction for house prices
# based on the provided data from the Kaggle Competition. Here is a brief look at the data
# before creating and submitting predictions
##############################################

library(caret)
library(AppliedPredictiveModeling)
library(dplyr)
library(ellipse)
library(corrplot)
library(Hmisc)

##### Function for displaying correlation data ####
flattenCorrMatrix <- function(cormat, pmat) {
  ut <- upper.tri(cormat)
  data.frame(
    row = rownames(cormat)[row(cormat)[ut]],
    column = rownames(cormat)[col(cormat)[ut]],
    cor  =(cormat)[ut],
    p = pmat[ut]
  )
}
###################################################

#Import data
test <- read.csv( "C:/Users/jlh_5/OneDrive/Documents/zillowHousePrices/test.csv")
train <- read.csv( "C:/Users/jlh_5/OneDrive/Documents/zillowHousePrices/train.csv")

#1460 obs of 81 variables. Various data types and some missing values
str(train)

#Get numeric and categorical
train_num <- dplyr::select_if(train, is.numeric)
train_cat <- dplyr::select_if(train, is.factor)

#Visualize
range(train_num$OverallQual)
transparentTheme(trans=.4)
featurePlot(x = train_num[,3:16],
            y = train_num$SalePrice,
            plot = "scatter")


#Closer look: As sales price increases, we expect to see quality and condition improve and homes to be
#newer. OverallCond does not appear to hold this assumption, why?
theme <- trellis.par.get()
theme$plot.line$col = rgb(1,0,0,.7)
trellis.par.set(theme)
featurePlot(x = train_num[,c("OverallCond","OverallQual","YearBuilt")],
            y = train_num$SalePrice,
            plot = "scatter",
            layout = c(3,1),
            type = c("p","smooth"),
            span =.70
)

# Data Quality?
# Columns with NA values
df_na <- train[colSums(is.na(train))>0]
colnames(df_na)


# Check how many rows have NA and remove them?
row.has.na <- apply(train, 1, function(x){any(is.na(x))})
sum(row.has.na) # 1460! 
#Every row has an NA?
ct <- complete.cases(train)
sum(ct) # 0 = every row has atleast one NA

# Discuss various ways to handle NA
# Remove columns with NA
to.remove <- c(colnames(df_na))
'%ni%' <- Negate('%in%')
df <- subset(train, select= names(train) %ni% to.remove)

# check that df has removed all NA
row.has.na2 <- apply(df, 1, function(x){any(is.na(x))})
sum(row.has.na2)

# df has 1460 obs of 62 variables
str(df)

# NULL
# R Dataframes coerce NULL values to NA during the read process. This might occur is an instance
# where an analyst writes a SQL query to build a dataset and imports the dataset to R via one of 
# the read functions (i.e. read.csv). In R NULL is a reserved word that represents a NULL 
# object that is returned by undefined expressions and functions. 
# Therefore, handling NA values in a dataframe is sufficient for NULL cases as well

# NZV
# Near Zero variance features. Calculates frequency ratio and the percent of unique data points out
# of total data points. The idea behind checking for nzv feature is two fold:
# 
# 1) Zero variance attributes and near zero variance attributes can cause certain modeling techniques
# to produce a poor fit i.e. Regression modeling. This can be worked around by using non-parametric
# techniques i.e. Regression Trees
#
# 2) When using sampling techniques to improve the generalization of model performance,
# having nera zero variance attributes may result in sub samples that produce zero variance features
# i.e. When using k-fold cross validation, a sub sample with a zero variance feature could
# negatively influence model performance

nzv <- nearZeroVar(df, saveMetrics = TRUE)
nzv[is.element(nzv$nzv, TRUE),]

# Highly correlated attributes?
#cor
res <- cor(df)
round(res,2)

#correlation with pearson coeff and p value
res2 <- rcorr(as.matrix(df), type = "pearson")
cor_mat <- flattenCorrMatrix(res2$r,res2$P)

# Corrplot: Corrplot confirms bias that we may already have - SalePrice is highly correlated with
# attributes such as OverallQual, OverallCond, YearBuilt, and various Square footage metrics.
# It's worth noting that the pearson corellation coefficient is concerned with linear association
# of two variables. A low coefficient does not rule out other non linear relationships. 
# Also, since the pearson coeff essentailly uses a line of best fit, the coefficient is 
# sensitive to outliers.
corrplot(res)