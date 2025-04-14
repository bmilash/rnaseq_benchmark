#!/bin/bash
# run_workflow.sh - executes a Snakemake workflow on a SLURM cluster.
# This script is designed to be executed by hand or within the 
# container, not as a standalone SLURM script.
#

# Find location of this script - that will be the location of the snakefile.
scriptdir=`dirname $0`
# Default number of concurrent jobs:
numjobs=40
# Default configuration file for all but cluster configuration:
configfile=$scriptdir"/config.yaml"
# Default cluster configuration:
clustername=$(echo $UUFSCELL | cut -d . -f 1)
otherargs=""
reservation=""

# Process command line arguments.
while [ -n "$1" ]
do
	if [ $1 = "-h" ]
	then
		echo "Use: $0 [--cluster clustername] [--reservation reservationname] [--configfile config.yaml] [--jobs numjobs] [additional optional args]"
		echo 'clustername defaults to current cluster (defined by $UUFSCELL variable)'
		echo "number of concurrent jobs defaults to $numjobs"
		exit 1
	fi
	if [ $1 = "--configfile" ]
	then
		shift
		configfile=$1
		shift
		continue
	fi
	if [ $1 = "--reservation" ]
	then
		shift
		reservationname=$1
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
		clustername=$1
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

date +'Starting at %R.'
echo "Running on $HOSTNAME"

clusterconfig="ClusterConfigs/"$clustername".yaml"

if [ ! -f $clusterconfig ]
then
	echo "Problem: cluster configuration file $clusterconfig not found."
	exit 1
fi

echo "clustername: $clustername"
echo "clusterconfig: $clusterconfig"
echo "configfile: $configfile"
echo "otherargs: $otherargs"

# Function to wrap sbatch.
function mysbatch () {
	cluster=$1
	shift
	partition=$1
	shift
	qos=$1
	shift
	account=$1
	shift
	rule=$1
	shift
	runtime=$1
	shift
	memory=$1
	shift
	sbatch -M $cluster -p $partition -q $qos -A $account -J $rule --time=$runtime --mem=$memory $* | cut -d' ' -f4
}

export -f mysbatch

# Load snakemake module if necessary.
which snakemake >/dev/null 2>&1
if [ $? -ne 0 ]
then
	module load snakemake/9.1.9
fi

if [ -n "$reservationname" ]
then
	reservation="--reservation=$reservationname"
else
	reservation=""
fi

# Run snakemake.
set -x
#snakemake -s $scriptdir/Snakefile.benchmark \
#	--cluster-config $clusterconfig \
#	--configfile $configfile \
#	--latency-wait 60 \
#	--cluster "mysbatch {cluster.cluster} {cluster.partition} {cluster.qos} {cluster.account} {rule} {cluster.time} {cluster.memory} $reservation" \
#	--cluster-cancel scancel \
#	--jobs $numjobs \
#	$otherargs

snakemake --snakefile $scriptdir/Snakefile.benchmark \
	--workflow-profile $scriptdir/profiles/$clustername \
	--configfile $configfile \
	$otherargs

if [ $? -eq 0 ]
then
	date +'Finished successfully at %R.'
else
	date +'Finished with error at %R.'
fi
