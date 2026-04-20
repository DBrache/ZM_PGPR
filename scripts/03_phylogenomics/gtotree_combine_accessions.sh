#!/bin/bash

output_file="combined_output.txt"

> "$output_file"

for file in GTDB-*-genus-GTDB-rep-accs.txt; do
  cat "$file" >> "$output_file"
done
