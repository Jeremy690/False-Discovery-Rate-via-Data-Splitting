### BHq and BYq based on pairwise partial correlation test
BHq <- function(data, q){
  n <- dim(data)[1]
  p <- dim(data)[2]
  
  ### get pvalues
  pvalues <- NULL
  for(i in 2:p){
    for(j in 1:(i-1)){
      pvalues = suppressWarnings(c(pvalues, pcor.test(data[, i], data[, j], data[, -c(i,j)])$p.value))
    }
  }
  
  ### selected_edge
  sorted_pvalues <- sort(pvalues, decreasing = F, index.return = T)
  cutoff <- max(which(sorted_pvalues$x <= (1:(p*(p-1)/2))*q / (p*(p-1)/2)))
  selected_edge <- sorted_pvalues$ix[1:cutoff]
 
  ### calculate fdp and power
  true_edge_set <- c(NULL)
  edge_index <- 0
  for(i in 2:p){
    for(j in 1:(i-1)){
      edge_index <- edge_index + 1
      if(precision[j, i] != 0){
        true_edge_set <- c(true_edge_set, edge_index)
      }
    }
  }
  tp <- length(intersect(true_edge_set, selected_edge))
  fp <- length(selected_edge) - tp
  fdp <- fp/(tp + fp)
  power <- tp/length(true_edge_set)
  
  return(list(fdp = fdp, power = power))
}
