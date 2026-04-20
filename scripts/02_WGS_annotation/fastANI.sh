#!/bin/bash
#SBATCH --job-name=fastANI-WGS-1
#SBATCH --output=fastANI-WGS-1.out
#SBATCH --error=fastANI-WGS-1.err
#SBATCH --partition=medium
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=10
#SBATCH --time=1-00:00:00

# Load the necessary module
module load anaconda3/2023.09-0

# Initialize conda
source $(conda info --base)/etc/profile.d/conda.sh

# Activate Conda environment
conda activate fastani

fastANI --ql fasta_paths.txt --rl fasta_paths.txt -o fastANI-1_out --matrix -t 10

conda deactivate
