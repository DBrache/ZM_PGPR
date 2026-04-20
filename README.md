# ZM_PGPR

Data and scripts for **"Identification of bacterial candidates that promote the growth of the seagrass *Zostera marina*"** (Brache-Smith, Badillo, Maeda, Sogin).

- Raw reads (WGS + 16S Nanopore amplicons): NCBI BioProject **PRJNA1260012**
- Processed data archive (NanoASV output, colony PCR FASTAs, ASV/taxonomy/metadata tables): Zenodo — DOI https://doi.org/10.5281/zenodo.19102534
- Genome assemblies: NCBI GenBank (accessions in Supplementary Table 3)

---

## Repository layout

```
scripts/
├── 01_amplicon_ASV_tree/   Fig 1 — ASV reference tree + App-SpaM isolate placement
├── 02_WGS_annotation/      WGS annotation pipeline (feeds Fig 3 + Table S3)
├── 03_phylogenomics/       Fig 2 — GToTree phylogenomic tree
├── 04_KEGG_assays/         Fig 3 — phenotype assays + KEGG presence/absence
└── 05_MinCom/              Metage2Metabo minimal-community selection
```


## Citation

*to be added on acceptance*

## Preprint is available here

https://www.biorxiv.org/content/10.64898/2026.03.19.712741v1
