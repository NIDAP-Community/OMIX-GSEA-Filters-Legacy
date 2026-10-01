# Changelog

## Unreleased

- Select the OMIX Visualization v2 Code Ocean starter environment, retain the
  capsule-specific DT and Pandoc overlays, and remove redundant htmlwidgets and
  plotly overlays already supplied by the starter.
- Enable Code Ocean named parameters and bind all 15 public and advanced
  controls to the canonical OMIX GSEA Filters interface.
- Add deterministic attached-input discovery and adapter contract tests for
  missing, extra, or misbound controls.
- Record the canonical source and schema hashes plus the tagged runtime, while
  leaving the unverified imported runtime digest explicitly pending.
- Record the canonical public `r-visualization` tag and immutable GHCR digest
  separately from the adapter configuration so the public and imported Code
  Ocean environment identities are not conflated.
- Record successful linked-capsule validation run `859970` against adapter
  commit `3391b904123421a6fa9719996951af8d766716e5`, including its attached
  input, named parameters, row assertions, and four inspected outputs. The
  imported Code Ocean digest and release identifiers remain pending.
- Revalidate the release-candidate adapter tree committed as
  `e436f0d63ab27fff01d95c767de6f204c047f2fb` in linked-capsule run `880093`.
  The run retained 375 rows and reproduced all four expected outputs after the
  platform-generated `.codeocean/environment.json` newline normalization was
  committed, with unchanged parsed JSON content and runtime selection.
- Validate merged adapter commit
  `96ea6f3e09a813808d7356768c2acf8b1bf780f7` in linked-capsule run `883755`,
  then publish that exact tree as Code Ocean Standard Capsule Release Version
  2.0. The adapter Git tag and imported Code Ocean runtime digest remain
  pending.
