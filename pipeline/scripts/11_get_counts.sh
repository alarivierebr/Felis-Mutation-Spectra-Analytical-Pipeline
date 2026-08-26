#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=project0076
#SBATCH --job-name=get_variants
#SBATCH --time=12:00:00
#SBATCH --partition=nodes,smp
#SBATCH --cpus-per-task=4
#SBATCH --mem=32G

#SBATCH --output=/mnt/autofs/data/userdata/project0076/annalise/filtering/pipeline/logs/11-%j.out
#SBATCH --error=/mnt/autofs/data/userdata/project0076//annalise/filtering/pipeline/logs/11-%j.err

#SBATCH --mail-user=3175404l@student.gla.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL

source /mnt/autofs/data/userdata/project0076/annalise/filtering/pipeline/project_config.sh
set -euo pipefail

OUTPUT="${RESULTS_DIR}"/vcf_variant_snps_summary.txt

VCFS=(
    "${GLNEXUS_VCF}" # Full cohort, no filtering
    "${MULTI_SPLIT_VCF}" # After bcftools norm -m -any
    "${FILTER_VAR}" #After filter_variants.py
    "${BCFTOOLS_FILTER}" #After bcftools view -m 2 -M 2 -c 2:minor -a -A
    "${MUTYPER_VAR_FELIS}" #Felis ancestral and derived assigned vcf before mutyper spec
    "${MUTYPER_VAR_FELIDAE}" #Felidae ancestral and derived assigned vcf before mutyper spec
)

# Header
echo -e "VCF\tTotal_variants\tSNPs\tIndels\tMultiallelic_sites\tMultiallelic_SNPs\tBiallelic_SNPs" > "${OUTPUT}"

for VCF in "${VCFS[@]}"; do

    NAME=$(basename "${VCF}")

    echo "Processing ${NAME}..."

    TOTAL=$(bcftools view -H "${VCF}" | wc -l) 
    SNPS=$(bcftools view -H -v snps "${VCF}" | wc -l)
    INDELS=$(bcftools view -H -v indels "${VCF}" | wc -l)
    MULTI=$(bcftools view -H -m3 "${VCF}" | wc -l)
    MULTI_SNPS=$(bcftools view -H -m3 -v snps "${VCF}" | wc -l)
    BI_SNPS=$(bcftools view -H -m2 -M2 -v snps "${VCF}" | wc -l)

    echo -e "${NAME}\t${TOTAL}\t${SNPS}\t${INDELS}\t${MULTI}\t${MULTI_SNPS}\t${BI_SNPS}" >> "${OUTPUT}"

done

#First PCA - Check logs for plink run

#After PCA Full cohort
#check logs

#After PCA Wild
#check logs

#After PCA Domestic
#check logs

# # Full Cohort

# #bcftools view -v snps -H "${GLNEXUS_VCF}" --threads "${SLURM_CPUS_PER_TASK}" | wc -l > cohort.full.var_count.txt
# #bcftools view -v indels -H "${GLNEXUS_VCF}" --threads "${SLURM_CPUS_PER_TASK}" | wc -l > cohort.full.indel_count.txt


# #After Filter variants
# #bcftools view -v snps -H "${SPLIT_CHROM}" --threads "${SLURM_CPUS_PER_TASK}" | wc -l > after.filter.var_count.txt
# #bcftools view -v indels -H "${SPLIT_CHROM}" --threads "${SLURM_CPUS_PER_TASK}" | wc -l > after.filter.indel_count.txt


# # After bcftools view filter
# #bcftools view -v snps -H "${BCFTOOLS_FILTER}" --threads "${SLURM_CPUS_PER_TASK}" | wc -l > after.bcf.filter.var_count.txt
# #bcftools view -v indels -H "${BCFTOOLS_FILTER}" --threads "${SLURM_CPUS_PER_TASK}" | wc -l > after.bcf.filter.indel_count.txt

# #Mutyper Variants Felis
# #bcftools view -v snps -H "${MUTYPER_VAR_FELIS}" --threads "${SLURM_CPUS_PER_TASK}" | wc -l > mutyper.felis.var_count.txt
# #bcftools view -v indels -H "${MUTYPER_VAR_FELIS}" --threads "${SLURM_CPUS_PER_TASK}" | wc -l > mutyper.felis.indel_count.txt

# #Mutyper Variants Felidae
# bcftools view -H "${MUTYPER_VAR_FELIDAE}" --threads "${SLURM_CPUS_PER_TASK}" | wc -l > mutyper.felidae.var_count.txt
# bcftools view -v snps -H "${MUTYPER_VAR_FELIDAE}" --threads "${SLURM_CPUS_PER_TASK}" | wc -l > mutyper.felidae.snp_count.txt
# bcftools view -v indels -H "${MUTYPER_VAR_FELIDAE}" --threads "${SLURM_CPUS_PER_TASK}" | wc -l > mutyper.felidae.indel_count.txt
# bcftools view -H -m3 "${MUTYPER_VAR_FELIDAE}" --threads "${SLURM_CPUS_PER_TASK}" | wc -l > mutyper.felidae.multi_sites_count.txt
# bcftools view -H -m3 -v snps "${MUTYPER_VAR_FELIDAE}" --threads "${SLURM_CPUS_PER_TASK}" | wc -l > mutyper.felidae.multi_snps_count.txt
# bcftools view -H -m2 -M2 -v snps "${MUTYPER_VAR_FELIDAE}" --threads "${SLURM_CPUS_PER_TASK}" | wc -l > mutyper.felidae.bi_snps_count.txt