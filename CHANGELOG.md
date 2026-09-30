# Changelog

## Unreleased

- Enable Code Ocean named parameters and bind all 15 public and advanced
  controls to the canonical OMIX GSEA Filters interface.
- Add deterministic attached-input discovery and adapter contract tests for
  missing, extra, or misbound controls.
- Record the canonical source and schema hashes plus the tagged runtime, while
  leaving the unverified runtime digest and Code Ocean run explicitly pending.
- Record the canonical public `r-visualization` tag and immutable GHCR digest
  separately from the adapter's historical `r-pathway` selection; Code Ocean
  runtime reconciliation, environment identity, and validation remain pending.
