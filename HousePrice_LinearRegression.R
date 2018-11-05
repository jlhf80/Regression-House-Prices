##############################################
# James Henson
# House Prices: Advanced Regression Techniques
# filename: HousePrice_LinearRegression.R
#
# Exploring linear regression techniques with 
# Zillow dataset from Kaggle Competition
#
##############################################

# clear
rm(list=ls())

# load
library(MASS)
library(glmnet)
library(dplyr)
library(data.table)
library(dummies)


# Import data
train <- read.csv( "C:/Users/jlh_5/OneDrive/Documents/zillowHousePrices/Zillow-House-Prices/train.csv")
test <- read.csv( "C:/Users/jlh_5/OneDrive/Documents/zillowHousePrices/Zillow-House-Prices/test.csv")

# Combine datasets before preprocessing to ensure same columns during prediction 
train_df <- train
test_df <- test
train_df["dataset"]<- c("train")
test_df["SalePrice"]<- 0

test_df["dataset"]<- c("test")

df <- rbind(train_df,test_df)

# dummy data
df <- dummy.data.frame(df)

# 3 attributes are int and have nulls
colnames(df[colSums(is.na(df))>0])
str(df[colSums(is.na(df))>0])

# replace with zero
df[is.na(df)]<-0
str(df[colSums(is.na(df))>0])

# Seperate test and train df
train <- df[df$datasettest %in% 0,]
test <- df[df$datasettest %in% 1,]


# remove added columns for test and train, sale price on test set
drop <- c("datasettest","datasettrain")
drop_sale <- c("SalePrice")

train <- train[, !(names(train) %in% drop)]
test <- test[, !(names(test) %in% drop)]
test <- test[, !(names(test) %in% drop_sale)]

# assignment to re use code
df <- train

# modeling - linear, step, elastic
# Full model - really high adj r^2 .9192, Outliers appear in cooks distance plot. Tail behavior in
# QQ plot is interesting
mod <- lm(SalePrice ~ ., data=df)
summary(mod)
layout(matrix(c(1,2,3,4),2,2))
plot(mod)

# Full model overfits data 
# Discuss overfitting, introduce stepwise, lasso, ridge, elastic

# Stepwise
step_mod <- stepAIC(mod, direction = "backward")
step_mod$anova

step_both <- stepAIC(mod, direction = "back")

summary(step_both) # r^2 .9238 coef: 123

