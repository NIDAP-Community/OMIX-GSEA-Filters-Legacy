# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [Unreleased]

## [4.0.0] - 2026-07-08

### Added
- **Interactive column filters** in HTML table for powerful data exploration
  - **Character columns** (contrast, pathway, collection, genes): HTML5 datalist autocomplete with type-to-search functionality
    - Shows filtered suggestions as you type
    - Works with all text columns including hidden ones
  - **Numeric columns** (pval, padj, ES, NES, size, fractions): Separate Min and Max input boxes for flexible range filtering
    - Supports negative values (e.g., filter NES from -3 to -1)
    - One-sided filtering by leaving Min or Max empty
    - Proper handling of edge cases including zero values
  - **Gene search capability**: Type gene symbols in `leadingEdge`, `inPathway`, or ortholog columns to find pathways containing specific genes
  - Filters remain active when toggling column visibility
  - No duplicate filter inputs (set `filter = "none"` in DT options)
- Comprehensive README column documentation:
  - **Required columns table**: 16 columns with type and description (all core columns; orthologs and nMoreExtreme are optional)
  - **Optional columns table**: 3 columns (nMoreExtreme, ortholog columns)
  - **Output columns**: Documents derived `main_collection` column and column order
  - **Example input row**: Formatted as readable two-column table (Column | Example Value) for better clarity
- Enhanced App Panel help text with detailed parameter guidance:
  - Concrete examples for all text inputs (contrast names with hyphens, collection codes, pathway names, gene symbols)
  - Typical threshold values (0.05 for p-value, 1.5 for NES, 15 for size)
  - Clear explanation of filtering modes and directions
  - Explicit recommendation for adjusted p-value (FDR-corrected) in GSEA Preranked context
  - Case-sensitivity notes for all relevant parameters

### Changed
- **Simplified error messages** for Collections/Pathways/Genes to Include filters
  - Removed environment-specific context (references to GSEA Preranked capsule and App Panel)
  - Cleaner format: "Requested X are not found" with clear lists of missing and available items
  - More actionable for Code Ocean users across different workflows
- Column filter implementation:
  - Replaced single "Min to Max" input with separate Min/Max boxes for better negative number handling
  - Changed separator from hyphen (`-`) to "to" (e.g., `-3 to -1`) to avoid parsing issues with negative values
  - Replaced dropdown select menus with HTML5 datalist for more intuitive autocomplete experience
- Updated README.md interactive table documentation:
  - Added detailed column filter usage instructions with examples
  - Documented gene search functionality
  - Added `pathways_database` to hidden-by-default columns list
  - Restructured Input and Output sections for clarity:
    - Moved "Output Columns" from Input section to Output section
    - Clear separation between input data requirements and output structure
- Updated contrast example in App Panel to use OMIX standard format with hyphens (`Treatment_1-Control` instead of `Treatment_vs_Control`)
- **Removed legacy GSEA v67 support code**:
  - Removed `adjust.v67()` function for outdated CCBR GSEA format compatibility
  - Removed `tested_contrast` and `gene_score` function parameters (no longer needed)
  - Removed associated documentation for legacy parameters
  - Simplified code by removing ~180 lines of legacy format handling

### Removed
- Legacy GSEA format support (CCBR Preranked GSEA version 67 or lower)
- `tested_contrast` parameter
- `gene_score` parameter

### Technical
- Column filtering uses custom JavaScript functions:
  - Character columns: HTML5 datalist pattern matching
  - Numeric columns: parseFloat with null/undefined/empty string handling for Min/Max logic
- All columns (visible and hidden) have filter inputs ready for when revealed via Show/Hide Columns button

## [3.0.0] - 2026-07-08

### Added
- **Pathway links to MSigDB**: Pathway names are now clickable links to MSigDB database
  - Automatic species detection: Collections starting with `M` (MH, MC2, etc.) link to mouse MSigDB, others to human
  - Links open in new tab to preserve your work
  - **Smart link detection**: Only creates links for confirmed MSigDB pathways (H, C1-C8, MH, MC1-MC8)
    - Custom pathways display as plain text to prevent broken links
    - Uses `pathways_database` column if available, otherwise validates collection patterns
- **Gene column formatting**: Leading edge and pathway gene lists now display with improved readability
  - Comma → comma+space formatting (`GENE1, GENE2` instead of `GENE1,GENE2`)
  - Left-aligned with text wrapping (matching pathway column style)
  - Wider column width (350px) for better gene list display
  - Applies to: `leadingEdge`, `inPathway`, `leadingEdge_orthologs`, `inPathway_orthologs`

## [2.0.0] - 2026-07-08

### Added
- **Pathway links to MSigDB**: Pathway names are now clickable links to MSigDB database
  - Automatic species detection: Collections starting with `M` (MH, MC2, etc.) link to mouse MSigDB, others to human
  - Links open in new tab to preserve your work
  - **Smart link detection**: Only creates links for confirmed MSigDB pathways (H, C1-C8, MH, MC1-MC8)
    - Custom pathways display as plain text to prevent broken links
    - Uses `pathways_database` column if available, otherwise validates collection patterns
- **Gene column formatting**: Leading edge and pathway gene lists now display with improved readability
  - Comma → comma+space formatting (`GENE1, GENE2` instead of `GENE1,GENE2`)
  - Left-aligned with text wrapping (matching pathway column style)
  - Wider column width (350px) for better gene list display
  - Applies to: `leadingEdge`, `inPathway`, `leadingEdge_orthologs`, `inPathway_orthologs`

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
