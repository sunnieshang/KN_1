# linear model for model comparison
setwd("/Users/sunnieshang/Dropbox/Research/KN_1/Matlab Code")
rm(list=ls())
data <- read.csv(file="PSBP_Whole.csv", head=TRUE, sep=",")
n <- cbind(max(data[,2]),max(data[,3]),max(data[,4]),max(data[,5]),max(data[,6]),max(data[,7]))

forJags <- list(delay_1410=data$delay_1410,
                carrier_id=data$carrier_id,
                route=data$route,
                route_carrier_id=data$route_carrier_id,
                month=data$month,
                carrier_leg2=data$carrier_leg2,
                carrier_leg3=data$carrier_leg3,
                pos_1280=data$pos_1280,
                neg_1280=data$neg_1280,
                plan_dur=data$plan_dur,
                log_weight=data$log_weight,
                log_pieces=data$log_pieces
                )

# inits <- list(list(mu=c(0,0,0),alpha=c(0,0,0,0,0),tau=c(1,1,1,1,1,1,1),
#                     .RNG.seed=1234,
#                     .RNG.name="base::Mersenne-Twister"),
#                list(mu=c(10,10,10),alpha=c(10,10,10,10,0),tau=c(10,1,10,1,10,1,1),
#                     .RNG.seed=9999,
#                     .RNG.name="base::Mersenne-Twister"))

inits <- list(list(mu=c(0,0,0),alpha=c(0,0,0,0,0),tau=c(1,1,1,1,1,1,1),
                    .RNG.seed=1234,
                    .RNG.name="base::Mersenne-Twister"))

library(rjags)
foo <- jags.model(file="linear.bug",
                  n.chains = 1,
                  inits=inits,
                  data=forJags)

out <-coda.samples(foo,
                   n.iter=10e3,
                   thin=1,
                   variable.names=c("mu","tau","alpha","A","R","AR","M","L2","L3"))

geweke.diag(out)
heidel.diag(out)
raftery.diag(out)

library(mcmcplots)
mcmcplot(out, dir=getwd())

denplot(out)
denplot(out, collapse=T)
caterplot(out, c("alpha", "mu"), val.lim=c(-1,6))
abline(v=0, lty=2)


