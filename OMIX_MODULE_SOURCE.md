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
| Platform release | Pending — successful validation is not a released capsule version. |
| Runtime tag | `codeocean/omix-r-visualization:r4.4.3-v2` (from `.codeocean/environment.json`). |
| Runtime digest | Pending — no immutable digest has been validated or recorded. |
| Named-parameter platform run | Capsule `8822105`, run `880093`, October 1, 2026, adapter commit `e436f0d63ab27fff01d95c767de6f204c047f2fb`. |
| Syncweaver lock | Pending — no generated `.syncweaver-lock.json` is recorded. |

The canonical module declares the `r-visualization` runtime profile. The linked
capsule now selects the matching Code Ocean OMIX Visualization v2 environment,
retains its capsule-specific DT and Pandoc overlays, and relies on the starter
for htmlwidgets and plotly. Representative platform validation succeeded; the
imported Code Ocean environment digest and platform release remain pending.

<!-- omix-runtime-provenance: {"runtime_profile":"r-visualization","published_image":"ghcr.io/nidap-community/omix-r-visualization","published_tag":"r4.4.3-v2","published_digest":"sha256:1d9f453b49412aa05e9d3420cd4b1b4ea0beac4923cb40572af38b0ae2a46830","published_immutable_reference":"ghcr.io/nidap-community/omix-r-visualization@sha256:1d9f453b49412aa05e9d3420cd4b1b4ea0beac4923cb40572af38b0ae2a46830","adapter_base_image":"codeocean/omix-r-visualization:r4.4.3-v2","adapter_base_image_digest":null,"adapter_digest_status":"pending_code_ocean_resolution","runtime_profile_alignment_status":"validated_code_ocean_run_digest_pending","code_ocean_environment_id":null,"capsule_run":{"capsule_id":"8822105","run_id":"880093","date":"2026-10-01","adapter_commit":"e436f0d63ab27fff01d95c767de6f204c047f2fb","dataset_id":"f165ec6c-115f-446a-8429-55073714c2ef"}} -->

### Runtime provenance detail

| Field | Recorded value |
| --- | --- |
| Canonical runtime profile | `r-visualization`, as declared by the canonical module. |
| Published OMIX runtime | Tag `ghcr.io/nidap-community/omix-r-visualization:r4.4.3-v2`; immutable public identity `ghcr.io/nidap-community/omix-r-visualization@sha256:1d9f453b49412aa05e9d3420cd4b1b4ea0beac4923cb40572af38b0ae2a46830`. |
| Adapter-selected base image | `codeocean/omix-r-visualization:r4.4.3-v2`; it aligns by profile and tag, while the imported Code Ocean image digest remains **Pending Code Ocean resolution**. A similarly named public GHCR image is not treated as proof of the imported Code Ocean environment's identity. |
| Runtime build evidence | [Starter Environments run 33779788678](https://github.com/NIDAP-Community/OMIX/actions/runs/33779788678) built, verified, inventoried, and published `r-visualization:v2`; [GHCR version 1205968442](https://github.com/orgs/NIDAP-Community/packages/container/omix-r-visualization/1205968442) independently maps the version tag to the recorded digest. Post-publication package-set re-verification remains pending in the canonical release manifest. |
| Code Ocean environment identity | Linked capsule `8822105` selected **OMIX Visualization 2 (2)** and built from `registry.poc-nci.codeocean.io/codeocean/omix-r-visualization:r4.4.3-v2`. The imported immutable digest or stable environment-release ID was not exposed in the run record and remains pending. |
| Capsule run | Run `880093` completed successfully on October 1, 2026 from the exact tree committed as `e436f0d63ab27fff01d95c767de6f204c047f2fb`. |

### Code Ocean validation evidence

- **Capsule:** `8822105` (linked to this GitHub repository)
- **Run:** `880093`, completed October 1, 2026 in 7 seconds
- **Input:** attached `gsea_data` asset
  `f165ec6c-115f-446a-8429-55073714c2ef`; recursively discovered
  `/data/gsea_data/gsea_results.csv` with 2,544 rows and 19 columns
- **Parameters:** adjusted p-value at `0.05`; NES threshold `0`; both enrichment
  directions; pathway-size threshold `0`; top rank `all`; no collection,
  pathway, gene, or contrast restrictions
- **Results:** 375 filtered rows; 848 input unique pathways and 218 retained
  unique pathways (25.7% retention)
- **Outputs inspected:** `filtered_gsea_results.csv` (672.66 KB),
  `filtered_gsea_results.rds` (160.74 KB), `filtering_summary.png` (94.92 KB),
  and `filtered_gsea_results_table.html` (1.15 MB); all were nonempty. The
  summary plot and interactive table rendered successfully.

This establishes representative platform behavior for the recorded commit and
tag-selected environment. Code Ocean's newline normalization for
`.codeocean/environment.json` was committed as part of the exact tested tree;
the parsed environment configuration and runtime selection were unchanged. It
does not establish the imported environment's immutable digest, a capsule
release, an adapter tag, or release approval.

The published public image identity is also recorded in the canonical
[`release-manifest.json`](https://github.com/NIDAP-Community/OMIX/blob/eee4433cd74d0ce9bd1daba1571ca6312cba7ea2/starter-environments/release-manifest.json).
It identifies the intended portable runtime candidate; it does not alter the
adapter environment or establish Code Ocean validation. Public image tag,
public digest, adapter-selected base image, Code Ocean environment identity,
capsule run, and platform release remain separate records.

See the [OMIX versioning and release policy](https://github.com/NIDAP-Community/OMIX/blob/main/docs/versioning-and-releases.md). The source commit, adapter tag, platform release, and runtime identity are separate records.

## Ownership and synchronization

The canonical module owns scientific functions, portable CLI behavior, schemas,
tests, and scientific documentation. This adapter owns deployment UI, input
discovery, result paths, runtime setup, and the platform entry point.

Make reusable changes in the canonical module, update its tests and interface,
record the next canonical version and immutable source reference here, and then re-export the listed
file without unreviewed behavioral changes. Validate the adapter with
representative deployment inputs before release.
