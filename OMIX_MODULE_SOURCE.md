# Canonical OMIX Module Source

## Canonical module

- **Module:** [OMIX GSEA Filters Legacy](https://github.com/NIDAP-Community/OMIX/tree/main/modules/OMIX-GSEA-Filters-Legacy)
- **Canonical path:** `modules/OMIX-GSEA-Filters-Legacy/`
- **Canonical module version:** `1.0.0`
- **Canonical interface version:** `1`
- **Canonical release tag:** Pending — baseline tag not yet established.
- **Canonical source reference:** [`2987296a45a2a11e6c4b3454c813a63ae6db6ac0`](https://github.com/NIDAP-Community/OMIX/commit/2987296a45a2a11e6c4b3454c813a63ae6db6ac0)
- **Interface schema:** [schemas/interface.yml](https://github.com/NIDAP-Community/OMIX/blob/main/modules/OMIX-GSEA-Filters-Legacy/schemas/interface.yml)
- **Module contract:** [OMIX module contract](https://github.com/NIDAP-Community/OMIX/blob/main/docs/module-contract.md)

## Exported scientific files

| Canonical file | Adapter copy | Purpose |
| --- | --- | --- |
| `R/filter_gsea_function.R` | `code/functions/filter_gsea_function.R` | Legacy GSEA result-filtering implementation. |

The listed export was verified byte-for-byte against the canonical source
reference above.

## Adapter release record

| Field | Recorded value |
| --- | --- |
| Adapter version | Pending — baseline tag not yet established. |
| Adapter release tag | Pending. |
| Platform release | Pending validation record. |
| Runtime identity | Not yet recorded as an immutable image digest or lockfile reference. |

See the [OMIX versioning and release policy](https://github.com/NIDAP-Community/OMIX/blob/main/docs/versioning-and-releases.md). The source commit, adapter tag, platform release, and runtime identity are separate records.

## Ownership and synchronization

The canonical module owns scientific functions, portable CLI behavior, schemas,
tests, and scientific documentation. This adapter owns deployment UI, input
discovery, result paths, runtime setup, and the platform entry point.

Make reusable changes in the canonical module, update its tests and interface,
record the next canonical version and immutable source reference here, and then re-export the listed
file without unreviewed behavioral changes. Validate the adapter with
representative deployment inputs before release.
