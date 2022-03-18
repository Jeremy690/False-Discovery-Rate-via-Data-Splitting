generate_data <- function(){
  ### randomly generate the true beta
  beta_star <- rep(0, p)
  beta_star[signal_index] <- rnorm(p0, mean = 0, sd = delta*sqrt(log(p)/n))
  
  ### generate the design matrix X and response y
  #X1 <- mvrnorm(n/2, mu = rep(0.5, p),  Sigma = covariance)
  #X2 <- mvrnorm(n/2, mu = rep(-0.5, p), Sigma = covariance)
  #X  <- rbind(X1, X2)
  X = mvrnorm(n, mu = rep(0, p),  Sigma = covariance)
  y <- X%*%beta_star + rnorm(n, mean = 0, sd = 1)
  
  return(list(X = X, y = y))
}
