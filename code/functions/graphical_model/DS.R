### nodewise data-splitting procedure
DS <- function(data, q, num_split){
  DS_selected_edge  <- matrix(0, nrow = p, ncol = p)
  MDS_selected_edge <- matrix(0, nrow = p, ncol = p)
  
  for(j in 1:p){
    ### response variable and design matrix
    y <- data[, j]
    X <- data[, -j]
    
    inclusion_rate <- matrix(0, nrow = num_split, ncol = p - 1)
    num_select <- rep(0, num_split)
    
    ### multiple data splits
    for(iter in 1:num_split){
      ### randomly split the data
      sample_index1 <- sample(x = c(1:n), size = 0.5 * n, replace = F)
      sample_index2 <- setdiff(c(1:n), sample_index1)
      
      ### get the penalty lambda for Lasso
      cvfit  <- cv.glmnet(X[sample_index1, ], y[sample_index1], type.measure = "mse", nfolds = 10)
      lambda <- cvfit$lambda.min
      
      ### run Lasso on the first half of the data
      beta1 <- as.vector(glmnet(X[sample_index1, ], y[sample_index1], family = "gaussian", alpha = 1, lambda = lambda)$beta)
      nonzero_index = which(beta1 != 0)
      
      ### run OLS on the second half of the data, restricted on the selected features
      if(length(nonzero_index) != 0){
        beta2 <- rep(0, p - 1)
        fit <- lm(y[sample_index2] ~ X[sample_index2, nonzero_index] - 1)
        beta2[nonzero_index] <- as.vector(fit$coeff)
      }
      
      ### calculate the mirror statistics
      M <- sign(beta1 * beta2) * (abs(beta1) + abs(beta2))
      selected_index <- analys(M, abs(M), q/2)
      
      ### the size of the selected neighborhood
      num_select[iter] <- length(selected_index)
      inclusion_rate[iter, selected_index] <- 1/num_select[iter]
    }
    
    ### single data-splitting result
    DS_selected_edge[j, -j] <- ifelse(inclusion_rate[1, ] > 0, 1, 0)
    
    ### multiple data-splitting result
    inclusion_rate <- apply(inclusion_rate, 2, mean)
    feature_rank <- order(inclusion_rate)
    feature_rank <- setdiff(feature_rank, which(inclusion_rate == 0))
    null_feature <- numeric()
    for(feature_index in 1:length(feature_rank)){
      if(sum(inclusion_rate[feature_rank[1:feature_index]]) > q/2){
        break
      }else{
        null_feature <- c(null_feature, feature_rank[feature_index])
      }
    }
    selected_index <- rep(0, p - 1)
    selected_index[setdiff(feature_rank, null_feature)] <- 1
    MDS_selected_edge[j, -j] <- selected_index
  }
  
  ### single data-splitting fdp and power
  fdp_power_result <- fdp_power(DS_selected_edge)
  DS_fdp <- fdp_power_result$fdp
  DS_power <- fdp_power_result$power
  
  ### multiple data-splitting fdp and power
  fdp_power_result <- fdp_power(MDS_selected_edge)
  MDS_fdp <- fdp_power_result$fdp
  MDS_power <- fdp_power_result$power
  
  return(list(DS_fdp = DS_fdp, DS_power = DS_power, MDS_fdp = MDS_fdp, MDS_power = MDS_power))
}

