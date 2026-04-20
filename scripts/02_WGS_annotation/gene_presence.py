import os
import pandas as pd

# Function to search for all GFF files in a directory and its subdirectories
def find_gff_files(base_dir):
    gff_files = []
    for root, dirs, files in os.walk(base_dir):  # Traverse subdirectories
        for file in files:
            if file.endswith(".gff"):
                gff_files.append(os.path.join(root, file))
    return gff_files

# Specify the base directory where your GFF files are stored
base_directory = os.environ.get("PROKKA_DIR", "./prokka-results")  # override via env or edit here

# Read the list of gene names and gene IDs from a TXT file (two columns)
gene_list_df = pd.read_csv("gene_list.txt", sep="\t", header=None, names=["Gene Name", "Gene ID"], quotechar='"')
gene_dict = dict(zip(gene_list_df["Gene ID"], gene_list_df["Gene Name"]))  # Switch to using Gene ID as key

# Find all GFF files in the specified base directory and its subdirectories
gff_files = find_gff_files(base_directory)

# Initialize presence/absence dictionary using gene IDs as keys
presence_matrix = {gene_id: {gff: 0 for gff in gff_files} for gene_id in gene_dict}

# Scan each GFF file
for gff in gff_files:
    with open(gff) as f:
        for line in f:
            if line.startswith("#"):  # Skip comments
                continue
            fields = line.strip().split("\t")
            if len(fields) < 9:
                continue  # Ensure it has enough columns
            attributes = fields[8]  # 9th column (attributes)
            for gene_id in gene_dict:
                if gene_id in attributes:  # Check if gene ID appears in attributes
                    presence_matrix[gene_id][gff] = 1

# Convert dictionary to DataFrame
df = pd.DataFrame.from_dict(presence_matrix, orient="index")
df.index.name = "Gene ID"
df.to_csv("gene_presence_matrix.txt", sep="\t")

print("Gene presence/absence matrix saved as 'gene_presence_matrix.txt'.")

