# Singularity - singularity recipe for construction workflow container.
Bootstrap:docker
From:snakemake/snakemake:v5.7.0

%labels
Maintainer brett.milash@utah.edu
Version 1.0.0

%files
# Copy these files to / in the container.
./config.yaml
./cluster.yaml
./Snakefile.benchmark

# Install additional packages.
%post
conda install -y -c bioconda sra-tools
conda install -y -c bioconda star
conda install -y -c bioconda samtools
conda install -y -c bioconda fastqc
conda install -y -c bioconda multiqc
conda install -y -c conda-forge r-base
# Innstall R libraries used in the workflow.
conda install -y r-DESeq2
conda install -y r-yaml
conda install -y r-ggplot2
conda install -y r-ggrepel

%runscript
# Default configuration file:
configfile=/config.yaml
# Determine configuration file.
if [ $# != 0 ]
then
	if [ $1 = "--config" ]
	then
		shift
		# Use next argument as config file. Exit if it doesn't exist.
		configfile=$1
		echo "Using configuration file $configfile."
		if [ ! -f $configfile ]
		then
			echo "Configuration file $configfile doesn't exist. Exiting."
			exit 1
		fi
		shift
	fi
fi
echo "Generating directed acyclic graph diagram -> dag.png"
snakemake -s /Snakefile.benchmark --configfile $configfile --dag | dot -Tpng > dag.png
echo "Generating rule graph diagram -> rulegraph.png"
snakemake -s /Snakefile.benchmark --configfile $configfile --rulegraph | dot -Tpng > rulegraph.png
echo "Running snakemake with remaining arguments ( $* )."
sh run_workflow.sh --configfile $configfile $*
