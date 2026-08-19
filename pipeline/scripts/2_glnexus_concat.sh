#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=project0076
#SBATCH --job-name=glnexus_chr
#SBATCH --time=48:00:00
#SBATCH --partition=smp
#SBATCH --cpus-per-task=4
#SBATCH --mem=48G
#SBATCH --array=1-20%4

#SBATCH --output=/mnt/autofs/data/userdata/project0076/annalise/GLNexus/slurmlogs/%x-%A_%a.out
#SBATCH --error=/mnt/autofs/data/userdata/project0076/annalise/GLNexus/slurmlogs/%x-%A_%a.err

#SBATCH --mail-user=3175404l@student.gla.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL

set -euo pipefail

OUTDIR="/mnt/autofs/data/userdata/project0076/annalise/GLNexus/output2"

bcftools concat -a -Oz \
    ${OUTDIR}/*.bcf \
    -o ${OUTDIR}/cohort.full.vcf.gz

bcftools index -f ${OUTDIR}/cohort.full.vcf.gz

echo "Merged cohort successfully created"