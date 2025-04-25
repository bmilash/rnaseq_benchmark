#!/bin/bash
#SBATCH --partition=notchpeak-dtn
#SBATCH --qos=notchpeak-dtn
#SBATCH --account=dtn

genome_url=ftp://ftp.ensembl.org/pub/release-98/fasta/saccharomyces_cerevisiae/dna/Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.fa.gz
genome_fasta=Genome/Saccharomyces_cerevisiae.R64-1-1.dna.toplevel.fa

mkdir -p $(dirname $genome_fasta)
cd $(dirname $genome_fasta)
wget $genome_url
gunzip $(basename $genome_fasta)
