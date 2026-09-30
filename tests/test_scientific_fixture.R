#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = FALSE)
script <- sub("^--file=", "", args[grepl("^--file=", args)])
root <- normalizePath(file.path(dirname(script), ".."))
source(file.path(root, "code", "functions", "filter_gsea_function.R"))

fixture <- data.frame(
  contrast = c("B-A", "B-A", "C-A"),
  collection = c("H", "H", "H"),
  pathway = c("KEEP_POSITIVE", "DROP_PVALUE", "DROP_NEGATIVE"),
  pval = c(0.005, 0.1, 0.004),
  padj = c(0.01, 0.2, 0.02),
  ES = c(0.8, 0.7, -0.9),
  NES = c(1.5, 1.4, -2.0),
  size = c(20L, 20L, 20L),
  size_leadingEdge = c(8L, 8L, 8L),
  leadingEdge = c("A,B", "C,D", "E,F"),
  inPathway = c("A,B,G", "C,D,H", "E,F,I"),
  stringsAsFactors = FALSE
)

observed <- GSEA_Filters(
  gsea_table = fixture,
  columns_to_sort_output_by = c("padj", "pval"),
  sort_output_in_decreasing_order = FALSE,
  p_value_filter = "adjusted p-value",
  p_value_threshold = 0.05,
  enrichment_score_filter = "NES (Normalized Enrichment Score)",
  enrichment_score_threshold = 1,
  enrichment_score_sign = "+",
  size_filter = "Pathway size",
  size_cutoff = 5,
  top_rank_filter = "all",
  collections_to_include = NULL,
  pathways_to_include = NULL,
  gene_filter_universe = "Leading Edge (LE)",
  genes_to_include = NULL,
  contrast_filter = "none",
  contrasts = NULL,
  display_warnings = -1
)

stopifnot(
  identical(observed$pathway, "KEEP_POSITIVE"),
  identical(observed$contrast, "B-A")
)
message("GSEA Filters scientific fixture check passed")
