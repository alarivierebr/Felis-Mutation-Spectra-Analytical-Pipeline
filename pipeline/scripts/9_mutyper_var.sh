#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=project0076
#SBATCH --job-name=10_mutyperV
#SBATCH --time=12:00:00
#SBATCH --partition=nodes,smp
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

#SBATCH --output=/mnt/autofs/data/userdata/project0076/annalise/pipeline/results/logs/%j.out
#SBATCH --error=/mnt/autofs/data/userdata/project0076/annalise/pipeline/results/logs/%j.err

#SBATCH --mail-user=3175404l@student.gla.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL

set -euo pipefail

source /mnt/autofs/data/userdata/project0076/annalise/pipeline/project_config.sh


[[ -f "${ANNOTATED_VCF}" ]] || {
    echo "ERROR: Cannot find ${ANNOTATED_VCF}" >&2
    exit 1
}

mutyper variants "${FELIDAE_ANC}" "${ANNOTATED_VCF}" \
	| bcftools view \
	-Oz \
	--threads "${SLURM_CPUS_PER_TASK}" \
	--write-index=tbi \
	-o "${MUTYPER_VAR_FELIDAE}"

mutyper variants "${FELIS_ANC}" "${ANNOTATED_VCF}" \
	| bcftools view \
	-Oz \
	--threads "${SLURM_CPUS_PER_TASK}" \
	--write-index=tbi \
	-o "${MUTYPER_VAR_FELIS}"
