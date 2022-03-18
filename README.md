# False-Discovery-Rate-via-Data-Splitting
Reproduce all the figures for the paper False Discovery Rate via Data Splitting

# Data

**Abstract**

We use two real data sets in our paper. The first one is the scRNAseq data which contains a total of 400 T47D A1-2 human breast cancer cells. This data contains 400 samples of control group in which the cells are vehicle-treated and 400 samples of treatment group in which the cells are treated with 100 nM synthetic glucocorticoid dexamethasone (Dex). After proper normalization, the final scRNAseq data contains 800 samples, each with 32,049 gene expressions.

The second dataset is used to detect mutations in the Human Immunodeficiency Virus Type 1 (HIV-1) that are associated with drug resistance. It contains resistance measurements of seven drugs for protease inhibitors (PIs), six drugs for nucleoside reverse-transcriptase inhibitors (NRTIs). The response vector y records the log-fold-increase of the lab-tested drug resistance. The design matrix X is binary, in which the j-th column indicates the presence or absence of the j-th mutation.

**Availability**

These two datasets are both available online.

The scRNAseq data is available at
https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE141834

The drug data is availabel at 
http://hivdb.stanford.edu/pages/published_analysis/genophenoPNAS2006/

**Description**

The data is explained in full in the text of Section 4.1 and Section 4.3 of the manuscript.

# Code

**Abstract**

We have made an R package for our methods, which is available at this git: https://github.com/Jeremy690/DSfdr. The vignetts in the R package contains two easy to run cases to illustrate our methods. In this repo, we include all the code neede to construct every figure in our paper. 

**Description**

The code folder contains all the scripts we used to reproduce the results in the main text of the paper. It consists of three parts, functions, simulation and real_data. The functions folder basically contains the implementation for our methods and the comparing methods. It also contains some utility functions which is used to calculate the fdp and power. The simulation folder contains all the code needed to reproduce the simulations in the main text of the paper. Each folder of the simulation contains the R code and the sh file. The sh file is used to run the simulations in a parallel way via the Odyssey system at Harvard. All scripts used to reproduce the real data analysis are included under the real_data folder.

**Optional Information**

Code is developed and tested using R 3.6.3. The simulation study is conducted under FAS research computing cluster at Harvard (Odyssey system). Current implementation depends on the followingR packages:

```
● glmnet: version 4.1-1.
● MASS: version 7.3-51.4.
● knockoff: version 0.3.3.
● mvtnorm: version 1.0-11.
● hdi: version 0.1-7.
● SILGGM: version 1.0.0
● breadcrumbs: version 0.1.0.
● ppcor: version 1.1.
```

All packages are available through CRAN (https://cran.r-project.org/)and can be installed
automatically by running **install.packages(PACKAGE_NAME)** inan R session.
