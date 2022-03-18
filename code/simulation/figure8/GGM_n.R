### FDR control for Gaussian graphical model
rm(list = ls())
library(mvtnorm)
library(glmnet)
library(SILGGM)
library(ppcor)
library(breadcrumbs)

# Set working directory to `figure8` folder, e.g., 
# > setwd("~/code/simulation/figure8")

source_directory('../../functions/graphical_model/')

### replicate index
replicate <- as.integer(Sys.getenv('SLURM_ARRAY_TASK_ID'))
set.seed(replicate)

### algorithmic setting
n <- as.numeric(Sys.getenv("att"))   
p <- 100
rho <- 8    
a <- -0.6  
c <- 1.5
q <- 0.2
num_split <- 50
precision <- matrix(0, nrow = p, ncol = p)
edges_set <- matrix(0, nrow = p, ncol = p)

### banded graph
for(i in 1:p){
  for(j in 1:p){
    if(i == j){
      precision[i, j] <- 1
    }
    if(i != j & abs(i - j) <= rho){
      precision[i, j] <- sign(a)*abs(a)^(abs(i - j)/c)
      edges_set[i, j] <- 1
    }
  }
}

### the precision matrix should be positive definite
min_eigen <- min(eigen(precision)$values)
if(min_eigen < 0){diag(precision) <- diag(precision) + abs(min_eigen) + 0.005}

### generate samples
data <- rmvnorm(n, mean = rep(0, p), sigma = solve(precision))

### test out different methods
BHq_result <- BHq(data, q)
DS_result  <- DS(data, q, num_split)
GFC_result <- GFC(data, precision, q)

data_save <- list(DS_fdp  = DS_result$DS_fdp,  DS_power  = DS_result$DS_power,
                  MDS_fdp = DS_result$MDS_fdp, MDS_power = DS_result$MDS_power,
                  BHq_fdp = BHq_result$fdp, BHq_power = BHq_result$power,
                  GFC_fdp = GFC_result$fdp, GFC_power = GFC_result$power)
save(data_save, file = paste("result_upperleft/n_", n, 
                             "_replicate_", replicate, ".RData", sep = ""))

