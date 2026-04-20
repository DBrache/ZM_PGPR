#!/bin/bash
#SBATCH --job-name=mafft_iqtree_fig1_ASV_cPRtree_20260227
#SBATCH --partition=cenvalarc.bigmem
#SBATCH --time=1-00:00:00
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --output=mafft_iqtree_fig1_ASV_cPRtree_20260227.out
#SBATCH --error=mafft_iqtree_fig1_ASV_cPRtree_20260227.err

# MAFFT alignment + IQ-TREE 2 ML reference tree for Fig 1
# Input : ALL_ASV_filtered.fasta  (2,378 decontam-filtered GTDB r226 ASVs)
# Output: ALL_ASV_filtered_aligned.fasta, *.treefile (GTR+G, 5000 UFBoot)

module load anaconda3/2023.09-0
source $(conda info --base)/etc/profile.d/conda.sh

# Step 1: MAFFT alignment
conda activate mafft
mafft --thread 64 --adjustdirectionaccurately ALL_ASV_filtered.fasta > ALL_ASV_filtered_aligned.fasta
conda deactivate

# Step 2: IQ-TREE phylogeny
conda activate iqtree
iqtree -s ALL_ASV_filtered_aligned.fasta -m GTR+G -bb 5000 -T AUTO
conda deactivate
