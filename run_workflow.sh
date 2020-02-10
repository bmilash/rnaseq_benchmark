#!/bin/bash
# run_workflow.sh - executes a Snakemake workflow on a SLURM cluster.
# This script is designed to by executed by hand or within the 
# container, not as a standalone SLURM script.
date +'Starting at %R.'
echo "Running on $HOSTNAME"

cluster_config="cluster.yaml"
# Check if cluster config includes a reservation.
grep reservation $cluster_config > /dev/null
if [ $? = 0 ]
then
	reservation="--reservation={cluster.reservation}"
else
	reservation=""
fi

snakemake -s Snakefile.benchmark \
	--cluster-config cluster.yaml \
	--latency-wait 20 \
	--cluster "sbatch --clusters={cluster.cluster} --account={cluster.account} --partition={cluster.partition} $reservation --ntasks={cluster.ntasks} --time={cluster.time} -J '{rule}'" \
	--jobs 20

date +'Finished at %R.'
