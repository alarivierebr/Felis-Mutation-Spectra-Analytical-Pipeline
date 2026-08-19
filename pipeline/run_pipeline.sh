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

source /mnt/autofs/data/userdata/project0076/annalise/pipeline/project_config.sh

set -euo pipefail


#job3=$(sbatch "${SCRIPTS_DIR}/3_outlier_remove.sh" | awk '{print $4}')
#echo "Submitted 3_no_outlier_remove.sh t: ${job3}"

#ob4=$(sbatch --dependency=afterok:${job3} "${SCRIPTS_DIR}/4_multi_split.sh" | awk '{print $4}')
#echo "Submitted 4_multi_split.sh: ${job4}"

job5=$(sbatch "${SCRIPTS_DIR}/5_filter_variants.sh" | awk '{print $4}')
echo "Submitted 5_filter_variants.sh: ${job5}"

job6=$(sbatch --dependency=afterok:${job5} "${SCRIPTS_DIR}/6_bcftools_filter.sh" | awk '{print $4}')
echo "Submitted 6_bcftools_filter.sh: ${job6}"

job7=$(sbatch --dependency=afterok:${job6} "${SCRIPTS_DIR}/7_plink_filtered.sh" | awk '{print $4}')
echo "Submitted 7_plink_filtered.sh: ${job7}"

job8=$(sbatch --dependency=afterok:${job7} "${SCRIPTS_DIR}/8_dom_only_plink.sh" | awk '{print $4}')
echo "Submitted 8_dom_only_plink.sh: ${job8}"

job9=$(sbatch --dependency=afterok:${job7} "${SCRIPTS_DIR}/8_wild_only_plink.sh" | awk '{print $4}')
echo "Submitted 8_wild_only_plink.sh: ${job9}"

job10=$(sbatch --dependency=afterok:${job6} "${SCRIPTS_DIR}/9_annotate.sh" | awk '{print $4}')
echo "Submitted 9_annotate.sh: ${job10}"

job11=$(sbatch --dependency=afterok:${job10} "${SCRIPTS_DIR}/10_mutyper_var.sh" | awk '{print $4}')
echo "Submitted 10_mutyper_var.sh: ${job11}"

job12=$(sbatch --dependency=afterok:${job11} "${SCRIPTS_DIR}/11_mutyper_spec.sh" | awk '{print $4}')
echo "Submitted 11_mutyper_spec.sh: ${job12}"

#job13=$(sbatch --dependency=afterok:${job3} "${SCRIPTS_DIR}/4_plink_1.sh" | awk '{print $4}')
#echo "Submitted 4_plink_1.sh: ${job13}"