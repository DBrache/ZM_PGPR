#!/bin/bash

CSV="fasta_name_map.csv"
INPUT_DIR="."
OUT="16S_db.fa"

# Clear output file
> "$OUT"

# Clean the CSV first to remove any hidden characters
sed 's/\r//g' "$CSV" > "${CSV}.clean"

echo "Processing files..."

while IFS=',' read -r oldname newname; do
  # Clean up leading/trailing whitespace and quotes
  oldname=$(echo "$oldname" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^"//;s/"$//')
  newname=$(echo "$newname" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  
  # Skip header line if it exists
  if [[ "$oldname" == "oldname" ]] || [[ "$oldname" == "old_name" ]]; then
    continue
  fi
  
  fasta="${INPUT_DIR}/${oldname}.fa"
  
  if [[ -f "$fasta" ]]; then
    echo "Processing $oldname → $newname"
    
    # Use a counter variable that we increment outside awk
    counter=0
    while IFS= read -r line; do
      if [[ $line == \>* ]]; then
        ((counter++))
        echo ">${newname}_16S_${counter}" >> "$OUT"
      else
        echo "$line" >> "$OUT"
      fi
    done < "$fasta"
    
  else
    echo "⚠️  File not found: $fasta"
  fi
done < "${CSV}.clean"

# Clean up temp file
rm -f "${CSV}.clean"

echo "✅ Concatenation complete: $OUT"
echo "Total sequences processed:"
grep -c "^>" "$OUT"
