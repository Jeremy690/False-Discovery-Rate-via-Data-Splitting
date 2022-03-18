rm(list = ls())
library(mvtnorm)
library(MASS)

# Set working directory to `figure2` folder, e.g., 
# > setwd("~/code/simulation/figure2/")


#### Data splitting for Gaussian mean problem
nob <- as.numeric(Sys.getenv("att"))
nsp <- 10 * nob
replicate <- as.integer(Sys.getenv('SLURM_ARRAY_TASK_ID'))
set.seed(replicate)

### rank
p1 <- p2 <- 0

### algorithmic setting
np <- 800; s0 <- trunc(np*0.2);
mu <- c(rnorm(s0)*0.5, rep(0, np - s0))
mu1 <- abs(qnorm(0.01)/sqrt(nob))
mu2 <- mu1 - 1/nob

### generate X1 and X2 conditioning on mu1 and mu2
Sigma = diag(1, nob - 1) - 1/nob*rep(1, nob - 1)%o%rep(1, nob - 1)
X1 = numeric(nob)
X2 = numeric(nob)
X1[-1] = mvrnorm(1, mu = rep(mu1, nob - 1), Sigma = Sigma)
X2[-1] = mvrnorm(1, mu = rep(mu2, nob - 1), Sigma = Sigma)
X1[1] = mu1*nob - sum(X1[-1])
X2[1] = mu2*nob - sum(X2[-1])
xob = matrix(rnorm(np*nob), ncol = np) + outer(rep(1, nob), mu)
xob[,1:2] = cbind(X1, X2)

#### calculate mirror statistics
s1 = sample(c(1:nob), nob/2); s2 = setdiff(c(1:nob), s1)
xs1 = colMeans(xob[s1,]); xs2 = colMeans(xob[s2,])
mstat = abs(xs1 + xs2) - abs(xs1 - xs2)
p1 = p1 + (mstat[1] >= mstat[2])

#### calculate inclusion rate
inclurate = rep(0, nsp)%o%rep(0, np)
for(j in 1:nsp){
  s1 <- sample(c(1:nob), nob/2); s2 <- setdiff(c(1:nob), s1)
  xs1 <- colMeans(xob[s1,]); xs2 <- colMeans(xob[s2,])
  mstat <- abs(xs1 + xs2) - abs(xs1 - xs2)
  sm <- sort(abs(mstat), decreasing = T)
  for(i in 2:np){
    t1 <- sm[i]
    r1 <- sum(mstat < -t1)/sum(mstat > t1)
    if(r1 <= 0.1) cut1 <- t1
  }
  sel2 = which(mstat > cut1)
  inclurate[j,sel2] = inclurate[j, sel2] + 1/length(sel2)
}
inclusionrate = colMeans(inclurate)
p2 = p2 + (inclusionrate[1] >= inclusionrate[2])

#### save data
data_save = list(DS_rank = p1, MDS_rank = p2)
save(data_save, file = paste("result_left/n_", nob , "_replicate_", replicate, ".RData", sep = ""))

