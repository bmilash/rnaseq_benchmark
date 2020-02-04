#!/bin/bash
# snakemake.slurm - executes a Snakemake workflow on a SLURM cluster.
#SBATCH --partition=scrubpeak-shared
#SBATCH --account=chpc
#SBATCH --time=03:00:00
#SBATCH --nodes=1
date +'Starting at %R.'
echo "Running on $HOSTNAME"

# Load modules.
module load snakemake/5.6.0

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
