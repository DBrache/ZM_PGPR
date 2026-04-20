#!/bin/bash
#SBATCH --job-name=GTDBtk-clasify-wf
#SBATCH --time=24:00:00
#SBATCH --partition=medium
#SBATCH --ntasks=1
#SBATCH --mem=128G                  # pplacer OOMs below this
#SBATCH --cpus-per-task=2           # 4 CPU ran out of memory
#SBATCH --output=GTDBtk-clasify.%j.output

# GTDB-Tk v2.4.0 classify_wf for taxonomic assignment of 61 WGS isolates
# against GTDB r220. --skip_ani_screen is used because FastANI was run
# separately (see fastANI.sh). Genomes processed in splits due to memory.

module load anaconda3/2023.09-0
source $(conda info --base)/etc/profile.d/conda.sh

conda activate gtdbtk-2.4.0

GENOME_DIR="${GENOME_DIR:-./fastas/split1}"
OUT_DIR="${OUT_DIR:-./gtdbtk_out/split1}"

gtdbtk classify_wf \
  --genome_dir "$GENOME_DIR" \
  --out_dir    "$OUT_DIR" \
  --extension fasta \
  --skip_ani_screen \
  --cpus 2

conda deactivate
