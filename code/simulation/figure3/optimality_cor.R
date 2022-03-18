rm(list = ls())
library(MASS)
library(glmnet)
library(mvtnorm)
library(breadcrumbs)

# Set working directory to `figure3` folder, e.g., 
# > setwd("~/code/simulation/figure3")

source_directory('../../functions/linear/')
source('DS1.R')
source('DS2.R')
source('DS3.R')

# replicate index
replicate <- as.integer(Sys.getenv('SLURM_ARRAY_TASK_ID'))
set.seed(replicate)

### algorithmic settings
n <- 500
p = 500
p0 <- 50
q <- 0.1
rho <- as.numeric(Sys.getenv("att"))
delta <- 5
num_split <- 50

### constant correlation
covariance <- toeplitz(seq(rho, 0, length.out = p/10))
covariance <- bdiag(rep(list(covariance), 10))
diag(covariance) <- 1

### randomly locate the signals
signal_index <- sample(c(1:p), size = p0, replace = F)

### generate data
data <- generate_data()
X <- data$X; y <- data$y


### DS and MDS
DS1_result <- DS1(X,y, num_split, q)
DS2_result <- DS2(X,y, num_split, q)
DS3_result <- DS3(X,y, num_split, q)

### save results
data_save <- list(DS1_fdr = DS1_result$DS_fdr, DS1_power = DS1_result$DS_power, 
                  DS2_fdr = DS2_result$DS_fdr, DS2_power = DS2_result$DS_power, 
                  DS3_fdr = DS3_result$DS_fdr, DS3_power = DS3_result$DS_power,
                  MDS1_fdr = DS1_result$MDS_fdr, MDS1_power = DS1_result$MDS_power,
                  MDS2_fdr = DS2_result$MDS_fdr, MDS2_power = DS2_result$MDS_power,
                  MDS3_fdr = DS3_result$MDS_fdr, MDS3_power = DS3_result$MDS_power)
save(data_save, file = paste("result_left/rho_", rho, "_replicate_", replicate, ".RData", sep = ""))


