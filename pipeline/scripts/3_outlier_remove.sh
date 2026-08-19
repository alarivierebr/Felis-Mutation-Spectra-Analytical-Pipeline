#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=project0076
#SBATCH --job-name=3_outlier_remove
#SBATCH --time=12:00:00
#SBATCH --partition=nodes,smp
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

#SBATCH --output=/mnt/autofs/data/userdata/project0076/annalise/results/logs/3-%j.out
#SBATCH --error=/mnt/autofs/data/userdata/project0076/annalise/results/logs/3-%j.err

#SBATCH --mail-user=3175404l@student.gla.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL

source /mnt/autofs/data/userdata/project0076/annalise/pipeline/project_config.sh

#Keep only good samples passing manual QC check
bcftools view \
    --samples-file "${QC_SAMPLES_TO_KEEP}" \
	--threads "${SLURM_CPUS_PER_TASK}" \
	-Oz \
	-o "${OUTLIERS_REMOVED_VCF}" \
	--write-index=tbi \
	"${GLNEXUS_VCF}"