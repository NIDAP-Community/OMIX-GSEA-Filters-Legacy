# OMIX GSEA Filters Legacy Adapter Instructions

Read [OMIX_MODULE_SOURCE.md](../OMIX_MODULE_SOURCE.md) before changing this
repository.

- Keep Code Ocean-specific files in `.codeocean/`, `metadata/`, `environment/`,
  `code/main.R`, and `code/run`.
- Keep reusable scientific logic in `code/functions/` synchronized with the
  canonical OMIX module at `modules/OMIX-GSEA-Filters-Legacy/R/`.
- Do not add data, results, package inventories, or credentials to Git.
- A Code Ocean-tested scientific change must be backported to OMIX before a
  release is finalized.
