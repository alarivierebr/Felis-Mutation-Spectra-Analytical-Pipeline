#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=project0076
#SBATCH --job-name=6_bcf_filter
#SBATCH --time=12:00:00
#SBATCH --partition=nodes,smp
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

#SBATCH --output=/mnt/autofs/data/userdata/project0076/annalise/results/logs/6-%j.out
#SBATCH --error=/mnt/autofs/data/userdata/project0076/annalise/results/logs/6-%j.err

#SBATCH --mail-user=3175404l@student.gla.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL

source /mnt/autofs/data/userdata/project0076/annalise/pipeline/project_config.sh

bcftools view \
	-m 2 \
	-M 2 \
	-c 2:minor \
	-A \
	-a \
	--threads "${SLURM_CPUS_PER_TASK}" \
	-Oz \
	-o "${BCFTOOLS_FILTER}" \
	--write-index=tbi \
	"${SPLIT_CHROM}"