# Model from "both" stepwise selection  produced adj r^2 of .9192
step_lm <- lm(formula = SalePrice ~ Id + MSSubClass + `MSZoningC (all)` + MSZoningFV + 
                MSZoningRH + MSZoningRL + MSZoningRM + LotFrontage + LotArea + 
                StreetGrvl + StreetPave + AlleyGrvl + AlleyPave + AlleyNA + 
                LotShapeIR1 + LotShapeIR2 + LotShapeIR3 + LotShapeReg + LandContourBnk + 
                LandContourHLS + LandContourLow + LandContourLvl + UtilitiesAllPub + 
                UtilitiesNoSeWa + LotConfigCorner + LotConfigCulDSac + LotConfigFR2 + 
                LotConfigFR3 + LotConfigInside + LandSlopeGtl + LandSlopeMod + 
                LandSlopeSev + NeighborhoodBlmngtn + NeighborhoodBlueste + 
                NeighborhoodBrDale + NeighborhoodBrkSide + NeighborhoodClearCr + 
                NeighborhoodCollgCr + NeighborhoodCrawfor + NeighborhoodEdwards + 
                NeighborhoodGilbert + NeighborhoodIDOTRR + NeighborhoodMeadowV + 
                NeighborhoodMitchel + NeighborhoodNAmes + NeighborhoodNoRidge + 
                NeighborhoodNPkVill + NeighborhoodNridgHt + NeighborhoodNWAmes + 
                NeighborhoodOldTown + NeighborhoodSawyer + NeighborhoodSawyerW + 
                NeighborhoodSomerst + NeighborhoodStoneBr + NeighborhoodSWISU + 
                NeighborhoodTimber + NeighborhoodVeenker + Condition1Artery + 
                Condition1Feedr + Condition1Norm + Condition1PosA + Condition1PosN + 
                Condition1RRAe + Condition1RRAn + Condition1RRNe + Condition1RRNn + 
                Condition2Artery + Condition2Feedr + Condition2Norm + Condition2PosA + 
                Condition2PosN + Condition2RRAe + Condition2RRAn + Condition2RRNn + 
                BldgType1Fam + BldgType2fmCon + BldgTypeDuplex + BldgTypeTwnhs + 
                BldgTypeTwnhsE + HouseStyle1.5Fin + HouseStyle1.5Unf + HouseStyle1Story + 
                HouseStyle2.5Fin + HouseStyle2.5Unf + HouseStyle2Story + 
                HouseStyleSFoyer + HouseStyleSLvl + OverallQual + OverallCond + 
                YearBuilt + YearRemodAdd + RoofStyleFlat + RoofStyleGable + 
                RoofStyleGambrel + RoofStyleHip + RoofStyleMansard + RoofStyleShed + 
                RoofMatlClyTile + RoofMatlCompShg + RoofMatlMembran + RoofMatlMetal + 
                RoofMatlRoll + `RoofMatlTar&Grv` + RoofMatlWdShake + RoofMatlWdShngl + 
                Exterior1stAsbShng + Exterior1stAsphShn + Exterior1stBrkComm + 
                Exterior1stBrkFace + Exterior1stCBlock + Exterior1stCemntBd + 
                Exterior1stHdBoard + Exterior1stImStucc + Exterior1stMetalSd + 
                Exterior1stPlywood + Exterior1stStone + Exterior1stStucco + 
                Exterior1stVinylSd + `Exterior1stWd Sdng` + Exterior1stWdShing + 
                Exterior2ndAsbShng + Exterior2ndAsphShn + `Exterior2ndBrk Cmn` + 
                Exterior2ndBrkFace + Exterior2ndCBlock + Exterior2ndCmentBd + 
                Exterior2ndHdBoard + Exterior2ndImStucc + Exterior2ndMetalSd + 
                Exterior2ndOther + Exterior2ndPlywood + Exterior2ndStone + 
                Exterior2ndStucco + Exterior2ndVinylSd + `Exterior2ndWd Sdng` + 
                `Exterior2ndWd Shng` + MasVnrTypeBrkCmn + MasVnrTypeBrkFace + 
                MasVnrTypeNone + MasVnrTypeStone + MasVnrTypeNA + MasVnrArea + 
                ExterQualEx + ExterQualFa + ExterQualGd + ExterQualTA + ExterCondEx + 
                ExterCondFa + ExterCondGd + ExterCondPo + ExterCondTA + FoundationBrkTil + 
                FoundationCBlock + FoundationPConc + FoundationSlab + FoundationStone + 
                FoundationWood + BsmtQualEx + BsmtQualFa + BsmtQualGd + BsmtQualTA + 
                BsmtQualNA + BsmtCondFa + BsmtCondGd + BsmtCondPo + BsmtCondTA + 
                BsmtCondNA + BsmtExposureAv + BsmtExposureGd + BsmtExposureMn + 
                BsmtExposureNo + BsmtExposureNA + BsmtFinType1ALQ + BsmtFinType1BLQ + 
                BsmtFinType1GLQ + BsmtFinType1LwQ + BsmtFinType1Rec + BsmtFinType1Unf + 
                BsmtFinType1NA + BsmtFinSF1 + BsmtFinType2ALQ + BsmtFinType2BLQ + 
                BsmtFinType2GLQ + BsmtFinType2LwQ + BsmtFinType2Rec + BsmtFinType2Unf + 
                BsmtFinType2NA + BsmtFinSF2 + BsmtUnfSF + TotalBsmtSF + HeatingFloor + 
                HeatingGasA + HeatingGasW + HeatingGrav + HeatingOthW + HeatingWall + 
                HeatingQCEx + HeatingQCFa + HeatingQCGd + HeatingQCPo + HeatingQCTA + 
                CentralAirN + CentralAirY + ElectricalFuseA + ElectricalFuseF + 
                ElectricalFuseP + ElectricalMix + ElectricalSBrkr + ElectricalNA + 
                X1stFlrSF + X2ndFlrSF + LowQualFinSF + GrLivArea + BsmtFullBath + 
                BsmtHalfBath + FullBath + HalfBath + BedroomAbvGr + KitchenAbvGr + 
                KitchenQualEx + KitchenQualFa + KitchenQualGd + KitchenQualTA + 
                TotRmsAbvGrd + FunctionalMaj1 + FunctionalMaj2 + FunctionalMin1 + 
                FunctionalMin2 + FunctionalMod + FunctionalSev + FunctionalTyp + 
                Fireplaces + FireplaceQuEx + FireplaceQuFa + FireplaceQuGd + 
                FireplaceQuPo + FireplaceQuTA + FireplaceQuNA + GarageType2Types + 
                GarageTypeAttchd + GarageTypeBasment + GarageTypeBuiltIn + 
                GarageTypeCarPort + GarageTypeDetchd + GarageTypeNA + GarageYrBlt + 
                GarageFinishFin + GarageFinishRFn + GarageFinishUnf + GarageFinishNA + 
                GarageCars + GarageArea + GarageQualEx + GarageQualFa + GarageQualGd + 
                GarageQualPo + GarageQualTA + GarageQualNA + GarageCondEx + 
                GarageCondFa + GarageCondGd + GarageCondPo + GarageCondTA + 
                GarageCondNA + PavedDriveN + PavedDriveP + PavedDriveY + 
                WoodDeckSF + OpenPorchSF + EnclosedPorch + X3SsnPorch + ScreenPorch + 
                PoolArea + PoolQCEx + PoolQCFa + PoolQCGd + PoolQCNA + FenceGdPrv + 
                FenceGdWo + FenceMnPrv + FenceMnWw + FenceNA + MiscFeatureGar2 + 
                MiscFeatureOthr + MiscFeatureShed + MiscFeatureTenC + MiscFeatureNA + 
                MiscVal + MoSold + YrSold + SaleTypeCOD + SaleTypeCon + SaleTypeConLD + 
                SaleTypeConLI + SaleTypeConLw + SaleTypeCWD + SaleTypeNew + 
                SaleTypeOth + SaleTypeWD + SaleConditionAbnorml + SaleConditionAdjLand + 
                SaleConditionAlloca + SaleConditionFamily + SaleConditionNormal + 
                SaleConditionPartial, data = df)
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
dim(coeff_mod10) # 21 coefficients
dim(coeff_mod0) # 301 coeff
dim(coeff_mod5) # 29
cmat0 <- coef(mod0, s=mod0$lambda.1se)[,1]
cmat0 <- as.data.frame(cmat0)
coeff_mod0 <- subset(cmat0, cmat0 != 0)

