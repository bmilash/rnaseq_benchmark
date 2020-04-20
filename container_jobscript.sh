#!/bin/sh
# Custom jobscript for containerized workflow.
# properties = {properties}
#echo "$0 command $*"
cp $0 jobscript.$SLURMD_NODENAME.$SLURM_JOBID
#if [ -d /opt/conda ]
echo "/etc/os-release:"
cat /etc/os-release
echo "PATH:"
echo $PATH
echo $PATH | grep "/opt/conda" > /dev/null
#if [ -d /opt/conda ]
if [ $? -eq 0 ]
then
# Inside container.
echo "$0: Executing command inside container."
{exec_job}
else
# Outside container.
echo "$0: Executing command from outside container."
#env
which singularity > /dev/null
if [ $? -eq 1 ]
then
	module load singularity
else
	echo "Singularity already loaded."
fi
singularity shell rnaseq_slurm.sif <<END_OF_INPUT
{exec_job}
END_OF_INPUT
fi
