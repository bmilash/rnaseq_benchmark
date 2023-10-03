#!/bin/bash
# run_workflow.sh - executes a Snakemake workflow on a SLURM cluster.
# This script is designed to be executed by hand or within the 
# container, not as a standalone SLURM script.
#
# Use:
# sh run_workflow.sh [ --configfile config.yaml] [--cluster cluster.yaml] [additional optional args]
date +'Starting at %R.'
echo "Running on $HOSTNAME"

# Find location of this script - that will be the location of the snakefile.
scriptdir=`dirname $0`
# Default number of concurrent jobs:
numjobs=20
# Default configuration file for all but cluster configuration:
configfile=$scriptdir"/config.yaml"
# Default cluster configuration:
clusterconfig=$scriptdir/"cluster.yaml"
otherargs=""

# Process command line arguments.
while [ -n "$1" ]
do
	if [ $1 = "-h" ]
	then
		echo "Use: $0 [ --configfile config.yaml] [--cluster cluster.yaml] [additional optional args]"
		exit 1
	fi
	if [ $1 = "--configfile" ]
	then
		shift
		configfile=$1
		shift
		continue
	fi
	if [ $1 = "--jobs" ]
	then
		shift
		numjobs=$1
		shift
		continue
	fi
	if [ $1 = "--cluster" ]
	then
		shift
		clusterconfig=$1
		shift
		continue
	fi
	if [ -n "$otherargs" ]
	then
		otherargs=$otherargs" "
	fi
	otherargs=$otherargs$1
	shift
done

echo "configfile: $configfile"
echo "clusterconfig: $clusterconfig"
echo "otherargs: $otherargs"

# Function to wrap sbatch.
function mysbatch () {
	cluster=$1
	shift
	partition=$1
	shift
	account=$1
	shift
	rule=$1
	shift
	runtime=$1
	shift
	memory=$1
	shift
	sbatch -M $cluster -p $partition -A $account -J $rule --time=$runtime --mem=$memory $* | cut -d' ' -f4
}

export -f mysbatch


# Load snakemake module if necessary.
which snakemake >/dev/null 2>&1
if [ $? -ne 0 ]
then
<<<<<<< HEAD
	module load snakemake
fi

# Check if cluster config includes a reservation.
grep reservation $clusterconfig > /dev/null
=======
	module load snakemake/6.4.1
fi

#configfile=$2
configfile=config.yaml
# Check if cluster config includes a reservation.
#cluster_config=$4
cluster_config=cluster.yaml
grep reservation $cluster_config > /dev/null
>>>>>>> adccc05135bda3fa78ce1a34dcc0a912b5a77fa1
if [ $? = 0 ]
then
	reservation="--reservation={cluster.reservation}"
else
	reservation=""
fi

# Run snakemake.
<<<<<<< HEAD
set -x
snakemake -s $scriptdir/Snakefile.benchmark \
	--cluster-config $clusterconfig \
	--configfile $configfile \
	--latency-wait 60 \
	--cluster "mysbatch {cluster.cluster} {cluster.partition} {cluster.account} {rule} {cluster.time} {cluster.memory} $reservation" \
	--cluster-cancel scancel \
	--jobs $numjobs \
	$otherargs

if [ $? -eq 0 ]
then
	date +'Finished successfully at %R.'
else
	date +'Finished with error at %R.'
fi
=======
snakemake -s $scriptdir/Snakefile.benchmark \
	--cluster-config $cluster_config \
	--configfile $configfile \
	--latency-wait 20 \
	--cluster "sbatch --clusters={cluster.cluster} --account={cluster.account} --partition={cluster.partition} $reservation --ntasks={cluster.ntasks} --time={cluster.time} -J '{rule}'" \
	--jobs 8 \
	$target

date +'Finished at %R.'
>>>>>>> adccc05135bda3fa78ce1a34dcc0a912b5a77fa1
