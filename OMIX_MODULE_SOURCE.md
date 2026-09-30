# Canonical OMIX Module Source

## Canonical module

- **Module:** [OMIX GSEA Filters Legacy](https://github.com/NIDAP-Community/OMIX/tree/main/modules/OMIX-GSEA-Filters-Legacy)
- **Canonical path:** `modules/OMIX-GSEA-Filters-Legacy/`
- **Canonical module version:** `1.0.0`
- **Canonical interface version:** `1`
- **Canonical release tag:** Pending — baseline tag not yet established.
- **Canonical source reference:** [`eee4433cd74d0ce9bd1daba1571ca6312cba7ea2`](https://github.com/NIDAP-Community/OMIX/commit/eee4433cd74d0ce9bd1daba1571ca6312cba7ea2)
- **Interface schema:** [schemas/interface.yml](https://github.com/NIDAP-Community/OMIX/blob/main/modules/OMIX-GSEA-Filters-Legacy/schemas/interface.yml)
- **Module contract:** [OMIX module contract](https://github.com/NIDAP-Community/OMIX/blob/main/docs/module-contract.md)

## Exported scientific files

| Canonical file | Adapter copy | SHA-256 | Purpose |
| --- | --- | --- | --- |
| `R/filter_gsea_function.R` | `code/functions/filter_gsea_function.R` | `981aa772884f41931b3a64b1a67ddca455ae7b56b746b5472bc27505bfc31c2e` | Legacy GSEA result-filtering implementation. |

The listed export was verified byte-for-byte against the canonical source
reference above. The canonical `schemas/interface.yml` used for the App Panel
and adapter contract has SHA-256
`74a4305e2436b8636d1a2b5462624dc54e30f93be830a883c41af15e7544b174`.

## Platform translations

- The canonical `input` control is exposed as the Code Ocean file selector
  named `input`. When it is blank, `code/adapter_io.R` recursively discovers
  exactly one canonical `gsea_results` filename beneath `/data`; ambiguity is
  an error rather than an implicit choice.
- The canonical internal `output_dir` control is platform-managed as
  `../results`. It is intentionally not shown in the App Panel.
- `filtering_summary.png` and `filtered_gsea_results_table.html` are
  adapter-only presentation outputs. The canonical CSV and RDS outputs retain
  their stable names.
- All 15 public and advanced canonical controls use their canonical CLI names
  in the named-parameter App Panel. There are no scientific aliases or hidden
  public controls in this adapter.

## Adapter release record

| Field | Recorded value |
| --- | --- |
| Adapter version | Pending — baseline tag not yet established. |
| Adapter release tag | Pending. |
| Platform release | Pending validation record. |
| Runtime tag | `codeocean/omix-r-pathway:r4.4.3-bioconductor3.20-v1` (from `.codeocean/environment.json`). |
| Runtime digest | Pending — no immutable digest has been validated or recorded. |
| Named-parameter platform run | Pending — GitHub/local checks are not Code Ocean validation. |
| Syncweaver lock | Pending — no generated `.syncweaver-lock.json` is recorded. |

The canonical module declares the `r-visualization` runtime profile. This
adapter currently names the historical Code Ocean `omix-r-pathway` image plus
its platform overlay packages. Compatibility passed a local representative
run, but runtime-profile reconciliation and the immutable digest remain
pending Forge and Code Ocean validation.

See the [OMIX versioning and release policy](https://github.com/NIDAP-Community/OMIX/blob/main/docs/versioning-and-releases.md). The source commit, adapter tag, platform release, and runtime identity are separate records.

## Ownership and synchronization

The canonical module owns scientific functions, portable CLI behavior, schemas,
tests, and scientific documentation. This adapter owns deployment UI, input
discovery, result paths, runtime setup, and the platform entry point.

Make reusable changes in the canonical module, update its tests and interface,
record the next canonical version and immutable source reference here, and then re-export the listed
file without unreviewed behavioral changes. Validate the adapter with
representative deployment inputs before release.
