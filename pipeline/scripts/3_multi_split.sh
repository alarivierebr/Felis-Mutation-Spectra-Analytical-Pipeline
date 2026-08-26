#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=project0076
#SBATCH --job-name=4_multi_split
#SBATCH --time=12:00:00
#SBATCH --partition=smp,nodes
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

#SBATCH --output=/mnt/autofs/data/userdata/project0076/annalise/results/logs/4-%j.out
#SBATCH --error=/mnt/autofs/data/userdata/project0076/annalise/results/logs/4-%j.err

#SBATCH --mail-user=3175404l@student.gla.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL

source /mnt/autofs/data/userdata/project0076/annalise/pipeline/project_config.sh

bcftools norm \
	--threads "${SLURM_CPUS_PER_TASK}" \
    -m -any \
    -Oz \
	--write-index=tbi \
    -o "${MULTI_SPLIT_VCF}" \
    "${OUTLIERS_REMOVED_VCF}"