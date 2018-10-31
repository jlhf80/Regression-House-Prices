---
title: "Linear Regression with Zillow House Prices"
output: github_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```

## Introduction

Zillow Group is a set of brands with a mission to "Build the largest, most trusted and vibrant home-related marketplace in the world". Within Zillow Group exists Zillow, a real estate and rental marketplace that seeks to empower consumers with data and knowledge throughout the home buying/renting lifecycle. Zillow's Zestimate is an estimated market value for an individual home that seeks to provide buyers and sellers with a viable starting point for home valuation.

## Kaggle - House Prices: Advanced Regression Techniques

In the form of an open Kaggle competition, Zillow has provided housing data 79 attributes for residentail homes in Ames, Iowa. The goal is to predict the final price of each home. Here, we will focus on the application of linear, stepwise, and penalized regression models. It is worth noting, in a professional environment, more time would be spent exploring the data and developing intuition.  

## Including Code

You can include R code in the document as follows:

```{r cars}
summary(cars)
```

## Including Plots

You can also embed plots, for example:

```{r pressure, echo=FALSE}
plot(pressure)
```

Note that the `echo = FALSE` parameter was added to the code chunk to prevent printing of the R code that generated the plot.
