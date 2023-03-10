#!/bin/bash
#SBATCH -n 1
#SBATCH -N 1
#SBATCH --mem=4G
#SBATCH	-p shared
#SBATCH -t 5-00:00
#SBATCH -o snakemake.out
#SBATCH -e snakemake.err
#SBATCH --mail-type=END
#SBATCH --mail-user=mortimer@hsph.harvard.edu
#SBATCH --account=grad_lab

mkdir -p logs/slurm
snakemake -k --rerun-incomplete --profile slurm_genomics_pipeline
