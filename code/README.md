# Omix GSEA Filter

Filter GSEA table formatted output from Omix GSEA based on multiple criteria including p-values, enrichment scores, pathway size, and more.

## Input

### GSEA Results Table

CSV or RDS file from OMIX GSEA output.

**File options:**
- **Option 1**: Upload a CSV file directly via the App Panel ("Upload GSEA Results File" parameter)
- **Option 2**: Attach a data asset containing `gsea_results.csv` or `gsea_results.rds`
- RDS files must contain a data frame with the same structure as the CSV

**Priority**: If you upload a file via the App Panel, it takes priority over any attached data assets.

### Required Columns

The following columns **must** be present in the input file:

| Column | Type | Description |
|--------|------|-------------|
| `contrast` | character | Experimental contrast name (e.g., "Treatment_1-Control") |
| `geneScore` | character | Gene score type used (e.g., "_tstat", "_log2fc") |
| `fdr_correction_mode` | character | FDR correction method (e.g., "within each collection") |
| `pathways_database` | character | Database source (e.g., "MSigDB_2023.2.Hs") |
| `collection` | character | Pathway collection (e.g., "C2:CP:REACTOME: Reactome gene sets") |
| `pathway` | character | Pathway name (e.g., "REACTOME_CELL_CYCLE_MITOTIC") |
| `pval` | numeric | Raw p-value from GSEA |
| `padj` | numeric | Adjusted p-value (FDR) |
| `ES` | numeric | Enrichment Score (raw) |
| `NES` | numeric | Normalized Enrichment Score |
| `nMoreExtreme` | integer | Number of permutations more extreme than observed |
| `size` | integer | Total genes in pathway |
| `leadingEdge` | character | Comma-separated gene symbols in leading edge |
| `size_leadingEdge` | integer | Number of genes in leading edge |
| `fraction_leadingEdge` | numeric | Fraction of pathway genes in leading edge |
| `inPathway` | character | Comma-separated gene symbols in entire pathway |
| `species` | character | Species (e.g., "Mouse", "Human") |

### Optional Columns

These columns are optional:

| Column | Type | Description |
|--------|------|-------------|
| `leadingEdge_orthologs` | character | Human orthologs of leading edge genes |
| `inPathway_orthologs` | character | Human orthologs of pathway genes |

### Output Columns

The filtered output includes all input columns plus one additional derived column:

| Column | Type | Description |
|--------|------|-------------|
| `main_collection` | character | Top-level collection prefix extracted from `collection` (e.g., "C2" from "C2:CP:REACTOME") |

**Column order in outputs**: `contrast`, `geneScore`, `fdr_correction_mode`, `pathways_database`, `main_collection`, `collection`, `pathway`, `pval`, `padj`, `ES`, `NES`, `nMoreExtreme`, `size`, `leadingEdge`, `size_leadingEdge`, `fraction_leadingEdge`, `inPathway`, `species`, `leadingEdge_orthologs`, `inPathway_orthologs`

### Example Input Row

```
contrast,geneScore,fdr_correction_mode,pathways_database,collection,pathway,pval,padj,ES,NES,nMoreExtreme,size,leadingEdge,size_leadingEdge,fraction_leadingEdge,inPathway,species,leadingEdge_orthologs,inPathway_orthologs
"B-A","_tstat","within each collection","MSigDB_2023.2.Hs","C2:CP:REACTOME: Reactome gene sets","REACTOME_CELL_CYCLE_MITOTIC",0.000365898,0.0106373,-0.387934,-1.871296,0,560,"Myc,Mcm6,Gorasp1,...",145,0.258929,"Aaas,Abl1,Actr1a,...","Mouse","MYC,MCM6,GORASP1,...","AAAS,ABL1,ACTR1A,..."
```

## Output

- **Filtered GSEA Results**: Available in three formats
  - `filtered_gsea_results.csv` - Human-readable CSV format
  - `filtered_gsea_results.rds` - R native format (preserves data types, faster loading in R)
  - `filtered_gsea_results_table.html` - **Interactive HTML table** with:
    - **Clickable MSigDB pathway links**: Pathway names link directly to the Molecular Signatures Database
      - Automatic species detection (human vs mouse MSigDB)
      - Links open in new browser tab to preserve your work
      - Only verified MSigDB pathways are linked; custom pathways display as plain text
    - Formatted numbers: p-values in scientific notation, scores/fractions rounded
    - Sortable columns (click headers)
    - Copy button for quick data export
    - Show/Hide Columns button for customizable view
    - Default displays 5 rows with menu options (5, 10, 25, 50, 100, All)
    - Smart column visibility: technical columns hidden by default (use Show/Hide to reveal)
    - Pathway text wrapping for better readability
  - All files contain pathways passing filter criteria, sorted by p-value (most significant first)
- **Filtering Summary**: `filtering_summary.png` visualization with two panels:
  - **Top panel**: Total unique pathways before/after filtering with retention percentage
  - **Bottom panel**: Filtered pathways by contrast, grouped by enrichment direction (UP/DN)
    - Shows stacked bars by MSigDB collection when ≤12 collections present
    - Color-coded by collection or direction
    - Caption dynamically shows NES or ES based on selected enrichment score type

