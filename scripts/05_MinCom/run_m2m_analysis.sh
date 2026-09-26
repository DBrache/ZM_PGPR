#!/bin/bash
# m2m_analysis workflow: enumerates ALL minimal communities (32 solutions of size 5)
# and builds the boolean equation / power-graph used for the MinCom selection figure.
#
# Prerequisites (conda env "m2m"): graphviz, networkx, powergrasp, ete3, legacy-cgi
# Oog.jar: https://github.com/AuReMe/metage2metabo/tree/main/external_dependencies/Oog_CommandLineTool2012
# Paths reflect the local run layout; update to your own paths.

set -euo pipefail

ROOT="$HOME/metage2metabo"
RUN_DIR="$ROOT/m2m_20260121"
SEEDS="$RUN_DIR/docs/seeds_20260121/seeds.sbml"
TARGETS="$RUN_DIR/docs/targets_20260116/seeds.sbml"

m2m_analysis workflow \
  -n "$ROOT/recon/sbml" \
  -s "$SEEDS" \
  -t "$TARGETS" \
  -o "$RUN_DIR/m2m_analysis_output" \
  --oog "$ROOT/Oog.jar"
