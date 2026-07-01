#!/usr/bin/env Rscript

# Main script to run GSEA Filter
# Reads GSEA results table, applies filters, saves filtered output

# Load required libraries
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(tidyr)
  library(plotly)
  library(RColorBrewer)
  library(optparse)
})

# Source the GSEA filter function
source("/code/filter_gsea_function.R")

# Define command line options
option_list <- list(
  make_option("--p_value_filter", type = "character", default = "adjusted p-value",
              help = "P-value type for filtering [default: %default]"),
  make_option("--p_value_threshold", type = "double", default = 0.05,
              help = "P-value threshold [default: %default]"),
  make_option("--enrichment_score_filter", type = "character", default = "NES (Normalized Enrichment Score)",
              help = "Enrichment score type [default: %default]"),
  make_option("--enrichment_score_threshold", type = "double", default = 0,
              help = "Enrichment score threshold (absolute value) [default: %default]"),
  make_option("--enrichment_score_sign", type = "character", default = "+/-",
              help = "Enrichment score direction [default: %default]"),
  make_option("--size_filter", type = "character", default = "Pathway size",
              help = "Size filter type [default: %default]"),
  make_option("--size_cutoff", type = "integer", default = 0,
              help = "Minimum pathway/LE size [default: %default]"),
  make_option("--top_rank_filter", type = "character", default = "all",
              help = "Top rank filter [default: %default]"),
  make_option("--collections_to_include", type = "character", default = NULL,
              help = "Collections to include (comma-separated)"),
  make_option("--pathways_to_include", type = "character", default = NULL,
              help = "Pathways to include (comma-separated)"),
  make_option("--gene_filter_universe", type = "character", default = "Leading Edge (LE)",
              help = "Gene filter universe [default: %default]"),
  make_option("--genes_to_include", type = "character", default = NULL,
              help = "Genes to include (comma-separated)"),
  make_option("--contrast_filter", type = "character", default = "none",
              help = "Contrast filter mode [default: %default]"),
  make_option("--contrasts", type = "character", default = NULL,
              help = "Contrasts to keep/remove (comma-separated)"),
  make_option("--bubble_color_variable", type = "character", default = "collection",
              help = "Bubble color variable [default: %default]"),
  make_option("--sort_decreasing", type = "logical", default = FALSE,
              help = "Sort output in decreasing order [default: %default]")
)

# Parse arguments
opt_parser <- OptionParser(option_list = option_list)
opt <- parse_args(opt_parser)

# Convert comma-separated strings to vectors
parse_comma_list <- function(x) {
  if (is.null(x) || x == "" || x == "NULL") return(NULL)
  trimws(unlist(strsplit(x, ",")))
}

collections_vec <- parse_comma_list(opt$collections_to_include)
pathways_vec <- parse_comma_list(opt$pathways_to_include)
genes_vec <- parse_comma_list(opt$genes_to_include)
contrasts_vec <- parse_comma_list(opt$contrasts)

# Set file paths
# Auto-detect GSEA results from attached data asset
# Data assets are mounted under /data/<mount_point>
# Search for gsea_results.csv in /data subdirectories
data_dirs <- list.dirs("/data", recursive = FALSE, full.names = TRUE)
input_file <- NULL

for (dir in data_dirs) {
  candidate <- file.path(dir, "gsea_results.csv")
  if (file.exists(candidate)) {
    input_file <- candidate
    break
  }
}

# Fallback to old behavior if no data asset attached
if (is.null(input_file)) {
  input_file <- opt$input_file
  if (!is.null(opt$input_file) && opt$input_file != "") {
    cat("Warning: No gsea_results.csv found in attached data assets.\n")
    cat("Attempting to use provided input_file parameter.\n")
  } else {
    stop("Error: No GSEA results data asset attached and no input_file specified.")
  }
}

output_file <- "../results/filtered_gsea_results.csv"

# Read input GSEA table
cat("Reading GSEA table from:", input_file, "\n")

if (!file.exists(input_file)) {
  stop("Error: Input file not found: ", input_file)
}

gsea_table <- read.csv(input_file, stringsAsFactors = FALSE)

# Display input summary
cat(sprintf("\nInput table: %d rows, %d columns\n", nrow(gsea_table), ncol(gsea_table)))

# Log parameters
cat("\n=== GSEA Filter Parameters ===\n")
cat("P-value filter:", opt$p_value_filter, "\n")
cat("P-value threshold:", opt$p_value_threshold, "\n")
cat("Enrichment score filter:", opt$enrichment_score_filter, "\n")
cat("Enrichment score threshold:", opt$enrichment_score_threshold, "\n")
cat("Enrichment score sign:", opt$enrichment_score_sign, "\n")
cat("Size filter:", opt$size_filter, "\n")
cat("Size cutoff:", opt$size_cutoff, "\n")
cat("Top rank filter:", opt$top_rank_filter, "\n")
if (!is.null(collections_vec)) cat("Collections:", paste(collections_vec, collapse = ", "), "\n")
if (!is.null(pathways_vec)) cat("Pathways:", paste(pathways_vec, collapse = ", "), "\n")
if (!is.null(genes_vec)) cat("Genes:", paste(genes_vec, collapse = ", "), "\n")
cat("Contrast filter:", opt$contrast_filter, "\n")
if (!is.null(contrasts_vec)) cat("Contrasts:", paste(contrasts_vec, collapse = ", "), "\n")

# Apply filters using the GSEA_Filters function
cat("\n=== Applying GSEA Filters ===\n")

filtered_results <- GSEA_Filters(
  gsea_table = gsea_table,
  
  # P-value filtering
  p_value_filter = opt$p_value_filter,
  p_value_threshold = opt$p_value_threshold,
  
  # Enrichment score filtering
  enrichment_score_filter = opt$enrichment_score_filter,
  enrichment_score_threshold = opt$enrichment_score_threshold,
  enrichment_score_sign = opt$enrichment_score_sign,
  
  # Size filtering
  size_filter = opt$size_filter,
  size_cutoff = opt$size_cutoff,
  
  # Top rank filtering
  top_rank_filter = opt$top_rank_filter,
  
  # Collection filtering
  collections_to_include = collections_vec,
  
  # Pathway filtering
  pathways_to_include = pathways_vec,
  
  # Gene filtering
  gene_filter_universe = opt$gene_filter_universe,
  genes_to_include = genes_vec,
  
  # Contrast filtering
  contrast_filter = opt$contrast_filter,
  contrasts = contrasts_vec,
  
  # Plotting options
  bubble_color_variable = opt$bubble_color_variable,
  
  # Output options
  columns_to_sort_output_by = c("padj", "pval"),
  sort_output_in_decreasing_order = opt$sort_decreasing,
  
  # Display warnings
  display_warnings = -1
)

# Save filtered results
cat("\n=== Saving Results ===\n")
write.csv(filtered_results, output_file, row.names = FALSE)
cat(sprintf("Filtered results saved to: %s\n", output_file))
cat(sprintf("Output: %d pathways retained\n", nrow(filtered_results)))

cat("\n=== GSEA Filter Complete ===\n")
