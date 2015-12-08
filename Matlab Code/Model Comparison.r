##### linear model for model comparison
setwd("/Users/sunnieshang/Documents/Duke Study/Research/KN_1/Matlab Code")
rm(list=ls())
D <- read.csv(file="FinalData.csv", head=F, sep=",")
colnames(D) <- c("Y","carrier_id","route","route_carrier_id","month","num_leg",
                    paste("dev", 1:9),paste("dur", 1:8),paste("weight", 1:6))
D$carrier_id <- factor(D$carrier_id)
D$route <- factor(D$route)
D$route_carrier_id <- factor(D$route_carrier_id)
D$month <- factor(D$month)
D$num_leg <- factor(D$num_leg)
lm_model = lm(Y ~ ., data = D)
summary(lm_model)
# mean square error
mse <- mean(lm_model$residuals^2)
# root mean square error
rmse <- sqrt(mse)
# mean absolute error
mae <- mean(abs(lm_model$residuals))
y_hat <- predict(lm_model)

##### Generalized Additive Model
## TODO: Need to use the original predictors 
## thus find the correct smooth function using lo or s
library("gam")
gam_model <- gam(Y ~ s(weight 1) + ., data = D, trace = T)
summary(gam_model)
# plot(gam_model)
predict(gam_model)
gam_mse = mean(gam_model$residuals^2)
gam_rmse <- sqrt(gam_mse)
gam_mae <-  mean(abs(gam_model$residuals))

## Gaussian mixture model

save.image(file = "R_Model_Comparison.RData")
