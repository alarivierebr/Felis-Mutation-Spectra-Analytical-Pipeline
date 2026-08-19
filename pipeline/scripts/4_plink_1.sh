#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=project0076
#SBATCH --job-name=4_plink_1
#SBATCH --time=12:00:00
#SBATCH --partition=smp,nodes
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

#SBATCH --output=/mnt/autofs/data/userdata/project0076/annalise/pipeline/results/logs/4-plink-%j.out
#SBATCH --error=/mnt/autofs/data/userdata/project0076/annalise/pipeline/results/logs/4-plink-%j.err

#SBATCH --mail-user=3175404l@student.gla.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL

source /mnt/autofs/data/userdata/project0076/annalise/pipeline/project_config.sh


plink2 \
    --vcf "${GLNEXUS_VCF}" \
    --vcf-half-call missing \
    --make-bed \
    --out "${PLINK_1_DIR}"
	
plink2 \
    --bfile "${PLINK_1_DIR}" \
    --pca \
    --out "${PLINK_1_DIR}"