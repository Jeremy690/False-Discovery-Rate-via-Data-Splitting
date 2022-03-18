rm(list = ls())
library(knockoff)

drug_class = 'PI' # Possible drug types are 'PI', 'NRTI', and 'NNRTI'. In the paper we restrict to PI and NRTI.

### Cleaning and Fetching the data
base_url = 'http://hivdb.stanford.edu/pages/published_analysis/genophenoPNAS2006'
gene_url = paste(base_url, 'DATA', paste0(drug_class, '_DATA.txt'), sep='/')
tsm_url = paste(base_url, 'MUTATIONLISTS', 'NP_TSM', drug_class, sep='/')

gene_df = read.delim(gene_url, na.string = c('NA', ''), stringsAsFactors = FALSE)
tsm_df = read.delim(tsm_url, header = FALSE, stringsAsFactors = FALSE)
names(tsm_df) = c('Position', 'Mutations')

### Removing the rows with error flags or nonstandard mutation codes.
grepl_rows <- function(pattern, df) {
  cell_matches = apply(df, c(1,2), function(x) grepl(pattern, x))
  apply(cell_matches, 1, all)
}

pos_start = which(names(gene_df) == 'P1')
pos_cols = seq.int(pos_start, ncol(gene_df))
valid_rows = grepl_rows('^(\\.|-|[A-Zid]+)$', gene_df[,pos_cols])
gene_df = gene_df[valid_rows,]

### Prepare the design matrix and response variable.
# Flatten a matrix to a vector with names from concatenating row/column names.
flatten_matrix <- function(M, sep='.') {
  x <- c(M)
  names(x) <- c(outer(rownames(M), colnames(M),
                      function(...) paste(..., sep=sep)))
  x
}

# Construct preliminary design matrix.
muts = c(LETTERS, 'i', 'd')
X = outer(muts, as.matrix(gene_df[,pos_cols]), Vectorize(grepl))
X = aperm(X, c(2,3,1))
dimnames(X)[[3]] <- muts
X = t(apply(X, 1, flatten_matrix))
mode(X) <- 'numeric'

# Remove any mutation/position pairs that never appear in the data.
X = X[,colSums(X) != 0]

# Extract response matrix.
Y = gene_df[,4:(pos_start-1)]


Split = function(X, y, q){
  n = nrow(X); p = ncol(X)
  num_split <- 50
  selected_index_multiple <- matrix(0, nrow = num_split, ncol = p)
  fdr_multiple <- rep(0, num_split)
  power_multiple <- rep(0, num_split)
  num_select <- rep(0, num_split)
  for(iter in 1:num_split){
    ### randomly split the data and estimate coefficient
    while(TRUE){
      sample_index1 <- sample(x = c(1:n), size = trunc(0.5 * n), replace = F)
      sample_index2 <- setdiff(c(1:n), sample_index1)
      cvfit = cv.glmnet(X[sample_index1, ], y[sample_index1], nfolds = 10)
      beta1 = as.vector(coef(cvfit$glmnet.fit, cvfit$lambda.1se))[-1]
      nonzero_index <- which(beta1 != 0)
      if(length(nonzero_index)!=0)
        break
    }
    beta2 <- rep(0, p)
    beta2[nonzero_index] <- as.vector(lm(y[sample_index2] ~ X[sample_index2, nonzero_index] - 1)$coeff)
    ### calculate the test statistics
    M <- sign(beta1 * beta2) * (abs(beta1) + abs(beta2))
    M[is.na(M)] = 0
    ### find the threshold
    result = analys(M, abs(M), q)
    current_selected_index <- result
    ### number of selected variables
    num_select[iter] <- length(current_selected_index)
    if(num_select[iter]!=0)
      selected_index_multiple[iter, current_selected_index] <- selected_index_multiple[iter, current_selected_index] + 1/num_select[iter]
    
  }
  
  ### single splitting result
  single_split_selected = current_selected_index
  
  ### multiple splitting result
  feature_rank <- order(apply(selected_index_multiple, 2, mean))
  feature_rank <- setdiff(feature_rank, which(apply(selected_index_multiple, 2, mean) == 0))
  null_variable <- numeric()
  fdr_replicate <- rep(0, num_split)
  for(feature_index in 1:length(feature_rank)){
    for(split_index in 1:num_split){
      if(selected_index_multiple[split_index, feature_rank[feature_index]]){
        fdr_replicate[split_index] <- fdr_replicate[split_index] + 1/num_select[split_index]
      }
    }
    if(mean(fdr_replicate) > q){
      break
    }else{
      null_variable <- c(null_variable, feature_rank[feature_index])
    }
  }
  ### conservative one
  multiple_selected_index <- setdiff(feature_rank, null_variable)
  list(SDS = single_split_selected, MDS = multiple_selected_index)
}


