#!/bin/bash
#SBATCH --job-name=prokka-QJM3NY_25
#SBATCH --partition=long
#SBATCH --time=3-0:00:00
#SBATCH --output=prokka-QJM3NY_25.%j.output
#SBATCH --nodes=1
#SBATCH --ntasks=32

# Load necessary modules & activate conda environment
module load anaconda3/2023.09-0        # Load the Anaconda module
source $(conda info --base)/etc/profile.d/conda.sh
conda activate prokka

# Run Prokka annotation on a single isolate assembly
# Update FASTA and OUTDIR to your local paths
FASTA="${FASTA:-./fastas/QJM3NY_25.fasta}"
OUTDIR="${OUTDIR:-./prokka-results/QJM3NY_25-iso_290}"

prokka "$FASTA" \
    --kingdom Bacteria \
    --addgenes \
    --addmrna \
    --rfam \
    --outdir "$OUTDIR"

conda deactivate
