### GFC-L and GFC-SL (Liu et al 2013)
GFC <- function(data, precision, q){
  fit <- SILGGM(data, method = 'GFC_L',  true_graph = precision, alpha = q)
  
  list(fdp = fit$FDR, power = fit$power)
}