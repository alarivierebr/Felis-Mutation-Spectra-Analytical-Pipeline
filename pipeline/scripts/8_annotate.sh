#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=project0076
#SBATCH --job-name=annotate
#SBATCH --time=12:00:00
#SBATCH --partition=nodes,smp
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

#SBATCH --output=/mnt/autofs/data/userdata/project0076/annalise/results/logs/9-%j.out
#SBATCH --error=/mnt/autofs/data/userdata/project0076/annalise/results/logs/9-%j.err

#SBATCH --mail-user=3175404l@student.gla.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL

set -euo pipefail

source /mnt/autofs/data/userdata/project0076/annalise/pipeline/project_config.sh


bcftools +fill-tags \
    "${BCFTOOLS_FILTER}" \
	--threads "${SLURM_CPUS_PER_TASK}" \
    -Oz \
    -o "${ANNOTATED_VCF}" \
    -- -t AC,AN