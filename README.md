# RNASeq_benchmark

This is a snakemake workflow that performs a simple RNAseq gene expression
analysis using data from experiment GSE129319 from the Gene Expression 
Omnibus.

External programs used by the workflow:
- module
- fasterq-dump (module sra-toolkit/2.10.0)
- STAR (module star/2.7.1a)
- wget
- gunzip
- samtools (module samtools/1.5)
- Rscript (module R/3.6.1)
- fastqc (module fastqc/0.11.4)
- multiqc (module multiqc/1.5)

(Plus, snakemake and python of course)
