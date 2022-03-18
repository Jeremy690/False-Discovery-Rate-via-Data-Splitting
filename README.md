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

We have made an R package for our methods, which is available at this git: https://github.com/Jeremy690/DSfdr. The vignetts in the R package contains two easy to run cases to illustrate our methods. In this repo, we include all the code neede to construct every figure in our paper. It consists of three parts. functions folder basically contains the code for our methods and the comparing methods. It also 
