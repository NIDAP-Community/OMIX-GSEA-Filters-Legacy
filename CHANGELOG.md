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
  leaving the unverified runtime digest and Code Ocean run explicitly pending.
- Record the canonical public `r-visualization` tag and immutable GHCR digest
  separately from the adapter configuration; applying the new configuration to
  Code Ocean, resolving its environment identity, and validation remain pending.
