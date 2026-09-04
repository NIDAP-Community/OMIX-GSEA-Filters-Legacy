# OMIX GSEA Filters Legacy — Code Ocean adapter

Filter GSEA result tables using statistical, pathway-annotation,
gene-membership, and contrast criteria.

## Canonical OMIX module

| Item | Location |
| --- | --- |
| Canonical module | [OMIX GSEA Filters Legacy](https://github.com/NIDAP-Community/OMIX/tree/main/modules/OMIX-GSEA-Filters-Legacy) |
| Interface contract | [schemas/interface.yml](https://github.com/NIDAP-Community/OMIX/blob/main/modules/OMIX-GSEA-Filters-Legacy/schemas/interface.yml) |
| Development contract | [OMIX module contract](https://github.com/NIDAP-Community/OMIX/blob/main/docs/module-contract.md) |
| Released source reference | [OMIX_MODULE_SOURCE.md](OMIX_MODULE_SOURCE.md) |

The canonical module owns scientific behavior, portable CLI operation, tests,
and the reusable input/output contract. This repository is its Code Ocean
deployment adapter.

## What this deployment adds

- `code/functions/filter_gsea_function.R` is the exported scientific function
  from the canonical OMIX module.
- `code/main.R` and `code/run` translate Code Ocean inputs and write capsule
  outputs.
- `.codeocean/`, `metadata/`, and `environment/` are Code Ocean-specific and
  do not belong in the OMIX module.

See [OMIX_MODULE_SOURCE.md](OMIX_MODULE_SOURCE.md) and the
[OMIX module contract](https://github.com/NIDAP-Community/OMIX/blob/main/docs/module-contract.md)
before making changes.

## Inputs and outputs

The capsule accepts an uploaded GSEA results file or a data asset containing
`gsea_results.csv` or `gsea_results.rds`. It writes filtered CSV and RDS result
tables, an interactive HTML table, and a filtering summary image to Code Ocean
results. Detailed capsule usage is in [code/README.md](code/README.md).

## Environment and reproducibility

Use the pinned capsule environment recorded with the release. Retain the input
GSEA-result identity and selected filters with a released result. The canonical
source relationship is recorded in [OMIX_MODULE_SOURCE.md](OMIX_MODULE_SOURCE.md).

## For developers

Read [AGENTS.md](AGENTS.md) and [OMIX_MODULE_SOURCE.md](OMIX_MODULE_SOURCE.md)
before editing. Reusable scientific changes belong in the canonical OMIX module
and are exported here only after validation.
