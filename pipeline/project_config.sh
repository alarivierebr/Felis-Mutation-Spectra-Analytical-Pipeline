#!/bin/bash -l

#Project configuration

# --------------- Tools Required ------------#

#Plink2
#bcftools 
#mutyper
#GLNexus 
#python3

# ------------ Project directories -------------- #

PROJECT_DIR="/mnt/autofs/data/userdata/project0076/annalise"

RESULTS_DIR="${PROJECT_DIR}/filtering/pipeline/results"

LOG_DIR="${RESULTS_DIR}/logs"

SCRIPTS_DIR="${PROJECT_DIR}/filtering/pipeline/scripts"

GLNEXUS_DIR="${PROJECT_DIR}/GLNexus/output2"

MUTYPER_DIR="${RESULTS_DIR}/mutyper"

FILTER_VARIANTS_SCRIPT="${PROJECT_DIR}/filtering/filter_variants.py"

SAMPLE_LIST_DIR="${SCRIPTS_DIR}/sample_lists"

# ------------ ANCESTRAL GENOMES --------------#

FELIDAE_ANC="/mnt/autofs/data/userdata/project0076/Cats/ancestral_genomes/ANCESTRAL_GENOME_FELIDAE/ancestral/ancestral_genome/ancestral.fasta"
FELIS_ANC="/mnt/autofs/data/userdata/project0076/Cats/ancestral_genomes/ANCESTRAL_GENOME_FELIS/ancestral/ancestral_genome/ancestral.fasta"


#------- Sample Lists -------- #

QC_SAMPLES_TO_KEEP="${SAMPLE_LIST_DIR}/samples_to_keep.txt"

DOM_ONLY="${SAMPLE_LIST_DIR}/domestic_only_samples.txt"

WILD_ONLY="${SAMPLE_LIST_DIR}/wild_only_samples.txt"

FILTERED_OUT="${SAMPLE_LIST_DIR}/filtered_samples.txt"

#------ suffixes -----#

PLINK_1_DIR="${RESULTS_DIR}/plink_1/before_filter_pca"

CHROM_SUFFIX="filtered.vcf.gz"

PLINK_2_DIR="${RESULTS_DIR}/plink_filtered/filtered_pca"

PLINK_3_DIR="${RESULTS_DIR}/plink_nO/nO_filtered_pca"

DOM_ONLY_DIR="${RESULTS_DIR}/plink_filtered/dom_only/nO_dom_only"

WILD_ONLY_DIR="${RESULTS_DIR}/plink_filtered/wild_only/nO_wild_only"


# ------------ Input/output files---------------#

#Input for 3_multi_split.sh
GLNEXUS_VCF="${GLNEXUS_DIR}/cohort.full.vcf.gz"
#Input for 4_bcftools_norm and 4_plink_pca
OUTLIERS_REMOVED_VCF="${RESULTS_DIR}/outliers.removed.vcf.gz"
#Output for 4_bcftools_norm, Input for 5
MULTI_SPLIT_VCF="${RESULTS_DIR}/multi_split.vcf.gz"
MULTI_SPLIT_INDEX="${RESULTS_DIR}/multi_split.vcf.gz.tbi"
#Output for 5 and input for 6
FILTER_VAR="${RESULTS_DIR}/filtered.vcf.gz"
#Output for 6 and Input for 7
BCFTOOLS_FILTER="${RESULTS_DIR}/nO_final.full.vcf.gz"
#input for 8 and output for 8
FILTERED_PLINK="${PLINK_2_DIR}"
#output for 9 and input for 10
ANNOTATED_VCF="${RESULTS_DIR}/annotated.vcf.gz"
#output for 10, input for 11
MUTYPER_VAR_FELIS="${RESULTS_DIR}/mutyper/felis.mutyper.var.vcf.gz"
MUTYPER_VAR_FELIDAE="${RESULTS_DIR}/mutyper/felidae.mutyper.var.vcf.gz"

MUTYPER_S_FELIS="${MUTYPER_DIR}/felis_mutyper.tsv"
MUTYPER_S_FELIDAE="${MUTYPER_DIR}/felidae_mutyper.tsv"

# ------ Filtering Parameters ------#

MIN_MAF=0.05
GENO=0.1