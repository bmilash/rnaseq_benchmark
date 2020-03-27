#!/bin/bash
# run_container.sh - script to create environment necessary to run
# the rnaseq_slurm.sif container.

# Locate sbatch, get its directory name, and bind that to /usr/local/bin
# inside the container.
sbatch_path=`which sbatch`
sbatch_dir=`dirname $sbatch_path`
binds=$sbatch_dir":/usr/local/bin"
#echo "sbatch located in $sbatch_dir"

# Find libraries used by sbatch, get their directories, and make a unique
# list of them. However, avoid system libraries.
ldlibpath=""
for dir in `ldd $sbatch_path | awk 'NF==4 {print $(NF-1)}' | grep -v '^/lib' | xargs dirname | sort -u`
do
	# For each library directory, bind it into the container.
	binds=$binds","$dir
	# Also construct a LD_LIBRARY_PATH of directories within the container.
	if [ -n "$ldlibpath" ]
	then
		ldlibpath=$ldlibpath":"$dir
	else
		ldlibpath=$dir
	fi
done

# Also need to bind directory containing slurm.conf.
# Locate the slurm.conf file, and add its directory to the list of binds.
slurm_conf_file=`scontrol show config | grep SLURM_CONF | awk '{print $3}'`
slurm_conf_dir=`dirname $slurm_conf_file`
binds=$binds","$slurm_conf_dir

# Also also need to include directory where libmunge.so and the munge socket
# are. Don't know yet how to find this programmatically.
binds=$binds",/usr/lib64"
binds=$binds",/var/run/munge"

echo "binds: $binds"
echo "ldlibpath: $ldlibpath"

export SINGULARITY_BIND=$binds
export SINGULARITYENV_LD_LIBRARY_PATH=$ldlibpath

singularity run rnaseq_slurm.sif $*
#singularity shell rnaseq_slurm.sif
