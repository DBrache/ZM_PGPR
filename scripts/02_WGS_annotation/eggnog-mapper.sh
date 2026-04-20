#!/bin/bash
#SBATCH --job-name=eggnog-mapper-WGS-1
#SBATCH --output=eggnog-mapper-WGS-1.out
#SBATCH --error=eggnog-mapper-WGS-1.err
#SBATCH --partition=long
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=200G
#SBATCH --time=3-00:00:00

# Load the necessary module
module load anaconda3/2023.09-0

# Initialize conda
source $(conda info --base)/etc/profile.d/conda.sh

# Activate Conda environment
conda activate eggnog-mapper

# Set the eggNOG database path (override EGGNOG_DATA_DIR if not set in Conda env)
export EGGNOG_DATA_DIR="${EGGNOG_DATA_DIR:-/path/to/egg-nog-data}"

# Print diagnostic information
echo "PATH: $PATH"
which emapper.py
echo "EGGNOG_DATA_DIR: $EGGNOG_DATA_DIR"
echo "Script started at $(date)"

# Directory containing all .faa files (Prokka output)
FAA_DIR="${FAA_DIR:-./faa_files}"

# Output directory for eggNOG-mapper results
OUTPUT_DIR="${OUTPUT_DIR:-./eggnog-out}"
mkdir -p $OUTPUT_DIR

# Loop through each .faa file
for FAA_FILE in $FAA_DIR/*.faa; do
    # Extract isolate name from filename
    ISOLATE_NAME=$(basename $FAA_FILE .faa)
    echo "Processing isolate: $ISOLATE_NAME at $(date)"
    
    # Create output directory for this isolate
    ISOLATE_OUTPUT_DIR="$OUTPUT_DIR/$ISOLATE_NAME"
    mkdir -p $ISOLATE_OUTPUT_DIR
    
    # Run eggNOG-mapper with correct parameters based on your version
    emapper.py -i $FAA_FILE -o $ISOLATE_NAME --output_dir $ISOLATE_OUTPUT_DIR --cpu $SLURM_CPUS_PER_TASK 
    
    echo "Finished processing $ISOLATE_NAME at $(date)"
    echo "--------------------------------"
done

echo "All eggNOG-mapper runs completed at $(date)"

# After finishing all isolates, create the presence/absence matrices
KEGG_MATRIX="$OUTPUT_DIR/kegg_presence_absence.csv"
PFAM_MATRIX="$OUTPUT_DIR/pfam_presence_absence.csv"
CAZY_MATRIX="$OUTPUT_DIR/cazy_presence_absence.csv"

# Create header for KEGG matrix
echo "Collecting unique KEGG IDs..."
echo -n "Isolate," > $KEGG_MATRIX
find $OUTPUT_DIR -name "*.emapper.annotations" | xargs cat | grep -v "^#" | awk -F'\t' '{if ($12!="") {split($12,a,","); for(i in a) {gsub(/ko:/, "", a[i]); print a[i]}}}' | sort | uniq | tr '\n' ',' | sed 's/,$/\n/' >> $KEGG_MATRIX

# Create header for Pfam matrix
echo "Collecting unique Pfam IDs..."
echo -n "Isolate," > $PFAM_MATRIX
find $OUTPUT_DIR -name "*.emapper.annotations" | xargs cat | grep -v "^#" | awk -F'\t' '{if ($20!="") {split($20,a,","); for(i in a) {gsub(/PF/, "", a[i]); gsub(/\.[0-9]+/, "", a[i]); print "PF"a[i]}}}' | sort | uniq | tr '\n' ',' | sed 's/,$/\n/' >> $PFAM_MATRIX

# Create header for CAZy matrix
echo "Collecting unique CAZy IDs..."
echo -n "Isolate," > $CAZY_MATRIX
find $OUTPUT_DIR -name "*.emapper.annotations" | xargs cat | grep -v "^#" | awk -F'\t' '{if ($21!="") {split($21,a,","); for(i in a) print a[i]}}' | sort | uniq | tr '\n' ',' | sed 's/,$/\n/' >> $CAZY_MATRIX

# Get list of all unique IDs for each database
KEGG_IDS=($(head -1 $KEGG_MATRIX | sed 's/Isolate,//' | tr ',' '\n'))
PFAM_IDS=($(head -1 $PFAM_MATRIX | sed 's/Isolate,//' | tr ',' '\n'))
CAZY_IDS=($(head -1 $CAZY_MATRIX | sed 's/Isolate,//' | tr ',' '\n'))

# Process each isolate
for ISOLATE_DIR in $OUTPUT_DIR/*/; do
    ISOLATE=$(basename $ISOLATE_DIR)
    echo "Processing matrix for $ISOLATE..."
    
    ANNOTATION_FILE=$(find $ISOLATE_DIR -name "*.emapper.annotations" -type f)
    if [ -z "$ANNOTATION_FILE" ]; then
        echo "No annotation file found for $ISOLATE. Skipping..."
        continue
    fi
    
    # Process KEGG IDs
    echo -n "$ISOLATE," >> $KEGG_MATRIX
    ISOLATE_KEGGS=$(grep -v "^#" $ANNOTATION_FILE | awk -F'\t' '{if ($12!="") {split($12,a,","); for(i in a) {gsub(/ko:/, "", a[i]); print a[i]}}}' | sort | uniq)
    for ID in "${KEGG_IDS[@]}"; do
        if echo "$ISOLATE_KEGGS" | grep -q "^$ID$"; then
            echo -n "1," >> $KEGG_MATRIX
        else
            echo -n "0," >> $KEGG_MATRIX
        fi
    done
    sed -i 's/,$/\n/' $KEGG_MATRIX
    
    # Process Pfam IDs
    echo -n "$ISOLATE," >> $PFAM_MATRIX
    ISOLATE_PFAMS=$(grep -v "^#" $ANNOTATION_FILE | awk -F'\t' '{if ($20!="") {split($20,a,","); for(i in a) {gsub(/PF/, "", a[i]); gsub(/\.[0-9]+/, "", a[i]); print "PF"a[i]}}}' | sort | uniq)
    for ID in "${PFAM_IDS[@]}"; do
        if echo "$ISOLATE_PFAMS" | grep -q "^$ID$"; then
            echo -n "1," >> $PFAM_MATRIX
        else
            echo -n "0," >> $PFAM_MATRIX
        fi
    done
    sed -i 's/,$/\n/' $PFAM_MATRIX
    
    # Process CAZy IDs
    echo -n "$ISOLATE," >> $CAZY_MATRIX
    ISOLATE_CAZYS=$(grep -v "^#" $ANNOTATION_FILE | awk -F'\t' '{if ($21!="") {split($21,a,","); for(i in a) print a[i]}}' | sort | uniq)
    for ID in "${CAZY_IDS[@]}"; do
        if echo "$ISOLATE_CAZYS" | grep -q "^$ID$"; then
            echo -n "1," >> $CAZY_MATRIX
        else
            echo -n "0," >> $CAZY_MATRIX
        fi
    done
    sed -i 's/,$/\n/' $CAZY_MATRIX
done

# Deactivate conda environment before exiting
conda deactivate

echo "Created KEGG matrix: $KEGG_MATRIX"
echo "Created Pfam matrix: $PFAM_MATRIX"
echo "Created CAZy matrix: $CAZY_MATRIX"

echo "All processing complete! $(date)"
