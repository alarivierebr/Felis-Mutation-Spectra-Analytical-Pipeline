
![Pipeline Flowchart](https://github.com/alarivierebr/Felis-Mutation-Spectra-Analytical-Pipeline/blob/main/docs/Filtering%20Pipeline%20Flowchart%20Larger.PNG?raw=true)


Whole Genome Sequence Analytical Pipeline for Variant Calling & Mutation Spectra Analysis

# Configuration

The `run_pipeline.sh` file executes all of the bash scripts except `1_glnexus.sh` and `2_glnexus_concat.sh` which are recommended to be executed manually. All scripts are contained in the scripts directory. The `run_pipeline.sh` script uses the pathways and directories set up in `project_config`. 

`1_glnexus.sh` requires a list of g.vcf files from the nf-core/sarek workflow. 

All plotting scripts require the libraries listed at the top of the scripts.

CORRECT_COUNTS courtesy of [nSPECTRa](https://github.com/evotools/nSPECTRa/blob/main/bin/CORRECT_COUNTS)

This analytical pipeline is designed to operate on a SLURM High Power Computing Cluster. SLURM Settings are left blank, please edit them according to your HPC's requirements. An example of the settings that can be used is as follows:

```bash
#!/bin/bash -l

############# SLURM SETTINGS #############

#SBATCH --account=youraccountname
#SBATCH --job-name=jobname
#SBATCH --time=48:00:00
#SBATCH --partition=hpc_partition_name
#SBATCH --cpus-per-task=4
#SBATCH --mem=256G

#SBATCH --output=<filepath_to_logs_folder>/%x-%A_%a.out
#SBATCH --error=<filepath_to_errorlogs_folder>/%x-%A_%a.err

```
# Dependencies

| Tool	| Version |
|-------| ------- |
|bcftools |	1.24  |
|GLNexus |	1.4.1 |
|mutyper |	1.0.2 |
|nf-core/sarek |	25.10.4|
|plink2 |	2.0.0a.6.9 |
|pysam	| 0.23.3  |
|python	|3.11.15, 3.14.16|
|R	|4.5.3 |
|[smakcr](https://github.com/julibeg/smakcr) |
