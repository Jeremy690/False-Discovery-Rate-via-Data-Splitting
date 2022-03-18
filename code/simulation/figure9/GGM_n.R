### FDR control for Gaussian graphical model
rm(list = ls())
library(mvtnorm)
library(glmnet)
library(SILGGM)
library(ppcor)
library(breadcrumbs)

# Set working directory to `figure9` folder, e.g., 
# > setwd("~/code/simulation/figure9")

source_directory('../../functions/graphical_model/')

### replicate index
replicate <- as.integer(Sys.getenv('SLURM_ARRAY_TASK_ID'))
set.seed(replicate)

### algorithmic setting
n <- as.numeric(Sys.getenv("att"))   
p <- 100
q <- 0.2
num_split <- 50
precision <- matrix(0, nrow = p, ncol = p)
edges_set <- matrix(0, nrow = p, ncol = p)


### block diagonal graph
block_size <- 25
num_blocks <- p/block_size
for(iter in 1:num_blocks){
  for(i in 1:block_size){
    for(j in i:block_size){
      row_index <- (iter - 1)*block_size + i
      col_index <- (iter - 1)*block_size + j
      if(row_index == col_index){
        precision[row_index, col_index] <- 1
      }else{
        precision[row_index, col_index] <- runif(1, min = 0.4, max = 0.8) * sample(c(-1, 1), size = 1)
        precision[col_index, row_index] <- precision[row_index, col_index]
        edges_set[row_index, col_index] <- 1
        edges_set[col_index, row_index] <- 1
      }
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
save(data_save, file = paste("result_left/n_", n, 
                             "_replicate_", replicate, ".RData", sep = ""))

