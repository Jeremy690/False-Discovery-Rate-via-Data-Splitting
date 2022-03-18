### calculate fdp and power
fdp_power <- function(selected_edge){
  num_false_discoveries <- 0
  num_selected_edge <- 0
  for(i in 1:(p - 1)){
    for(j in (i + 1):p){
      if(selected_edge[i, j] == 1 | selected_edge[j, i] == 1){
        num_selected_edge <- num_selected_edge + 1
        if(precision[i, j] == 0){
          num_false_discoveries <- num_false_discoveries + 1
        }
      }
    }
  }
  fdp <- num_false_discoveries/num_selected_edge
  power <- (num_selected_edge - num_false_discoveries)/sum(edges_set)*2
  
  return(list(fdp = fdp, power = power))
}
