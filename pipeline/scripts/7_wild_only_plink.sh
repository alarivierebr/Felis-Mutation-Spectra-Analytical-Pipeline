#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=project0076
#SBATCH --job-name=8_plink_wild
#SBATCH --time=12:00:00
#SBATCH --partition=smp,nodes
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

#SBATCH --output=/mnt/autofs/data/userdata/project0076/annalise/pipeline/results/logs/8-wild%j.out
#SBATCH --error=/mnt/autofs/data/userdata/project0076/annalise/pipeline/results/logs/8-wild%j.err

#SBATCH --mail-user=3175404l@student.gla.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL

source /mnt/autofs/data/userdata/project0076/annalise/pipeline/project_config.sh

plink2 \
    --bfile "${FILTERED_PLINK}" \
    --remove "${DOM_ONLY}" \
    --maf "${MIN_MAF}" \
    --geno "${GENO}" \
    --pca \
    --out "${WILD_ONLY_DIR}"