### How to Use the Interactive Table

1. Click `filtered_gsea_results_table.html` in results panel to open in browser
2. **Key features:**
   - **MSigDB pathway links**: Click any pathway name to view detailed information in the Molecular Signatures Database
     - Automatically detects species (human vs mouse) based on collection names
     - Opens in new tab to keep your results visible
     - Only verified MSigDB pathways are linked; custom pathways appear as plain text
   - **Copy button**: Click to copy all visible data to clipboard (teal button)
   - **Show/Hide Columns**: Toggle column visibility - technical columns (size, geneScore, leadingEdge, etc.) are hidden by default
   - **Rows per page**: Choose 5, 10, 25, 50, 100, or All rows to display (default: 5)
   - **Sort**: Click any column header to sort (click again to reverse)
   - **Formatted display**:
     - P-values shown in scientific notation (e.g., 1.23e-05)
     - Scores and fractions rounded to 2 decimals
     - Pathway names with underscores replaced by spaces and wrapped for readability
     - Gene lists formatted with comma+space for better readability
3. **Hidden by default** (use Show/Hide Columns to reveal):
   - Technical: `geneScore`, `fdr_correction_mode`, `nMoreExtreme`, `size`
   - Gene lists: `leadingEdge`, `inPathway`, `leadingEdge_orthologs`, `inPathway_orthologs`
   - Metadata: `species`, `main_collection`

## Usage

### Using App Panel (Recommended)

The capsule includes a comprehensive App Panel with three parameter categories:

#### 1. **Input Data**
   - **Upload GSEA Results File**: Upload your GSEA results CSV file directly, OR use an attached data asset
   - **Contrast Filter Mode**: Select how to filter by contrasts
     - `none` = include all contrasts
     - `keep` = include only specified contrasts
     - `remove` = exclude specified contrasts
   - **Contrasts**: Comma-separated contrast names (used with keep/remove mode)

#### 2. **Statistical Filters**
   - **P-value Type**: `adjusted p-value` (FDR) or `raw p-value`
   - **P-value Threshold**: Maximum p-value to include (default: 0.05)
   - **Enrichment Score Type**: `NES` (normalized) or `ES` (raw)
   - **Enrichment Score Threshold**: Minimum absolute score (set to 0 to disable filtering)
   - **Enrichment Direction**: `+/-` (both), `+` (positive only), or `-` (negative only)
   - **Size Filter Type**: `Pathway size` or `Leading Edge (LE) size`
   - **Minimum Size**: Minimum pathway/LE size (set to 0 to disable filtering)
   - **Top Rank Filter**: Keep top N pathways per collection and contrast (e.g., `10`), or `all`

#### 3. **Annotation Filters**
   - **Collections to Include**: Comma-separated MSigDB collections (e.g., `H,C2`), or leave empty for all
   - **Pathways to Include**: Comma-separated pathway names to include, or leave empty for all
   - **Gene Filter Universe**: Filter by genes in `Leading Edge (LE)` or entire `Pathway`
   - **Genes to Include**: Comma-separated gene symbols (e.g., `TP53,BRCA1`), or leave empty for all

### Command Line Usage

You can also run from command line with flags:

```bash
./run --p_value_threshold 0.01 --enrichment_score_threshold 1.5 --size_cutoff 15
```

**With uploaded file:**
```bash
./run --input_file /data/my_gsea_results.csv --p_value_threshold 0.01
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
./run --genes_to_include TP53 --gene_filter_universe "Leading Edge (LE)"
```

Keep only top 10 pathways per collection and contrast:
```bash
./run --top_rank_filter 10
```

Filter to specific contrasts:
```bash
./run --contrast_filter keep --contrasts "Treatment_vs_Control,DrugA_vs_Control"
```

## Filtering Capabilities

The GSEA_Filters function supports comprehensive filtering:

- **P-value filtering**: Raw or adjusted p-values with threshold
- **Enrichment score filtering**: ES or NES with absolute threshold and directional control (+/-, +, -)
- **Size filtering**: Minimum pathway or leading edge size
- **Top rank filtering**: Keep top N pathways per collection and contrast
- **Collection filtering**: Select specific MSigDB collections (e.g., H, C2, C5)
- **Pathway filtering**: Include specific pathways by name
- **Gene filtering**: Filter by genes in leading edge or entire pathway
- **Contrast filtering**: Keep or exclude specific experimental contrasts

**Note**: To disable enrichment score or size filtering, set the threshold/minimum to 0.

## Notes

- Output is automatically sorted by p-value with most significant pathways first
- The filtering summary visualization shows the reduction from input to filtered pathways
- All text parameters accept comma-separated values (e.g., "H,C2,C5" for collections)
- Compatible with GSEA Preranked output format (current and legacy versions)
- Detailed filtering steps and summary statistics are displayed in computation logs

## Contact

For issues or questions, contact CCBR at NCICCBRNIDAP@mail.nih.gov
