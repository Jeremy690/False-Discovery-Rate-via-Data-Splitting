### select the relevant features using mirror statistics
analys <- function(mm, ww, q){
  ### mm: mirror statistics
  ### ww: absolute value of mirror statistics
  ### q:  FDR control level
  cutoff_set <- max(ww)
  for(t in ww){
    ps <- length(mm[mm > t])
    ng <- length(na.omit(mm[mm < -t]))
    rto <- (ng + 1)/max(ps, 1)
    if(rto <= q){
      cutoff_set <- c(cutoff_set, t)
    }
  }
  cutoff <- min(cutoff_set)
  selected_index <- which(mm > cutoff)
  
  return(selected_index)
}
