#!/bin/bash
#SBATCH --job-name=partest
#SBATCH --ntasks=1
#SBATCH --mem=4gb
#SBATCH --partition=short
#SBATCH --time=2-00:00:00

cd /home/quentin.read/GitHub/paretotesting
module load r/4.1.2
Rscript2 rpareto_stan_testing_remote.R
