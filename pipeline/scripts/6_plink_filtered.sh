#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=project0076
#SBATCH --job-name=7_plink_filtered
#SBATCH --time=12:00:00
#SBATCH --partition=smp,nodes
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

#SBATCH --output=/mnt/autofs/data/userdata/project0076/annalise/filtering/pipeline/logs/7-%j.out
#SBATCH --error=/mnt/autofs/data/userdata/project0076/annalise/filtering/pipeline/logs/7-%j.err

#SBATCH --mail-user=3175404l@student.gla.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL

source /mnt/autofs/data/userdata/project0076/annalise/filtering/pipeline/project_config.sh


plink2 \
    --vcf "${BCFTOOLS_FILTER}" \
    --vcf-half-call missing \
    --make-bed \
    --out "${PLINK_3_DIR}"
	
plink2 \
    --bfile "${PLINK_3_DIR}" \
	--maf "${MIN_MAF}" \
    --geno "${GENO}" \
    --pca \
    --out "${PLINK_3_DIR}"