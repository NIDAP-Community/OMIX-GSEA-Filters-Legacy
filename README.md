# OMIX GSEA Filters Legacy — Code Ocean adapter

This repository is the Code Ocean deployment adapter for the platform-neutral
[OMIX GSEA Filters Legacy module](https://github.com/NIDAP-Community/OMIX/tree/main/modules/OMIX-GSEA-Filters-Legacy).
It filters result tables produced by OMIX GSEA Preranked Legacy using
statistical, pathway-annotation, gene-membership, and contrast criteria.

## Repository boundary

- `code/functions/filter_gsea_function.R` is the exported scientific function
  from the canonical OMIX module.
- `code/main.R` and `code/run` translate Code Ocean inputs and write capsule
  outputs.
- `.codeocean/`, `metadata/`, and `environment/` are Code Ocean-specific and
  do not belong in the OMIX module.

See [OMIX_MODULE_SOURCE.md](OMIX_MODULE_SOURCE.md) and the
[OMIX module contract](https://github.com/NIDAP-Community/OMIX/blob/main/docs/module-contract.md)
before making changes.

## Input and output

The capsule accepts an uploaded GSEA results file or a data asset containing
`gsea_results.csv` or `gsea_results.rds`. It writes filtered CSV and RDS result
tables, an interactive HTML table, and a filtering summary image to Code Ocean
results. Detailed capsule usage is in [code/README.md](code/README.md).
