#!/bin/bash

# Locate sbatch, get its directory name, and bind that to /usr/local/bin
# inside the container.
sbatch_path=`which sbatch`
sbatch_dir=`dirname $sbatch_path`
binds=$sbatch_dir":/usr/local/bin"
#echo "sbatch located in $sbatch_dir"

# Find libraries used by sbatch, get their directories, and make a unique
# list of them. However, avoid system libraries.
# Also need to bind directory containing slurm.conf. On notchpeak
# this is /uufs/notchpeak.peaks/sys/var/slurm/etc.
ldlibpath=""
for dir in `ldd $sbatch_path | grep 'libslurm' | awk 'NF==4 {print $(NF-1)}' | xargs dirname | sort -u`
do
	# For each library directory, bind it into a subdirectory of /opt.
	if [ -n "$binds" ]
	then
		binds=$binds","
	fi
	binds=$binds"$dir:/opt"$dir
	# Also construct a LD_LIBRARY_PATH of directories within the container.
	if [ -n "$ldlibpath" ]
	then
		ldlibpath=$ldlibpath":"
	fi
	ldlibpath=$ldlibpath"/opt"$dir
done

echo "binds: $binds"
echo "ldlibpath: $ldlibpath"

export SINGULARITY_BIND=$binds
export SINGULARITYENV_LD_LIBRARY_PATH=$ldlibpath

#singularity run rnaseq.sif --cluster-config cluster_np.yaml
singularity run rnaseq_local.sif
