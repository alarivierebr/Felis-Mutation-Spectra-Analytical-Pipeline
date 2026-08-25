Updating the files in here and cleaning it up now! Please wait to read until I'm finished!

Information about this code will go here!


# Configuration


```bash

```
The `run_pipeline.sh` file executes the bash scripts contained in the scripts folder, using the pathways and directories set up in `project_config`. It requires a list of g.vcf files from the nf-core/sarek workflow. It is designed to operate on a SLURM High Power Computing Cluster. SLURM Settings are left blank, please edit them according to your HPC's requirements. An example of the settings that can be used is as follows:

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