#!/bin/bash
#SBATCH --job-name=stan
#SBATCH --ntasks=4
#SBATCH --mem=4gb
#SBATCH --partition=short
#SBATCH --time=2-00:00:00

cd /home/quentin.read/GitHub/paretotesting
module load r/4.1.2
Rscript2 ${s}
