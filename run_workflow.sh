#!/bin/bash
# run_workflow.sh - executes a Snakemake workflow on a SLURM cluster.
# This script is designed to by executed by hand or within the 
# container, not as a standalone SLURM script.
date +'Starting at %R.'
echo "Running on $HOSTNAME"

# Find location of this script - that will be the location of the snakefile,
# the config file and the cluster config file.
scriptdir=`dirname $0`

# Determine if a target name was specified on the command line.
target=""
if [ -n "$1" ]
then
	target=$1
fi

# Load snakemake module if necessary.
which snakemake >/dev/null 2>&1
if [ $? -ne 0 ]
then
	module load snakemake/5.6.0
fi

# Check if cluster config includes a reservation.
cluster_config="$scriptdir/cluster.yaml"
grep reservation $cluster_config > /dev/null
if [ $? = 0 ]
then
	reservation="--reservation={cluster.reservation}"
else
	reservation=""
fi

# Run snakemake.
snakemake -s $scriptdir/Snakefile.benchmark \
	--cluster-config $cluster_config \
	--configfile $scriptdir/config.yaml \
	--latency-wait 20 \
	--cluster "sbatch --clusters={cluster.cluster} --account={cluster.account} --partition={cluster.partition} $reservation --ntasks={cluster.ntasks} --time={cluster.time} -J '{rule}'" \
	--jobs 8 \
	$target

date +'Finished at %R.'
