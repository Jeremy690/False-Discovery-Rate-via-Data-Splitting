### High dimension linear model (the effect of the number of splits in MDS)
rm(list = ls())
library(MASS)
library(glmnet)
library(mvtnorm)
library(breadcrumbs)

# Set working directory to `figure4` folder, e.g., 
# > setwd("~/code/simulation/figure4")

source_directory('../../functions/linear/')
# replicate index
replicate <- as.integer(Sys.getenv('SLURM_ARRAY_TASK_ID'))
set.seed(replicate)

### algorithmic settings
n <- 500
p <- 500
p0 <- 50
q <- 0.1
rho <- 0.8
delta <- 3
num_split <- as.numeric(Sys.getenv("att"))

### toeplitz correlation
covariance <- toeplitz(seq(rho, 0, length.out = p/10))
covariance <- bdiag(rep(list(covariance), 10))
diag(covariance) <- 1

### randomly locate the signals
signal_index <- sample(c(1:p), size = p0, replace = F)

### generate data
data <- generate_data()
X <- data$X; y <- data$y


### DS and MDS
DS_result <- DS(X, y, num_split, q)

### save data
data_save <- list(DS_fdr  = DS_result$DS_fdr,  DS_power  = DS_result$DS_power,
                  MDS_fdr = DS_result$MDS_fdr, MDS_power = DS_result$MDS_power)
save(data_save, file = paste("result_right/num_split_", num_split, "_replicate_", replicate, ".RData", sep = ""))





