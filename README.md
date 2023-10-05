# RNASeq_benchmark

This is a snakemake workflow that performs a simple RNAseq gene expression
analysis using data from experiment GSE129319 from the Gene Expression 
Omnibus.

We are using this workflow to exercise our SLURM clusters following a maintenance
downtime, and this is not intended as a proper modern way to process RNAseq gene
expression data.

Use:

```
./run_workflow.sh
```
Runs the workflow on current cluster using no reservation.
```
./run_workflow.sh --cluster clustername
```
Runs the workflow on named cluster using no reservation.
./run_workflow.sh --reservation reservationname
```
Runs workflow on current cluster under the named reservation.
```
./run_workflow -n
```
Performs dry run, showing which tasks would get executed.
```
./run_workflow clean
```
Similar to 'make clean', removes all output and intermediate files.

External programs used by the workflow:
- module
- fasterq-dump (module sra-toolkit/2.10.0)
- STAR (module star/2.7.10a)
- wget
- gunzip
- samtools (module samtools/1.16)
- Rscript (module R/4.1.3)
- fastqc (module fastqc/0.11.4)
- multiqc (module multiqc/1.12)

(Plus, snakemake and python of course)
