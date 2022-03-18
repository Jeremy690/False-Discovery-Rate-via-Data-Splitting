### calculate fdp and power
fdp_power <- function(selected_index, signal_index){
  num_selected <- length(selected_index)
  tp <- length(intersect(selected_index, signal_index))
  fp <- num_selected - tp
  fdp <- fp / max(num_selected, 1)
  power <- tp / length(signal_index)
  return(list(fdp = fdp, power = power))
}