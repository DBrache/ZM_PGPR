#!/bin/bash
# metage2metabo (M2M) v1.6.1 pipeline for MinCom selection and scope analysis.
#
# Seeds (n=73) and targets (n=30) are defined in Supplementary Table 1.
# Seeds include the 2026-01-21 seed set augmented with sucrose; targets are the
# 2026-01-16 target set (plant growth-promoting compounds: N, P, S, IAA,
# polyamines, siderophores, vitamins).
#
# Paths below reflect the local run layout; update to your own paths.

set -euo pipefail

ROOT="$HOME/metage2metabo"
GBK_DIR="$ROOT/iso_gbk"                          # 61 isolate GenBank files
RECON_DIR="$ROOT/recon"                          # GSMN reconstruction output
RUN_DIR="$ROOT/m2m_20260121"
SEEDS="$RUN_DIR/docs/seeds_20260121/seeds.sbml"
TARGETS="$RUN_DIR/docs/targets_20260116/seeds.sbml"

# --- Step 1: GSMN reconstruction (Pathway Tools v29.0 + MetaCyc via m2m recon)
m2m recon \
  -g "$GBK_DIR" \
  -o "$RECON_DIR" \
  -c 8 \
  -q

# --- Step 2: Minimal community selection (MinCom)
m2m mincom \
  -n "$RECON_DIR/sbml" \
  -s "$SEEDS" \
  -o "$RUN_DIR/mincom_20260121" \
  -t "$TARGETS" \
  -q

# --- Step 2b: Community scope of the full pool of 61 isolates
m2m cscope \
  -n "$RECON_DIR/sbml" \
  -s "$SEEDS" \
  -o "$RUN_DIR/cscope_20260121" \
  -t "$TARGETS" \
  -q

# --- Step 3a: Community scope for 5-member MinCom (MinCom-5)
m2m cscope \
  -n "$RUN_DIR/mincom_w_5" \
  -s "$SEEDS" \
  -o "$RUN_DIR/cscope_w_5_20260121" \
  -t "$TARGETS" \
  -q

# --- Step 3b: Community scope for 6-member MinCom with Agarivorans (MinCom-6)
m2m cscope \
  -n "$RUN_DIR/mincom_w_6_agar" \
  -s "$SEEDS" \
  -o "$RUN_DIR/cscope_w_6_agar_20260121" \
  -t "$TARGETS" \
  -q

# --- Step 4: Individual scope (per-isolate producible metabolites) for MinCom-6
m2m iscope \
  -n "$RUN_DIR/mincom_w_6_agar" \
  -s "$SEEDS" \
  -o "$RUN_DIR/iscope_w_6_agar_20260121" \
  -q
