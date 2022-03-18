#!/bin/bash
#SBATCH -n 1                                     # Number of cores
#SBATCH -t 0-2:00                                # Runtime in D-HH:MM
#SBATCH -p shared                        # Partition to submit to
#SBATCH --mem=10000M                             # Memory pool for all cores (see also --mem-per-cpu)
#SBATCH --mail-type=END                          # Type of email notification- BEGIN,END,FAIL,ALL
#SBATCH --mail-user=blin@g.harvard.edu
#SBATCH --array=1-200
#SBATCH -o out/err_cor
#SBATCH -J optimality

## LOAD SOFTWARE ENV ##
module load gcc/7.1.0-fasrc01 R/3.6.3-fasrc01
export R_LIBS_USER=$HOME/apps/R:$R_LIBS_USER
input=optimality_cor.R
cd ~/code/simulation/figure3/

for att in 0 0.2 0.4 0.6 0.8; do
#
echo "${att}"
export att
#
R CMD BATCH $input out/$input.$SLURM_ARRAY_TASK_ID.out

sleep 1                                          # pause to be kind to the scheduler
done