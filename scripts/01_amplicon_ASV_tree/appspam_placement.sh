#!/bin/bash
#SBATCH --job-name=appspam_20260301
#SBATCH --partition=long
#SBATCH --time=3-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=28
#SBATCH --output=appspam_20260301.out
#SBATCH --error=appspam_20260301.err

# App-SpaM phylogenetic placement of isolate 16S (colony PCR + WGS-extracted)
# onto the ASV reference tree for Fig 1.

module load anaconda3
source $(conda info --base)/etc/profile.d/conda.sh

conda activate App-SpaM

appspam \
  -s ALL_ASV_filtered_aligned.fasta \
  -q combined_16S_unaligned.fasta \
  -t ALL_ASV_filtered_aligned.treefile \
  --threads 28

conda deactivate
