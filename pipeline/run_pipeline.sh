#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=project0076
#SBATCH --job-name=project_config
#SBATCH --time=00:10:00
#SBATCH --partition=nodes,smp


#SBATCH --output=/mnt/autofs/data/userdata/project0076/annalise/pipeline/results/logs/run-pipeline-%j.out
#SBATCH --error=/mnt/autofs/data/userdata/project0076/annalise/pipeline/results/logs/run-pipeline-%j.err

#SBATCH --mail-user=3175404l@student.gla.ac.uk
#SBATCH --mail-type=BEGIN,END,FAIL


source /mnt/autofs/data/userdata/project0076/annalise/filtering/pipeline/project_config.sh

set -euo pipefail


#Runs every step in the pipeline aside from 1_glnexus.sh and 2_glnexus_concat.sh. Run 1 and 2 manually and then run this script at Step 3!

job1=$(sbatch "${SCRIPTS_DIR}/3_multi_split.sh" | awk '{print $4}')
echo "Submitted 3_multi_split.sh: ${job1}"

job2=$(sbatch --dependency=afterok:${job1} "${SCRIPTS_DIR}/4_filter_variants.sh" | awk '{print $4}')
echo "Submitted 4_filter_variants.sh: ${job2}"

job3=$(sbatch --dependency=afterok:${job2} "${SCRIPTS_DIR}/5_bcftools_filter.sh" | awk '{print $4}')
echo "Submitted 5_bcftools_filter.sh: ${job3}"

job4=$(sbatch --dependency=afterok:${job3} "${SCRIPTS_DIR}/6_plink_filtered.sh" | awk '{print $4}')
echo "Submitted 6_plink_filtered.sh: ${job4}"

job5=$(sbatch --dependency=afterok:${job4} "${SCRIPTS_DIR}/7_dom_only_plink.sh" | awk '{print $4}')
echo "Submitted 7_dom_only_plink.sh: ${job5}"

job6=$(sbatch --dependency=afterok:${job4} "${SCRIPTS_DIR}/7_wild_only_plink.sh" | awk '{print $4}')
echo "Submitted 7_wild_only_plink.sh: ${job6}"

job7=$(sbatch --dependency=afterok:${job4} "${SCRIPTS_DIR}/8_annotate.sh" | awk '{print $4}')
echo "Submitted 8_annotate.sh: ${job7}"

job8=$(sbatch --dependency=afterok:${job7} "${SCRIPTS_DIR}/9_mutyper_var.sh" | awk '{print $4}')
echo "Submitted 9_mutyper_var.sh: ${job8}"

job9=$(sbatch --dependency=afterok:${job8} "${SCRIPTS_DIR}/10_mutyper_spec.sh" | awk '{print $4}')
echo "Submitted 10_mutyper_spec.sh: ${job9}"

