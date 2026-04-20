#!/usr/bin/env python3
"""
Convert isolates_N_fasta.csv (201 isolates) to a FASTA file with
GTDB-based labels for App-SpaM and iTOL.

Header format: >Genus_species__Isolate_ID__Compartment
  - Uses GTDB taxonomy from cPCR_init_clean_taxa_2026_02_27.csv
  - Strips _WGS suffix from isolate_id for matching
  - Replaces spaces in species names with underscores

Usage: python make_isolate_fasta.py
  Reads:  isolates_N_fasta.csv and cPCR_init_clean_taxa_2026_02_27.csv
  Writes: isolates_for_appspam.fasta
"""

import csv
import sys

# --- File paths (adjust if needed) ---
fasta_csv = "isolates_N_fasta.csv"
taxa_csv = "cPCR_init_clean_taxa_2026_02_27.csv"
output_fasta = "isolates_for_appspam.fasta"

# --- Load taxonomy lookup ---
taxa_lookup = {}
with open(taxa_csv, 'r', encoding='utf-8-sig') as f:
    reader = csv.DictReader(f)
    for row in reader:
        iso_id = row['Isolate_ID'].strip()
        genus = row['Genus'].strip().replace(' ', '_')
        species = row['Species'].strip().replace(' ', '_')
        compartment = row['Compartment'].strip()
        comp_map = {'ZR': 'Rhizosphere', 'ZP': 'Rhizoplane', 'ZE': 'Endosphere', 'UN': 'Unknown'}
        comp_label = comp_map.get(compartment, compartment)
        taxa_lookup[iso_id] = {
            'genus': genus,
            'species': species,
            'compartment': comp_label
        }

# --- Convert fasta CSV to FASTA ---
n_written = 0
n_missing = 0
missing_ids = []

with open(fasta_csv, 'r', encoding='utf-8-sig') as fin, open(output_fasta, 'w') as fout:
    reader = csv.DictReader(fin)
    for row in reader:
        raw_id = row['isolate_id'].strip()
        seq = row['fasta'].strip()

        # Strip _WGS suffix for taxonomy matching
        match_id = raw_id.replace('_WGS', '')

        if match_id in taxa_lookup:
            info = taxa_lookup[match_id]
            header = f">{info['genus']}_{info['species']}__{raw_id}__{info['compartment']}"
        else:
            header = f">Isolate_{raw_id}"
            n_missing += 1
            missing_ids.append(raw_id)

        fout.write(header + '\n')
        fout.write(seq + '\n')
        n_written += 1

print(f"Wrote {n_written} sequences to {output_fasta}")
if n_missing > 0:
    print(f"WARNING: {n_missing} isolates had no taxonomy match: {', '.join(missing_ids)}")
else:
    print("All isolates matched to GTDB taxonomy.")
