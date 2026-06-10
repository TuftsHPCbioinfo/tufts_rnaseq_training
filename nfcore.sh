#!/bin/bash
#SBATCH --job-name=nfcore
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=8g
#SBATCH --partition=batch
#SBATCH --output=nfcore_%j.out
#SBATCH --error=nfcore_%j.err

module load nextflow
export NXF_SINGULARITY_CACHEDIR=/cluster/tufts/apps/container/biocontainers/nf-core/singularity-images/
nextflow run /cluster/tufts/apps/container/biocontainers/nf-core/pipelines/nf-core-rnaseq/3.26.0/3_26_0/ -params-file nf-params.json 