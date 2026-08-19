#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=project0076
#SBATCH --job-name=5_filter_var
#SBATCH --time=48:00:00
#SBATCH --partition=smp
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G

#SBATCH --output=/mnt/autofs/data/userdata/project0076/annalise/pipeline/results/logs/5-%j.out
#SBATCH --error=/mnt/autofs/data/userdata/project0076/annalise/pipeline/results/logs/5-%j.err

#SBATCH --mail-user=3175404l@student.gla.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL


source /mnt/autofs/data/userdata/project0076/annalise/pipeline/project_config.sh

set -euo pipefail

#list of chromosome names

chromosomes=(
"NC_058368.1"
"NC_058369.1"
"NC_058370.1"
"NC_058371.1"
"NC_058372.1"
"NC_058373.1"
"NC_058374.1"
"NC_058375.1"
"NC_058376.1"
"NC_058377.1"
"NC_058378.1"
"NC_058379.1"
"NC_058380.1"
"NC_058381.1"
"NC_058382.1"
"NC_058383.1"
"NC_058384.1"
"NC_058385.1"
"NC_058386.1"
"NC_001700.1"
)

for chromosome in "${chromosomes[@]}"; do

    bcftools view \
		--threads "${SLURM_CPUS_PER_TASK}" \
		-r "${chromosome}" \
		"${MULTI_SPLIT_VCF}" \
    | python3 "${FILTER_VARIANTS_SCRIPT}" \
        -i - \
        -o "${RESULTS_DIR}/${chromosome}.${CHROM_SUFFIX}"
done

bcftools concat \
    --threads "${SLURM_CPUS_PER_TASK}" \
    "${RESULTS_DIR}"/NC_*."${CHROM_SUFFIX}" \
    -Oz \
	--write-index=tbi \
    -o "${SPLIT_CHROM}"
