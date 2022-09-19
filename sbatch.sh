sbatch --job-name=dens1 --export=s=density_stanfits_remote.R,mod=1 job.sh
sbatch --job-name=dens2 --partition=medium --time=7-00:00:00 --export=s=density_stanfits_remote.R,mod=2 job.sh
sbatch --job-name=dens3 --partition=medium --time=7-00:00:00 --export=s=density_stanfits_remote.R,mod=3 job.sh
sbatch --job-name=prod1 --export=s=prod_stanfits_remote.R,mod=1 job.sh
sbatch --job-name=prod2 --partition=medium --time=7-00:00:00 --export=s=prod_stanfits_remote.R,mod=2 job.sh

sbatch --job-name=dens1all --export=s=density_stanfits_alldata.R,mod=1 job.sh
sbatch --job-name=dens2all --partition=medium --time=7-00:00:00 --export=s=density_stanfits_alldata.R,mod=2 job.sh
sbatch --job-name=dens3all --partition=medium --time=7-00:00:00 --export=s=density_stanfits_alldata.R,mod=3 job.sh
sbatch --job-name=prod1all --export=s=prod_stanfits_alldata.R,mod=1 job.sh
sbatch --job-name=prod2all --partition=medium --time=7-00:00:00 --export=s=prod_stanfits_alldata.R,mod=2 job.sh

sbatch --job-name=mortjfixef --export=s=mort_jcurve_fixef_brm_remote.R --mem=16gb job.sh
sbatch --job-name=diamjfixef --export=s=diam_jcurve_fixef_brm_remote.R --mem=16gb job.sh
sbatch --job-name=diamjhinge --export=s=diam_loglin_fixef_brm.R --mem=16gb job.sh