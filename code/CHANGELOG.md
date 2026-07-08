# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [2.0.0] - 2026-07-08

### Added
- Interactive HTML table with enhanced features:
  - Copy button for quick data export to clipboard
  - Show/Hide Columns button for customizable column visibility
  - Rows-per-page menu with options: 5, 10, 25, 50, 100, All (default: 5)
  - Smart default column visibility (hides technical/gene-list columns)
- Professional teal color scheme for interactive buttons

### Changed
- Interactive HTML table improvements:
  - P-values now displayed in scientific notation (e.g., 1.23e-05)
  - Scores and fractions rounded to 2 decimal places
  - Pathway names: underscores replaced with spaces for readability
  - Enhanced text wrapping for long pathway names
  - Default hidden columns: `geneScore`, `fdr_correction_mode`, `nMoreExtreme`, `size`, 
    `leadingEdge`, `inPathway`, `leadingEdge_orthologs`, `inPathway_orthologs`, 
    `species`, `main_collection` (accessible via Show/Hide Columns)
- Updated README.md to reflect current interactive table features

### Removed
- Interactive HTML table: removed search box and column filters for cleaner interface
- Removed CSV and Excel export buttons (kept Copy button only)

## [1.0.0] - 2025-01-06

### Added
- Initial release with comprehensive GSEA filtering capabilities
- Support for both CSV and RDS input formats
- Multi-criteria filtering: p-values, enrichment scores, pathway size, collections, genes, contrasts
- Interactive HTML table output with sorting and pagination
- Filtering summary visualization with:
  - Before/after pathway counts
  - Enrichment direction breakdown by contrast
  - Collection-based stacked bars (when ≤12 collections)
- App Panel with three parameter categories (Input, Statistical Filters, Annotation Filters)
- Command-line interface support
- Auto-detection of input files from attached data assets or uploaded files
