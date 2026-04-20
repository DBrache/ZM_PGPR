#!/usr/bin/env python3
"""
Replace internal_N labels in App-SpaM .jplace tree with bootstrap values
from the IQ-TREE .treefile. Matches by closing-paren order since both
trees share the same topology.

The root node (internal_1, the last closing paren) has no bootstrap
counterpart in the treefile, so its label is removed.
"""

import json
import os
import re
import sys
from pathlib import Path

def extract_internal_labels_by_close_paren(newick):
    """Extract labels on internal nodes in closing-paren order."""
    labels = []
    i = 0
    while i < len(newick):
        if newick[i] == ')':
            i += 1
            # Capture the label after the closing paren
            match = re.match(r'([A-Za-z0-9_.]+)', newick[i:])
            if match:
                labels.append(match.group(1))
                i += len(match.group(1))
        else:
            i += 1
    return labels


def main():
    fig1 = Path(os.environ.get("FIG1_DIR", "./fig1"))

    treefile_path = fig1 / "ALL_ASV_filtered_aligned.treefile"
    jplace_path = fig1 / "appspam_placement_results.jplace"
    output_path = fig1 / "appspam_placement_bootstrap.jplace"

    # Read IQ-TREE treefile
    treefile_newick = treefile_path.read_text().strip()
    # Read jplace
    with open(jplace_path) as f:
        jplace = json.load(f)
    jplace_tree = jplace["tree"]

    # Extract bootstrap values from treefile (closing-paren order)
    bootstrap_labels = extract_internal_labels_by_close_paren(treefile_newick)
    # Extract internal_N labels from jplace (closing-paren order)
    internal_labels = extract_internal_labels_by_close_paren(jplace_tree)

    print(f"IQ-TREE internal nodes: {len(bootstrap_labels)}")
    print(f"jplace internal nodes:  {len(internal_labels)}")

    # Sanity check
    if len(bootstrap_labels) != len(internal_labels):
        print("WARNING: Different number of internal nodes!")
        print(f"  treefile: {len(bootstrap_labels)}")
        print(f"  jplace:   {len(internal_labels)}")

    # Build replacement map: internal_N -> bootstrap value
    replace_map = {}
    for iq_label, spam_label in zip(bootstrap_labels, internal_labels):
        if spam_label.startswith("internal_"):
            replace_map[spam_label] = iq_label

    print(f"Replacements to make: {len(replace_map)}")
    print(f"Sample mappings (first 5):")
    for k, v in list(replace_map.items())[:5]:
        print(f"  {k} -> {v}")

    # The last internal node in both is the root.
    # In the treefile, the root has no bootstrap. In the jplace it's internal_1.
    # Find the root label (last in closing-paren order)
    root_jplace = internal_labels[-1]
    root_iq = bootstrap_labels[-1]
    print(f"\nRoot node: {root_jplace} -> {root_iq}")
    print("(Root label will be removed since it has no bootstrap meaning)")

    # Perform replacements in jplace tree
    fixed_tree = jplace_tree

    # Replace internal_N labels with bootstrap values
    # Sort by length descending to avoid partial matches (internal_10 before internal_1)
    for spam_label in sorted(replace_map.keys(), key=len, reverse=True):
        bs_val = replace_map[spam_label]
        # Replace )internal_N: with )bootstrap:
        fixed_tree = fixed_tree.replace(f"){spam_label}:", f"){bs_val}:")

    # Remove root label (internal_1 if it's the root)
    # The root label appears at the very end of the tree before the semicolon
    # Pattern: )internal_1; at the end
    fixed_tree = re.sub(r'\)' + re.escape(root_jplace) + r';', ');', fixed_tree)
    # Also handle if root has edge annotation
    fixed_tree = re.sub(r'\)' + re.escape(root_jplace) + r':', '):', fixed_tree)

    # Write fixed jplace
    jplace["tree"] = fixed_tree
    with open(output_path, 'w') as f:
        json.dump(jplace, f, indent='\t')

    print(f"\nFixed jplace written to: {output_path}")

    # Verify no internal_N labels remain
    remaining = re.findall(r'internal_\d+', fixed_tree)
    if remaining:
        print(f"WARNING: {len(remaining)} internal_N labels still remain: {remaining[:10]}")
    else:
        print("All internal_N labels successfully replaced.")


if __name__ == "__main__":
    main()