DS_knockoff_and_bhq <- function (X, y, q) {
  # Log-transform the drug resistance measurements.
  y = log(y)
  
  # Remove patients with missing measurements.
  missing = is.na(y)
  y = y[!missing]
  X = X[!missing,]
  
  # Remove predictors that appear less than 3 times.
  X = X[,colSums(X) >= 3]
  
  # Remove duplicate predictors.
  X = X[,colSums(abs(cor(X)-1) < 1e-4) == 1]
  
  # Run the knockoff filter.
  knock.gen = function(x) create.second_order(x,  method='equi')
  result = knockoff.filter(X, y, fdr=fdr, knockoffs=knock.gen, statistic=stat.glmnet_lambdasmax)
  knockoff_selected = names(result$selected)
  
  # Run BHq.
  p = ncol(X)
  lm.fit = lm(y ~ X - 1) # no intercept
  p.values = coef(summary(lm.fit))[,4]
  cutoff = max(c(0, which(sort(p.values) <= fdr * (1:p) / p)))
  bhq_selected = names(which(p.values <= fdr * cutoff / p))
  result = Split(X, y, fdr)
  SDS_selected = colnames(X)[result$SDS]
  MDS_selected = colnames(X)[result$MDS]
  list(SDS = SDS_selected, MDS = MDS_selected, Knockoff = knockoff_selected, BHq = bhq_selected)
}

fdr = 0.20
results = lapply(Y, function(y) DS_knockoff_and_bhq(X, y, fdr))
get_selected_name = function(X,y, selected){
  y = log(y)
  
  # Remove patients with missing measurements.
  missing = is.na(y)
  y = y[!missing]
  X = X[!missing,]
  
  # Remove predictors that appear less than 3 times.
  X = X[,colSums(X) >= 3]
  
  # Remove duplicate predictors.
  X = X[,colSums(abs(cor(X)-1) < 1e-4) == 1]
  colnames(X)[selected]
}




get_position <- function(x)
  sapply(regmatches(x, regexpr('[[:digit:]]+', x)), as.numeric)

comparisons <- lapply(results, function(drug) {
  lapply(drug, function(selected) {
    positions = unique(get_position(selected)) # remove possible duplicates
    discoveries = length(positions)
    false_discoveries = length(setdiff(positions, tsm_df$Position))
    list(true_discoveries = discoveries - false_discoveries,
         false_discoveries = false_discoveries)
  })
})

comparisons$APV$DeepPINK$true_discoveries = 18
comparisons$APV$DeepPINK$false_discoveries = 0
comparisons$ATV$DeepPINK$true_discoveries = 26
comparisons$ATV$DeepPINK$false_discoveries = 10
comparisons$IDV$DeepPINK$true_discoveries = 19
comparisons$IDV$DeepPINK$flase_discoveries = 6
comparisons$LPV$DeepPINK$true_discoveries = 18
comparisons$LPV$DeepPINK$false_discoveries = 5
comparisons$NFV$DeepPINK$true_discoveries = 28
comparisons$NFV$DeepPINK$false_discoveries = 10
comparisons$RTV$DeepPINK$true_discoveries = 18
comparisons$RTV$DeepPINK$false_discoveries = 4
comparisons$SQV$DeepPINK$true_discoveries = 15
comparisons$SQV$DeepPINK$false_discoveries = 2


for (drug in names(comparisons)) {
  plot_data = do.call(cbind, comparisons[[drug]])
  plot_data = plot_data[c('true_discoveries','false_discoveries'),]
  barplot(as.matrix(plot_data), main = paste('Resistance to', drug),
          col = c('navy','orange'), ylim = c(0,40))
}









