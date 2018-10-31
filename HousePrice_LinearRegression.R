##############################################
# James Henson
# CIS 508: Data Mining I
# House Prices: Advanced Regression Techniques
# filename: HousePrice_LinearRegression.R
#
# The purpose of the assignment is to submit a prediction for house prices
# based on the provided data from the Kaggle Competition. Here, our submissions are
# evaluated on RMSE of the log of the predicted value and the log of the observed sales price.
#
##############################################

library(MASS)
library(glmnet)
library(dplyr)
library(data.table)

# clear
rm(list=ls())

# Import data
train <- read.csv( "C:/Users/jlh_5/OneDrive/Documents/zillowHousePrices/train.csv")
test <- read.csv( "C:/Users/jlh_5/OneDrive/Documents/zillowHousePrices/test.csv")

# Data processing
# Remove columns with NA
# Columns with NA values
df_na <- train[colSums(is.na(train))>0]
to.remove <- c(colnames(df_na))
'%ni%' <- Negate('%in%')
df <- subset(train, select= names(train) %ni% to.remove)



# modeling - linear, step, elastic
# Full model - really high adj r^2 .909, Outliers appear in cooks distance plot. Tail behavior in
# QQ plot is interesting
mod <- lm(SalePrice ~ ., data=df)
summary(mod)
layout(matrix(c(1,2,3,4),2,2))
plot(mod)

# Full model overfits data 
# Discuss overfitting, introduce stepwise, lasso, ridge, elastic

# Stepwise
step_mod <- stepAIC(mod, direction = "both")
step$anova

# Model from stepwise selection with "both" produced adj r^2 of .9085
step_lm <- lm(formula = SalePrice ~ MSZoning + LotArea + Street + LandContour + 
                LotConfig + LandSlope + Neighborhood + Condition1 + Condition2 + 
                BldgType + HouseStyle + OverallQual + OverallCond + YearBuilt + 
                YearRemodAdd + RoofStyle + RoofMatl + ExterQual + Foundation + 
                BsmtFinSF1 + BsmtFinSF2 + BsmtUnfSF + X1stFlrSF + X2ndFlrSF + 
                FullBath + BedroomAbvGr + KitchenAbvGr + KitchenQual + TotRmsAbvGrd + 
                Functional + Fireplaces + GarageCars + GarageArea + WoodDeckSF + 
                ScreenPorch + PoolArea + MoSold + SaleType, data = df)
summary(step_lm)
opar <- par(mfrow = c(2,2), oma = c(0, 0, 1.1, 0))
plot(step_lm)



# Lasso
# Use df2 to remove y from df and use as.matrix to create model matrices needed for glmnet
# Using as.matrix for a mixed data frame encodes number as a character -> causes error
df2 <- df[,!names(df) %in% c("SalePrice")]

y <- as.matrix(df$SalePrice)
x <- as.matrix(as.data.frame(lapply(df2, as.numeric)))

mod.lasso <- glmnet(x,y, family = "gaussian", alpha = 1)
mod.ridge <- glmnet(x,y, family = "gaussian", alpha = 0)
mod.enet <- glmnet(x,y, family = "gaussian", alpha = 0.5)

#loop through cv.glmnet to produce models with alpha between 0 and 1 w/ 10 fold cross validation
# default
for (i in 0:10){
  assign(paste("mod",i,sep = ""), cv.glmnet(x,y, type.measure = "mse", alpha = i/10,
                                            family = "gaussian"))
}

# evaluate lasso
par(mfrow=c(3,2))
plot(mod.lasso, xvar = "lambda")
plot(mod10, main = "LASSO")

plot(mod.ridge, xvar = "lambda")
plot(mod0, main = "Ridge")

plot(mod.enet, xvar = "lambda")
plot(mod5, main = "ElasticNet")

#coefficients
cmat10 <- coef(mod10,s=mod10$lambda.1se)[,1] # [,1] drops sparse matrix format
cmat10 <- as.data.frame(cmat10)
coeff_mod10 <- subset(cmat10, cmat10 != 0)
dim(coeff_mod10) # 12 coefficients

cmat0 <- coef(mod0, s=mod0$lambda.1se)[,1]
cmat0 <- as.data.frame(cmat0)
coeff_mod0 <- subset(cmat0, cmat0 != 0)
dim(coeff_mod0) # 62 coeff

cmat5 <- coef(mod5, s=mod5$lambda.1se)[,1]
cmat5 <- as.data.frame(cmat5)
coeff_mod5 <- subset(cmat5, cmat5 != 0)
dim(coeff_mod5) # 13

# LASSO coeff at lamdamin
cmat10_m <- coef(mod10,s=mod10$lambda.min)[,1] # [,1] drops sparse matrix format
cmat10_m <- as.data.frame(cmat10_m)
coeff_mod10_m <- subset(cmat10_m, cmat10_m != 0)
dim(coeff_mod10_m) # 27 coefficients

#inspect LASSO
# Note Ex = excellent, Gd = good, TA = Avg, Fa = Fair, Po = Poor
# Notice the interpretation of the linear model suggested by the LASSO is not neccesarily the
# most intuitive - or perhaps they are - any other than excellent ratings for exteriorqual
# and kitchenqual have negative coefficients
# QQ plot shows that distribution behavior is relatively normal other than in the extreme tails
# This is appears to be consistant with the story converyed by the residual plots
fit1 <- lm(SalePrice ~ OverallQual+YearBuilt+ExterQual+BsmtFinSF1
           +TotalBsmtSF+X1stFlrSF+GrLivArea+KitchenQual+Fireplaces
           +GarageCars+GarageArea, data = train)
summary(fit1)
anova(fit1)
opar <- par(mfrow = c(2,2), oma = c(0, 0, 1.1, 0))
plot(fit1)
par(opar)

# inspect LASSO and lamba.min
# r^2 is 0.86 compared to the LASSO at lambda.1se r^2 of .80
# At Lamba.min, the model appears to have a better fit. But since our goal here is to 
# avoid overfitting, it is suggested to utilize lambda.1se
fit2 <- lm(SalePrice ~ MSSubClass+LotArea+LotShape+BldgType+OverallQual+OverallCond+
             YearBuilt+YearRemodAdd+RoofStyle+RoofMatl+ExterQual+BsmtFinSF1+TotalBsmtSF+
             HeatingQC+X1stFlrSF+GrLivArea+BsmtFullBath+KitchenAbvGr+KitchenQual+
             TotRmsAbvGrd+Functional+Fireplaces+GarageCars+WoodDeckSF+ScreenPorch+
             SaleCondition, data=train)
summary(fit2)
anova(fit2)
plot(fit2)

# dataframe lambda readings. cvm = mean cross-validated error
# Although LASSO has a smaller CVM, the standard error of the CVM (cvsd) makes cvm of LASSO
# and Ridge comparable. However, the LASSO model select 12 coefficients compared to 62 in 
# Ridge model. Where parsimony is king, the simpler model may be the better choice.
mod <- c("Lasso","Ridge","ElasticNet")
lamda1se <- c(mod10$lambda.1se, mod0$lambda.1se, mod5$lambda.1se)
lamdamin <- c(mod10$lambda.min, mod0$lambda.min, mod5$lambda.min)
cvmMin <- c(min(mod10$cvm), min(mod0$cvm), min(mod5$cvm))
cvsdMin <- c(min(mod10$cvsd), min(mod0$cvsd), min(mod5$cvsd))
df_eval <- data.frame(mod,lamda1se, lamdamin, cvmMin, cvsdMin)
df_eval

# Compare atrributes from linear regression, stepwise, lasso, and ridge regression models
# Discuss inference vs prediction