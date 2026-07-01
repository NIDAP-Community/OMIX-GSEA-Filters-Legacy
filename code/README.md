# Omix GSEA Filter

Filter GSEA table formatted output from Omix GSEA based on multiple criteria including p-values, enrichment scores, pathway size, and more.

## Input

- **GSEA Results Table**: CSV file (typically `gsea_results.csv` from OMIX GSEA output)
  - Required columns: `contrast`, `collection`, `pathway`, `pval`, `padj`, `ES`, `NES`, `size`, `leadingEdge`, etc.

## Output

- **Filtered GSEA Results**: `filtered_gsea_results.csv` containing pathways that pass all filter criteria
- **Interactive Bubble Plot**: Volcano-bubble chart visualization (displayed in logs)

## Usage

### Using App Panel (Recommended)

The capsule includes a comprehensive App Panel with five parameter categories:

1. **P-value Filtering**
   - Choose p-value type (adjusted/raw)
   - Set significance threshold (default: 0.05)

2. **Enrichment Score Filtering**
   - Select score type (NES/ES/none)
   - Set threshold and direction (+/-, +, -)

3. **Pathway Size Filtering**
   - Choose size type (pathway/leading edge)
   - Set minimum size cutoff

4. **Advanced Filters**
   - Top N pathways per collection
   - Filter by MSigDB collections (e.g., H, C2)
   - Filter by specific pathways
   - Filter by genes (in LE or pathway)
   - Filter by contrasts (keep/remove mode)

5. **Display Options**
   - Bubble color variable
   - Sort order

Simply attach your GSEA results data asset and configure parameters through the App Panel interface.

### Command Line Usage

You can also run from command line with flags:

```bash
./run --p_value_threshold 0.01 --enrichment_score_threshold 1.5 --size_cutoff 15
```

**Common Examples:**

Filter stringent pathways (padj < 0.01, |NES| > 1.5):
```bash
./run --p_value_threshold 0.01 --enrichment_score_threshold 1.5
```

Filter hallmark pathways only:
```bash
./run --collections_to_include H
```

Filter pathways containing TP53:
```bash
./run --genes_to_include TP53
```

Keep only top 10 pathways per collection and contrast:
```bash
./run --top_rank_filter 10
```

## Filtering Capabilities

The GSEA_Filters function supports comprehensive filtering:

- **P-value filtering**: Raw or adjusted p-values
- **Enrichment score filtering**: ES or NES with directional control
- **Size filtering**: Minimum pathway or leading edge size
- **Top rank filtering**: Keep top N per collection/contrast
- **Collection filtering**: Select specific MSigDB collections
- **Pathway filtering**: Include specific pathways
- **Gene filtering**: Filter by genes in leading edge or pathway
- **Contrast filtering**: Keep or exclude specific contrasts

## Notes

- The filter function displays detailed filtering steps and summary statistics in computation logs
- An interactive bubble plot is generated showing filtered pathways (NES vs -log10 p-value)
- Compatible with GSEA Preranked output format (current and legacy versions)
- All text parameters accept comma-separated values (e.g., "H,C2,C5" for collections)

## Contact

For issues or questions, contact CCBR at NCICCBRNIDAP@mail.nih.gov
