all: rnaseq_slurm.sif rnaseq_local.sif 

rnaseq_slurm.sif: Singularity.slurm Snakefile.container config.yaml cluster.yaml run_deseq2.r
	rm -f rnaseq_slurm.sif
	sudo singularity build rnaseq_slurm.sif Singularity.slurm

rnaseq_local.sif: Singularity.local Snakefile.container
	rm -f rnaseq_local.sif
	sudo singularity build rnaseq_local.sif Singularity.local
