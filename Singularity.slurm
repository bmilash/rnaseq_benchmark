# Singularity.slurm - singularity recipe for constructing workflow container. 
# This workflow uses SLURM to run jobs in parallel.
Bootstrap:docker
From:snakemake/snakemake

%labels
Maintainer brett.milash@utah.edu
Version 1.0.0

%files
# Copy these files to / in the container.
./config.yaml
./cluster.yaml
./Snakefile.container
./run_deseq2.r
# libhistory.so.6 is required by scontrol.
/lib64/libhistory.so /lib/libhistory.so
/lib64/libhistory.so.6 /lib/libhistory.so.6
/lib64/libhistory.so.6.2 /lib/libhistory.so.6.2

# Install additional packages and workflow files.
%post

# Ssh - this approach doesn't work, since it requires a password.
#apt-get update
#apt-get install -y openssh-client

# Workflow files:
mkdir -p /opt/workflow
mv /config.yaml /cluster.yaml /Snakefile.container /run_deseq2.r /opt/workflow

# Install other conda packages.
/opt/conda/bin/conda create -n sra-tools_env -y -c bioconda -c conda-forge sra-tools=2.10.3-0
/opt/conda/bin/conda create -n star_env -y -c bioconda star 
# Need to downgrade openssl: 1.0 is required by samtools.
# See https://github.com/bioconda/bioconda-recipes/issues/12100 .
/opt/conda/bin/conda install -n star_env -y -c bioconda samtools openssl=1.0
/opt/conda/bin/conda create -n fastqc_env -y -c bioconda fastqc
/opt/conda/bin/conda create -n multiqc_env -y -c bioconda multiqc

# Hack alert! R requires libreadline.so.6 and libncurses.5.so, so try linking
# the newer versions of those libraries to the older names.
ln -s /lib/x86_64-linux-gnu/libreadline.so.7 /lib/x86_64-linux-gnu/libreadline.so.6
ln -s /lib/x86_64-linux-gnu/libncursesw.so.5.9 /lib/x86_64-linux-gnu/libncurses.so.5

# Install R and its libraries.
/opt/conda/bin/conda create -n r_env -y -c r r-base r-yaml r-ggplot2 
/opt/conda/bin/conda install -n r_env -y -c conda-forge r-ggrepel
/opt/conda/bin/conda install -n r_env -y -c bioconda bioconductor-deseq2

# Create slurm user - needs to exist.
useradd slurm

%runscript
if [ "$1" == "--help" ]
then
	echo 'Use: singularity run siffile [--configfile config_file] [--cluster-config cluster_config_file] [other_arguments_to_snakemake]'
	exit 0
fi

date +'Starting at %R.'

# Getting error in conda startup because PS1 isn't exported. Try exporting
# it here.
if [ -z "$PS1" ]
then
	export PS1="default prompt> "
fi

# Arguments that require a default, that can be overridden:
configfile=/opt/workflow/config.yaml
clusterconfig=/opt/workflow/cluster.yaml
concurrentjobs=8
latencywait=20

otherargs=" "
while [ $# -gt 0 ]
do
	case $1 in
	'--configfile')
		shift
		configfile=$1
		shift
		;;
	'--jobs')
		shift
		concurrentjobs=$1
		shift
		;;
	'--latency-wait')
		shift
		latencywait=$1
		shift
		;;
	'--cluster-config')
		shift
		clusterconfig=$1
		shift
		;;
	*)
		otherargs=$otherargs" "$1
		shift
		;;
	esac
done

# Check if cluster config includes a reservation.
grep reservation $clusterconfig > /dev/null
if [ $? = 0 ]
then
	reservation="--reservation={cluster.reservation}"
else
	reservation=""
fi

echo "Environment:"
env

snakemake -s /opt/workflow/Snakefile.container \
	--use-singularity \
	--configfile $configfile \
	--cluster-config $clusterconfig \
	--jobscript container_jobscript.sh \
	--latency-wait $latencywait \
	--cluster "sbatch --clusters={cluster.cluster} --account={cluster.account} --partition={cluster.partition} $reservation --ntasks={cluster.ntasks} --time={cluster.time} -J '{rule}'" \
	--jobs $concurrentjobs \
	$otherargs

date +'Finished at %R.'
