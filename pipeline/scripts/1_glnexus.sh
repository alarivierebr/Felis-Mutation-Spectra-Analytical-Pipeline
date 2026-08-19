#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=project0076
#SBATCH --job-name=glnexus_chr
#SBATCH --time=48:00:00
#SBATCH --partition=smp
#SBATCH --cpus-per-task=8
#SBATCH --mem=48G
#SBATCH --array=1-20

#SBATCH --output=/mnt/autofs/data/userdata/project0076/annalise/GLNexus/slurmlogs/%x-%A_%a.out
#SBATCH --error=/mnt/autofs/data/userdata/project0076/annalise/GLNexus/slurmlogs/%x-%A_%a.err

#SBATCH --mail-user=3175404l@student.gla.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL

set -euo pipefail

################ MODULES ################

module load apps/miniforge
conda activate /mnt/data/project0076/annalise/miniforge3/envs/nf_env

# input

GVCF_LIST="/mnt/autofs/data/userdata/project0076/annalise/GLNexus/deepvariant_gvcfs.list"
CONTIG_FILE="/mnt/autofs/data/userdata/project0076/annalise/configs/chromosomes.txt"
BED_FILE="/mnt/autofs/data/userdata/project0076/annalise/GLNexus/chromosomes.bed"

OUTDIR="/mnt/autofs/data/userdata/project0076/annalise/GLNexus/output2"
DBROOT="${OUTDIR}/db"

mkdir -p "${OUTDIR}" "${DBROOT}"

if [[ ! -f "${GVCF_LIST}" ]]; then
    echo "ERROR: gVCF list not found: ${GVCF_LIST}"
    exit 1
fi

if [[ ! -f "${CONTIG_FILE}" ]]; then
    echo "ERROR: contig file not found: ${CONTIG_FILE}"
    exit 1
fi

if [[ ! -f "${BED_FILE}" ]]; then
    echo "ERROR: BED file not found: ${BED_FILE}"
    exit 1
fi

CONTIG_ID=$(head -${SLURM_ARRAY_TASK_ID} "${CONTIG_FILE}" | tail -1)

echo "Chromosome: ${CONTIG_ID}"


# contig specific bed file


BED_FILE="${DBROOT}/${CONTIG_ID}.bed"

awk -v c="${CONTIG_ID}" '$1==c {print $1"\t"$2"\t"$3}' \
    /mnt/autofs/data/userdata/project0076/annalise/GLNexus/chromosomes.bed \
    > "${BED_FILE}"

if [[ ! -s "${BED_FILE}" ]]; then
    echo "ERROR: BED missing for ${CONTIG_ID}"
    exit 1
fi


DBDIR="${DBROOT}/GLNexus_${CONTIG_ID}_${SLURM_JOB_ID}"
OUT_BCF="${OUTDIR}/${CONTIG_ID}.bcf"

#glnexus run

LD_PRELOAD=`jemalloc-config --libdir`/libjemalloc.so.`jemalloc-config --revision` glnexus_cli \
    --config DeepVariantWGS \
    --threads 2 \
    --mem-gbytes 40 \
    --bed "${BED_FILE}" \
    --list "${GVCF_LIST}" \
    --dir "${DBDIR}" \
    > "${OUT_BCF}"

#indexing

bcftools index -f "${OUT_BCF}"

echo "DONE: ${CONTIG_ID}"
echo "OUTPUT: ${OUT_BCF}"