cmat5 <- coef(mod5, s=mod5$lambda.1se)[,1]
cmat5 <- as.data.frame(cmat5)
coeff_mod5 <- subset(cmat5, cmat5 != 0)

dim(coeff_mod10) # 21 coefficients
dim(coeff_mod0) # 301 coeff
dim(coeff_mod5) # 29

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
moddf <- c("Lasso","Ridge","ElasticNet")
lamda1se <- c(mod10$lambda.1se, mod0$lambda.1se, mod5$lambda.1se)
lamdamin <- c(mod10$lambda.min, mod0$lambda.min, mod5$lambda.min)
cvmMin <- c(min(mod10$cvm), min(mod0$cvm), min(mod5$cvm))
cvsdMin <- c(min(mod10$cvsd), min(mod0$cvsd), min(mod5$cvsd))
df_eval <- data.frame(moddf,lamda1se, lamdamin, cvmMin, cvsdMin)
df_eval

# Compare atrributes from linear regression, stepwise, lasso, and ridge regression models
# Discuss inference vs prediction

# format test dataset for model usage
test_eval <- dummy.data.frame(test)
colnames(test_eval[colSums(is.na(test_eval))>0])
test_eval[is.na(test_eval)]<-0
mew <- predict(mod,test_eval)

# full model - 0.19622 kaggle
fin_lm <- predict(mod, test)
fin_lm <- as.data.frame(fin_lm)
fin_lm <- cbind(test$Id, fin_lm$fin_lm)
fin_lm <- as.data.frame(fin_lm)
colnames(fin_lm) <- c("Id","SalePrice")
#write.csv(fin_lm, "full_lm.csv", row.names = FALSE)

# backward stepwise - 0.54674 kaggle
fin_step <- predict(step_mod, test)
fin_step <- as.data.frame(fin_step)
fin_step <- cbind(test$Id, fin_step$fin_step)
fin_step <- as.data.frame(fin_step)
colnames(fin_step) <- c("Id","SalePrice")
#write.csv(fin_step, "fin_step.csv", row.names = FALSE)

# both stepwise - 0.20231 kaggle
fin_both <- predict(step_both, test)
fin_both <- as.data.frame(fin_both)
fin_both <- cbind(test$Id, fin_both$fin_both)
fin_both <- as.data.frame(fin_both)
colnames(fin_both) <- c("Id","SalePrice")
#write.csv(fin_both, "fin_both.csv", row.names = FALSE)

# lasso - 0.16560 kaggle
newx <- as.matrix.data.frame(test)
fin_mod10 <- predict.cv.glmnet(mod10, newx=newx, s=mod10$lambda.1se)

fin_mod10 <- as.data.frame(fin_mod10)
fin_mod10 <- cbind(test$Id, fin_mod10$`1`)
fin_mod10 <- as.data.frame(fin_mod10)
colnames(fin_mod10) <- c("Id","SalePrice")
#write.csv(fin_mod10, "lasso_mod10.csv", row.names = FALSE)

# ridge - 0.16154 kaggle
fin_mod0 <- predict.cv.glmnet(mod0, newx=newx, s=mod0$lambda.1se)

fin_mod0 <- as.data.frame(fin_mod0)
fin_mod0 <- cbind(test$Id, fin_mod0$`1`)
fin_mod10 <- as.data.frame(fin_mod10)
colnames(fin_mod0) <- c("Id","SalePrice")
#write.csv(fin_mod0, "ridge_mod0.csv", row.names = FALSE)

# enet - 0.16495 kaggle
fin_mod5 <- predict.cv.glmnet(mod5, newx=newx, s=mod5$lambda.1se)

fin_mod5 <- as.data.frame(fin_mod5)
fin_mod5 <- cbind(test$Id, fin_mod5$`1`)
fin_mod5 <- as.data.frame(fin_mod5)
colnames(fin_mod5) <- c("Id","SalePrice")
#write.csv(fin_mod5, "enet_mod5.csv", row.names = FALSE)