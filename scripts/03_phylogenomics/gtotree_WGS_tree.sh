#!/bin/bash
#SBATCH --job-name=WGS-only
#SBATCH --time=14:00:00
#SBATCH --partition=medium
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=50
#SBATCH --output=WGS-only-tree.%j.output

# GToTree phylogenomic tree of 61 WGS isolates (Fig 2).
# Uses the Bacteria single-copy gene set; internally runs MAFFT alignment
# and IQ-TREE with the best-fit substitution model and 1000 bootstrap replicates.
# Input : fasta_file_paths.txt, file-label-manifest.tsv
# Output: WGS-isolate-tree/

module load anaconda3/2023.09-0
source $(conda info --base)/etc/profile.d/conda.sh

conda activate gtotree

# -D : swap input accessions for GTDB taxonomy on the final tree
# -m : custom genome labels from manifest
GToTree \
  -f fasta_file_paths.txt \
  -H Bacteria \
  -D \
  -t \
  -L Family,Genus,Species \
  -j 50 \
  -o WGS-isolate-tree \
  -m file-label-manifest.tsv

conda deactivate
