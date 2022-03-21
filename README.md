# False-Discovery-Rate-via-Data-Splitting
Reproduce all the figures for the paper False Discovery Rate via Data Splitting

# Data

**Abstract**

We use two real data sets in our paper. The first one is an scRNAseq data set, which contains expressioons of a total of 400 T47D A1-2 human breast cancer cells. This data set contains 400 samples in the control group, in which the cells are vehicle-treated, and 400 samples in the treatment group, in which the cells are treated with 100 nM synthetic glucocorticoid dexamethasone (Dex). After proper normalization, the final scRNAseq data consist of 800 samples, each with  expressions of 32,049 genes.

The second dataset regards the detection of mutations in the Human Immunodeficiency Virus Type 1 (HIV-1) that are associated with drug resistance. It contains resistance measurements  for seven drugs of protease inhibitors (PIs), six drugs of nucleoside reverse-transcriptase inhibitors (NRTIs). The response vector y records the log-fold-increase of the lab-tested drug resistance. The design matrix X is binary, in which the j-th column indicates the presence or absence of the j-th mutation.

**Availability**

These two datasets are both available online.

The scRNAseq data is available at
https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE141834

The drug data is available at 
http://hivdb.stanford.edu/pages/published_analysis/genophenoPNAS2006/

**Description**

The datasets are explained in full in Section 4.1 and Section 4.3 of the manuscript.

# Code

**Abstract**

We have made an R package for our methods, which is available at this git: https://github.com/Jeremy690/DSfdr. The vignette in the R package contains two easy to run cases to illustrate our methods. In this repo, we include all the code neede to construct every figure in our paper. 

**Description**

The code folder contains all the scripts we used to reproduce the results in the main text of the paper. It consists of three parts: functions, simulations, and real_data. The functions folder contains the implementation of our methods and the methods considered for comparisons. It also contains some utility functions that are used to calculate the fdp and power. The simulation folder contains all the codes needed to reproduce the simulations in the main text of the paper. Each sub-folder of the simulation fold contains the R code and the sh file. The sh file is used to run the simulations in a parallel way via the Odyssey system at Harvard. All scripts used to reproduce the real data analysis are included in the real_data folder.

**Optional Information**

Code is developed and tested using R_3.6.3. The simulation study is carried out using the FAS research computing cluster at Harvard (Odyssey system). Our current implementation depends on the following R packages:

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

All packages are available through CRAN (https://cran.r-project.org/)and can be installed automatically by running **install.packages(PACKAGE_NAME)** in an R session.

**Structures of the Simulation Folder**

The general structure is provided in the **Description**. For each folder in the simulation, we also include several more folders, such as *out* and *results_()*. The results of the code are in the *results_()* folder and the log of the running can be accessed in the *out* folder.

# Instructions for Use

**Reproducibility**

*What is to be reproduced*

All the figures in the main text of the paper.

*How to reproduce analyses*

Numerical Simulations in Section 2.3, Section 4,1 and Section 4.2.

```
● Upload the file onto a computer system (e.g., Odyssey at Harvard).
● For each figure, open the corresponding folder.
● Make sure to change the working directory in the R file and the sh file in the corresponding folder. We have pointed out the codes you need to change when you want to produce the figures on your own.
● In the sh file, change the mail-user to your own email address. It will automatically inform you whenever your running jobs are done via email.
● Run the sh file and the results will appear in the result_left and result_right folder. 
● The results are in the .Rdata file form, you can directly load in the results and by calling data_save in the Rstudio, you get the results.
● Calculate the mean of the results will lead to each data point in the figure.
```

Note for the reproduction of Figure 7, you also need to specify the location of the data.txt. 

Real data results in Section 4.3.

```
● Directly run the two R files
```

Note that the results may differ slight from those in the paper, especially for the knockoff procedures, since both knockoffs and our methods involve random sampling and are not deterministic algorithms.

Running time:

The running time of the simulations with linear models was around 2-5 hours depending on the problem . For gaussian graphical models, it took more than ten hours to run. For real data, one may get the results within 10 minutes.

