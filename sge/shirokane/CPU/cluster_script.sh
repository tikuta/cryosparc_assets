#!/bin/bash

#$ -N cryosparc_{{ project_uid }}_{{ job_uid }}

#$ -pe def_slot {{ num_cpu }}

#$ -l s_vmem={{ s_vmem }}

## Time limit 4 days
#$ -l h_rt={{ h_rt }}

## STDOUT/STDERR
#$ -o {{ job_dir_abs }}/cluster.out
#$ -e {{ job_dir_abs }}/cluster.err
#$ -j y

## Number of threads
export OMP_NUM_THREADS={{ num_cpu }}

echo "HOSTNAME: $HOSTNAME"

{{ run_cmd }}
