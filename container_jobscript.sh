#!/bin/sh
# Custom jobscript for containerized workflow.
# properties = {properties}
echo "$? command $*"
env | grep "^SINGULARITY_NAME=" > /dev/null
if [ -d /opt/conda ]
then
# Inside container.
echo "$0: Executing command inside container."
{exec_job}
else
# Outside container.
echo "$0: Executing command from outside container."
env
module load singularity
singularity shell rnaseq_slurm.sif <<END_OF_INPUT
{exec_job}
END_OF_INPUT
fi
