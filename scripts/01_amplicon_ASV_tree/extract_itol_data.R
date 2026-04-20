## Extract ASV taxonomy and per-compartment counts for iTOL annotations
## Run AFTER executing NanoASV_GTDB_ZMcompartment_clean.Rmd through section 4
## (so that Nano_filtered exists in your environment).

fig1 <- "./itol_out"
dir.create(fig1, showWarnings = FALSE, recursive = TRUE)

# --- 1. ASV taxonomy (for class coloring strip) ---
tax_df <- as.data.frame(tax_table(Nano_filtered))
tax_df$ASV_ID <- rownames(tax_df)

write.csv(
  tax_df[, c("ASV_ID", "Kingdom", "Phylum", "Class", "Order", "Family", "Genus", "Species")],
  file.path(fig1, "asv_taxonomy_for_itol.csv"),
  row.names = FALSE
)

cat(sprintf("Exported %d ASV taxonomy rows\n", nrow(tax_df)))

# --- 2. Per-compartment ASV counts (for compartment bar chart) ---
otu_mat <- as.data.frame(otu_table(Nano_filtered))
sample_df <- data.frame(sample_data(Nano_filtered))

# Sum counts per ASV per compartment (excluding control)
asv_comp_counts <- do.call(rbind, lapply(taxa_names(Nano_filtered), function(asv) {
  counts <- tapply(as.numeric(otu_mat[asv, ]), sample_df$compartment, sum)
  data.frame(
    ASV_ID = asv,
    rhiz = as.integer(counts["Rhiz"]),
    plan = as.integer(counts["plan"]),
    endo = as.integer(counts["endo"])
  )
}))
asv_comp_counts[is.na(asv_comp_counts)] <- 0

write.csv(asv_comp_counts,
  file.path(fig1, "asv_compartment_counts_for_itol.csv"),
  row.names = FALSE
)

cat(sprintf("Exported %d ASV compartment count rows\n", nrow(asv_comp_counts)))
cat("Done! Files written to fig1/\n")
