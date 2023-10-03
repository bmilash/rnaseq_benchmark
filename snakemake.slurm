#!/bin/bash
# snakemake.slurm - executes a Snakemake workflow on a SLURM cluster.
#SBATCH --partition=lonepeak-shared
#SBATCH --account=chpc
#SBATCH --time=03:00:00
#SBATCH --ntasks=1
#SBATCH --reservation=Oct12Downtime

bash run_workflow.sh
