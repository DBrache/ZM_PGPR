# 05_MinCom — Metage2Metabo screening of 61 isolate genomes

Selection of the minimal plant-growth-promoting community (MinCom-6) from the 61 sequenced isolates.
Software: Metage2Metabo 1.6.1, MiSCoTo 3.2.0, MeneTools 3.4.0, clingo 5.3.0, Pathway Tools 29.0.

## Workflow

| Step | Command | Output folder (Zenodo) |
|---|---|---|
| 1. Draft metabolic networks (61 SBML) | `m2m recon` | `m2m_sbml_61_isolates.zip` |
| 2. Minimal community for the 30 PGP targets | `m2m mincom` | `mincom_full_pool_61/` |
| 2b. Community scope, full pool of 61 | `m2m cscope` | `cscope_full_pool_61/` |
| 3. Enumerate all minimal communities | `m2m_analysis workflow` | `mincom_enumeration_32_solutions/` |
| 4. Community scope, MinCom-5 and MinCom-6 | `m2m cscope` | `cscope_MinCom5/`, `cscope_MinCom6/` |
| 5. Individual scopes, MinCom-6 | `m2m iscope` | `iscope_MinCom6/` |

Seeds (n = 73) and targets (n = 30) are provided as SBML in `inputs/` on Zenodo and listed in Supplementary Table 1.

Selection outcome: minimum community size 5; 32 equivalent minimal communities; 3 essential symbionts
(Roseibium_195, Mesobacillus_127, Streptomyces_23) plus 2 slots filled from 12 alternative symbionts.
Peribacillus_49 and Streptomyces_384 are one of the 32 solutions; Agarivorans_311 is then added to give MinCom-6.
The full solution table is in Supplementary Table S5.

## Files

- `run_m2m.sh` — steps 1, 2, 2b, 4, 5
- `run_m2m_analysis.sh` — step 3
- `results/` — small summary outputs (mincom, key species, boolean equation, community scopes, `recon_stats.tsv`)

## Large files (Zenodo)

Full outputs and the 61 SBML networks are archived at Zenodo, DOI: https://doi.org/10.5281/zenodo.19102533
(all-versions DOI; always resolves to the latest version). Absolute file paths in the logs
and metadata were replaced with `<ROOT>`, `<RUN_DIR>`, `<CONDA>`, and `<HOME>`.

## Terminology

"Essential" and "alternative" symbionts are Metage2Metabo terms for membership in all or some predicted minimal
communities; they do not imply an ecological symbiosis.
