#!/bin/bash
# snakemake.slurm - executes a Snakemake workflow on a SLURM cluster.
#SBATCH --partition=scrubpeak-shared
#SBATCH --account=chpc
#SBATCH --time=03:00:00
#SBATCH --nodes=1

bash run_workflow.sh
