# Canonical OMIX Module

The reusable scientific implementation for this Code Ocean adapter is owned by
the [OMIX-GSEA-Filters-Legacy module](https://github.com/NIDAP-Community/OMIX/tree/main/modules/OMIX-GSEA-Filters-Legacy).

This adapter owns Code Ocean App Panel metadata, capsule environment setup,
input discovery under `/data`, result paths under `/results`, and the runtime
entry point in `code/main.R`.

When a change affects scientific behavior or the reusable command-line
interface, update the canonical module first (or backport a tested capsule fix)
and then export the released function to `code/functions/`. See the
[OMIX module contract](https://github.com/NIDAP-Community/OMIX/blob/main/docs/module-contract.md).
