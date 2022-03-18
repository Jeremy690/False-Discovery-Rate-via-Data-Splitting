### data-splitting methods (DS and MDS)
DS3 <- function(X, y, num_split, q){
  n <- dim(X)[1]; p <- dim(X)[2]
  inclusion_rate <- matrix(0, nrow = num_split, ncol = p)
  fdp <- rep(0, num_split)
  power <- rep(0, num_split)
  num_select <- rep(0, num_split)
  
  for(iter in 1:num_split){
    ### randomly split the data
    sample_index1 <- sample(x = c(1:n), size = 0.5 * n, replace = F)
    sample_index2 <- setdiff(c(1:n), sample_index1)
    
    ### get the penalty lambda for Lasso
    cvfit <- cv.glmnet(X[sample_index1, ], y[sample_index1], type.measure = "mse", nfolds = 10)
    lambda <- cvfit$lambda.1se/sqrt(2)
    
    ### run Lasso on the first half of the data
    beta1 <- as.vector(glmnet(X[sample_index1, ], y[sample_index1], family = "gaussian", alpha = 1, lambda = lambda)$beta)
    nonzero_index <- which(beta1 != 0)
    
    ### run OLS on the second half of the data, restricted on the selected features
    beta2 <- rep(0, p)
    beta2[nonzero_index] <- as.vector(lm(y[sample_index2] ~ X[sample_index2, nonzero_index] - 1)$coeff)
    
    ### calculate the mirror statistics
    M <- sign(beta1 * beta2) * (abs(beta1) + abs(beta2))
    selected_index <- analys(M, abs(M), q)
    
    ### number of selected variables
    num_select[iter] <- length(selected_index)
    inclusion_rate[iter, selected_index] <- 1/num_select[iter]
    
    ### calculate fdp and power
    result <- fdp_power(selected_index, signal_index)
    fdp[iter] <- result$fdp
    power[iter] <- result$power
  }
  
  ### single data-splitting (DS) result
  DS_fdr <- fdp[1]
  DS_power <- power[1]
  
  ### multiple data-splitting (MDS) result
  inclusion_rate <- apply(inclusion_rate, 2, mean)
  
  ### rank the features by the empirical inclusion rate
  feature_rank <- order(inclusion_rate)
  feature_rank <- setdiff(feature_rank, which(inclusion_rate == 0))
  null_feature <- numeric()
  
  ### backtracking 
  for(feature_index in 1:length(feature_rank)){
    if(sum(inclusion_rate[feature_rank[1:feature_index]]) > q){
      break
    }else{
      null_feature <- c(null_feature, feature_rank[feature_index])
    }
  }
  selected_index <- setdiff(feature_rank, null_feature)
  
  ### calculate fdp and power
  result <- fdp_power(selected_index, signal_index)
  MDS_fdr <- result$fdp
  MDS_power <- result$power
  
  return(list(DS_fdr = DS_fdr, DS_power = DS_power, MDS_fdr = MDS_fdr, MDS_power = MDS_power))
}