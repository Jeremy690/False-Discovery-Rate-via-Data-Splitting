# GWAS design for high dimension linear model
rm(list = ls())
library(MASS)
library(glmnet)
library(knockoff)
library(mvtnorm)
library(hdi)
library(breadcrumbs)

# Set working directory to `figure7` folder, e.g., 
# > setwd("~/code/simulation/figure7")

source_directory('../../functions/linear/')

### algorithmic settings
n <- 800
p <- 1200
p0 <- 70
q <- 0.1
delta <- as.numeric(Sys.getenv("att"))

### replicate index
replicate <- as.integer(Sys.getenv('SLURM_ARRAY_TASK_ID'))
set.seed(replicate)

### read data 
data <- t(read.table("../data.txt"))
freq <- colSums(data != 0)/nrow(data)
remove_index <- which(freq < 0.1)
X <- data[, -remove_index]
std <- apply(X, 2, sd)
gene_index <- order(std, decreasing = T)
X <- X[, gene_index[1:p]]
X <- X[1:n, ]
X <- X[, !duplicated(t(X))]
X <- scale(X)

### randomly generate the true beta
beta_star <- rep(0, p)
signal_index <- sample(c(1:p), size = p0, replace = F)
beta_star[signal_index] <- rnorm(p0, mean = 0, sd = delta*sqrt(1/n))

### generate y
y <- X%*%beta_star + rnorm(n, mean = 0, sd = 1)

### number of splits
num_split <- 50

###
DS_result <- DS(X,y, num_split, q)
knockoff_result <- knockoff(X, y, q)
BH_result <- MBHq(X, y, q, num_split)

### save data
data_save <- list(DS_fdp  = DS_result$DS_fdp,  DS_power  = DS_result$DS_power,
                  MDS_fdp = DS_result$MDS_fdp, MDS_power = DS_result$MDS_power,
                  knockoff_fdp = knockoff_result$fdp, knockoff_power = knockoff_result$power,
                  BH_fdp = BH_result$fdp, BH_power = BH_result$power)
save(data_save, file = paste("result_right/signal_", delta, "_replicate_", replicate, ".RData", sep = ""))


