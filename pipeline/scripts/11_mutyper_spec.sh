#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=project0076
#SBATCH --job-name=11_mutyperS
#SBATCH --time=12:00:00
#SBATCH --partition=nodes,smp
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

#SBATCH --output=/mnt/autofs/data/userdata/project0076/annalise/results/logs/11-%j.out
#SBATCH --error=/mnt/autofs/data/userdata/project0076/annalise/results/logs/11-%j.err

#SBATCH --mail-user=3175404l@student.gla.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL

source /mnt/autofs/data/userdata/project0076/annalise/pipeline/project_config.sh

set -euo pipefail


[[ -f "${MUTYPER_VAR_FELIDAE}" ]] || {
    echo "ERROR: Missing input file: ${10_MUTYPER_VAR_FELIDAE}" >&2
    exit 1
}

[[ -f "${MUTYPER_VAR_FELIS}" ]] || {
    echo "ERROR: Missing input file: ${10_MUTYPER_VAR_FELIS}" >&2
    exit 1
}

mutyper spectra "${MUTYPER_VAR_FELIDAE}" \
    > "${MUTYPER_S_FELIDAE}"

mutyper spectra "${MUTYPER_VAR_FELIS}" \
    > "${MUTYPER_S_FELIS}"