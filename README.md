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

## Inputs

The capsule accepts an uploaded CSV, TSV, TXT, or RDS GSEA results table. If
the upload is blank, attach a data asset containing exactly one file named
`gsea_results.csv`, `gsea_results.tsv`, `gsea_results.txt`, or
`gsea_results.rds`. Multiple matching files are rejected with their paths so
the user can select the intended file explicitly.

All 15 public and advanced canonical controls are available as named App Panel
parameters. Defaults and choices match the canonical schema. Detailed capsule
usage and column requirements are in [code/README.md](code/README.md).

## Outputs and workflow handoff

The capsule writes `filtered_gsea_results.csv` and
`filtered_gsea_results.rds` for downstream workflow use. It also writes
`filtered_gsea_results_table.html` and `filtering_summary.png` as
deployment-specific review aids.

## Environment and reproducibility

This PR configures the adapter for the Code Ocean OMIX Visualization v2
starter, `codeocean/omix-r-visualization:r4.4.3-v2`, with capsule-specific DT
and Pandoc overlays. Applying that configuration to the live capsule, resolving
its imported immutable digest, and recording a named-parameter Code Ocean run
remain pending; a local or GitHub test is not presented as platform validation.
Retain the input identity and selected filters with a released result.
Canonical and runtime provenance are recorded in
[OMIX_MODULE_SOURCE.md](OMIX_MODULE_SOURCE.md).

## For developers

Read [AGENTS.md](AGENTS.md) and [OMIX_MODULE_SOURCE.md](OMIX_MODULE_SOURCE.md)
before editing. Reusable scientific changes belong in the canonical OMIX module
and are exported here only after validation.
