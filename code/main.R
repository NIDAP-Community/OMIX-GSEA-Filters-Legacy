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
  library(patchwork)
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
# Search for gsea_results.csv or gsea_results.rds in /data subdirectories
data_dirs <- list.dirs("/data", recursive = FALSE, full.names = TRUE)
input_file <- NULL
file_format <- NULL

for (dir in data_dirs) {
  # Check for CSV first
  candidate_csv <- file.path(dir, "gsea_results.csv")
  if (file.exists(candidate_csv)) {
    input_file <- candidate_csv
    file_format <- "csv"
    break
  }
  
  # Check for RDS
  candidate_rds <- file.path(dir, "gsea_results.rds")
  if (file.exists(candidate_rds)) {
    input_file <- candidate_rds
    file_format <- "rds"
    break
  }
}

# Fallback to old behavior if no data asset attached
if (is.null(input_file)) {
  input_file <- opt$input_file
  if (!is.null(opt$input_file) && opt$input_file != "") {
    cat("Warning: No gsea_results.csv or gsea_results.rds found in attached data assets.\n")
    cat("Attempting to use provided input_file parameter.\n")
    # Detect format from file extension
    if (grepl("\\.rds$", input_file, ignore.case = TRUE)) {
      file_format <- "rds"
    } else {
      file_format <- "csv"
    }
  } else {
    stop("Error: No GSEA results data asset attached and no input_file specified.")
  }
}

output_file <- "../results/filtered_gsea_results.csv"

# Read input GSEA table
cat("Reading GSEA table from:", input_file, "\n")
cat("File format:", file_format, "\n")

if (!file.exists(input_file)) {
  stop("Error: Input file not found: ", input_file)
}

# Read based on format
if (file_format == "rds") {
  gsea_table <- readRDS(input_file)
  # Verify it's a data frame
  if (!is.data.frame(gsea_table)) {
    stop("Error: RDS file does not contain a data frame")
  }
} else {
  gsea_table <- read.csv(input_file, stringsAsFactors = FALSE)
}

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

# Generate summary visualizations
cat("\n=== Generating Summary Visualizations ===\n")

## Figure 1: Filtering Summary (Total + By Contrast)
cat("Creating filtering summary plot...\n")

# Prepare data - count UNIQUE pathways
if ("pathway" %in% colnames(gsea_table)) {
  before_total <- length(unique(gsea_table$pathway))
  after_total <- length(unique(filtered_results$pathway))
} else {
  # Fallback if no pathway column
  before_total <- nrow(gsea_table)
  after_total <- nrow(filtered_results)
}
retention_pct <- round(100 * after_total / before_total, 1)

# Count by contrast
if ("contrast" %in% colnames(gsea_table) && length(unique(gsea_table$contrast)) > 0) {
  before_by_contrast <- gsea_table %>%
    group_by(contrast) %>%
    summarise(count = n(), .groups = "drop") %>%
    mutate(status = "Before")
  
  after_by_contrast <- filtered_results %>%
    group_by(contrast) %>%
    summarise(count = n(), .groups = "drop") %>%
    mutate(status = "After")
  
  contrast_data <- bind_rows(before_by_contrast, after_by_contrast) %>%
    mutate(status = factor(status, levels = c("Before", "After")))
  
  # Create text summary panel with ggplot
  summary_text <- data.frame(
    x = c(1, 2, 3),
    y = c(1, 1, 1),
    label = c(
      paste0(before_total, "\nUnique\nPathways\nBefore"),
      "→",
      paste0(after_total, "\nUnique\nPathways\nAfter\n(", retention_pct, "%)")
    ),
    color = c("before", "arrow", "after")
  )
  
  p1 <- ggplot(summary_text, aes(x = x, y = y, label = label, color = color)) +
    geom_text(size = 9, fontface = "bold", lineheight = 0.85) +
    scale_color_manual(
      values = c("before" = "#E74C3C", "arrow" = "#7F8C8D", "after" = "#27AE60"),
      guide = "none"
    ) +
    labs(title = "Total Unique Pathways Filtered") +
    theme_void() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 16, margin = margin(b = 10)),
      plot.margin = margin(10, 10, 5, 10)
    ) +
    coord_cartesian(xlim = c(0.5, 3.5), ylim = c(0.5, 1.5))
  
  # Create contrast breakdown plot with GROUPED (dodged) bars
  p2 <- ggplot(contrast_data, aes(x = contrast, y = count, fill = status)) +
    geom_bar(stat = "identity", position = "dodge", width = 0.7) +
    scale_fill_manual(
      values = c("Before" = "#E74C3C", "After" = "#27AE60"),
      name = ""
    ) +
    labs(
      title = "Pathways by Contrast",
      x = "",
      y = "Number of Pathways"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 15),
      axis.text.x = element_text(angle = 0, hjust = 0.5, size = 11),
      axis.text.y = element_text(size = 11),
      axis.title.y = element_text(size = 13, face = "bold"),
      legend.position = "top",
      legend.text = element_text(size = 12),
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank()
    )
  
  # Combine plots using patchwork
  combined_plot <- p1 / p2 + plot_layout(heights = c(1, 2))
  
  # Save combined plot
  ggsave(
    "../results/filtering_summary.png",
    plot = combined_plot,
    width = 12,
    height = 8,
    dpi = 150
  )
  
  cat("Filtering summary saved to: ../results/filtering_summary.png\n")
} else {
  cat("Skipping filtering summary plot (no contrast column)\n")
}

## Figure 2: Enrichment Direction by Contrast
cat("Creating enrichment direction plot...\n")

if ("NES" %in% colnames(filtered_results) && "contrast" %in% colnames(filtered_results)) {
  # Check if multiple contrasts exist
  n_contrasts <- length(unique(filtered_results$contrast))
  
  if (n_contrasts > 0) {
    # Prepare data for ggplot with GROUPED (dodged) bars
    direction_data <- filtered_results %>%
      mutate(direction = ifelse(NES > 0, "Positive NES", "Negative NES")) %>%
      group_by(contrast, direction) %>%
      summarise(count = n(), .groups = "drop") %>%
      mutate(direction = factor(direction, levels = c("Negative NES", "Positive NES")))
    
    # Create ggplot with grouped bars
    p <- ggplot(direction_data, aes(x = contrast, y = count, fill = direction)) +
      geom_bar(stat = "identity", position = "dodge", width = 0.7) +
      scale_fill_manual(
        values = c("Negative NES" = "#E67E22", "Positive NES" = "#3498DB"),
        name = ""
      ) +
      labs(
        title = "Enrichment Direction by Contrast",
        x = "",
        y = "Number of Pathways"
      ) +
      theme_minimal(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 16),
        axis.text.x = element_text(angle = 0, hjust = 0.5, vjust = 0.5, size = 12),
        axis.text.y = element_text(size = 12),
        axis.title.y = element_text(size = 14, face = "bold"),
        legend.position = "top",
        legend.text = element_text(size = 12),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank()
      )
    
    # Save plot
    ggsave(
      "../results/enrichment_direction.png",
      plot = p,
      width = 12,
      height = 6,
      dpi = 150
    )
    
    cat("Enrichment direction plot saved to: ../results/enrichment_direction.png\n")
  } else {
    cat("Skipping enrichment direction plot (only one contrast or no NES column)\n")
  }
} else {
  cat("Skipping enrichment direction plot (missing NES or contrast column)\n")
}

# Print comprehensive filtering summary
cat("\n")
cat("=====================================================\n")
cat("           FILTERING SUMMARY                        \n")
cat("=====================================================\n")

# Criteria Applied
cat("\nCriteria Applied:\n")
criteria_list <- c()
if (!is.null(opt$p_value_filter) && opt$p_value_filter != "none") {
  # Normalize p-value filter name for display
  p_filter_lower <- tolower(opt$p_value_filter)
  if (grepl("adjusted", p_filter_lower) || grepl("padj", p_filter_lower) || grepl("fdr", p_filter_lower)) {
    p_label <- "Adjusted p-value"
    is_adjusted <- TRUE
  } else {
    p_label <- "P-value"
    is_adjusted <- FALSE
  }
  
  criteria_list <- c(criteria_list, paste0("  • ", p_label, " < ", opt$p_value_threshold))
  
  # If filtering by adjusted p-value, show FDR correction mode from data
  if (is_adjusted && "fdr_correction_mode" %in% colnames(gsea_table)) {
    fdr_modes <- unique(gsea_table$fdr_correction_mode)
    fdr_modes <- fdr_modes[!is.na(fdr_modes) & fdr_modes != ""]
    if (length(fdr_modes) > 0) {
      criteria_list <- c(criteria_list, paste0("    (FDR mode: ", paste(fdr_modes, collapse = ", "), ")"))
    }
  }
}
if (!is.null(opt$enrichment_score_filter) && opt$enrichment_score_filter != "none") {
  score_label <- toupper(opt$enrichment_score_filter)
  if (opt$enrichment_score_sign == "absolute") {
    criteria_list <- c(criteria_list, paste0("  • |", score_label, "| > ", opt$enrichment_score_threshold))
  } else if (opt$enrichment_score_sign == "positive") {
    criteria_list <- c(criteria_list, paste0("  • ", score_label, " > ", opt$enrichment_score_threshold))
  } else if (opt$enrichment_score_sign == "negative") {
    criteria_list <- c(criteria_list, paste0("  • ", score_label, " < -", opt$enrichment_score_threshold))
  }
}
if (!is.null(opt$size_filter) && (isTRUE(opt$size_filter) || opt$size_filter == "TRUE" || opt$size_filter == TRUE)) {
  criteria_list <- c(criteria_list, paste0("  • Gene set size >= ", opt$size_cutoff))
}
if (!is.null(opt$top_rank_filter) && (isTRUE(opt$top_rank_filter) || opt$top_rank_filter == "TRUE" || opt$top_rank_filter == TRUE)) {
  criteria_list <- c(criteria_list, "  • Top rank filtering enabled")
}
if (!is.null(collections_vec) && length(collections_vec) > 0) {
  criteria_list <- c(criteria_list, paste0("  • Collections: ", paste(collections_vec, collapse = ", ")))
}
if (!is.null(pathways_vec) && length(pathways_vec) > 0) {
  criteria_list <- c(criteria_list, paste0("  • Pathways: ", paste(pathways_vec, collapse = ", ")))
}
if (!is.null(genes_vec) && length(genes_vec) > 0) {
  criteria_list <- c(criteria_list, paste0("  • Genes: ", paste(genes_vec, collapse = ", ")))
}
if (!is.null(contrasts_vec) && length(contrasts_vec) > 0) {
  if (!is.null(opt$contrast_filter) && opt$contrast_filter == "include") {
    criteria_list <- c(criteria_list, paste0("  • Include contrasts: ", paste(contrasts_vec, collapse = ", ")))
  } else {
    criteria_list <- c(criteria_list, paste0("  • Exclude contrasts: ", paste(contrasts_vec, collapse = ", ")))
  }
}

if (length(criteria_list) == 0) {
  cat("  • No filters applied (all pathways retained)\n")
} else {
  cat(paste(criteria_list, collapse = "\n"), "\n")
}

# Overall Results
cat("\nOverall Results:\n")
if ("pathway" %in% colnames(gsea_table)) {
  before_unique <- length(unique(gsea_table$pathway))
  after_unique <- length(unique(filtered_results$pathway))
  unique_retention <- round(100 * after_unique / before_unique, 1)
  cat(sprintf("  • Unique pathways: %d → %d (%.1f%% retained)\n", 
              before_unique, after_unique, unique_retention))
}
before_rows <- nrow(gsea_table)
after_rows <- nrow(filtered_results)
row_retention <- round(100 * after_rows / before_rows, 1)
cat(sprintf("  • Pathway-contrast pairs: %d → %d (%.1f%% retained)\n", 
            before_rows, after_rows, row_retention))

# By Contrast
if ("contrast" %in% colnames(gsea_table) && length(unique(gsea_table$contrast)) > 1) {
  cat("\nBy Contrast:\n")
  contrast_summary <- gsea_table %>%
    group_by(contrast) %>%
    summarise(before = n(), .groups = "drop") %>%
    left_join(
      filtered_results %>% 
        group_by(contrast) %>% 
        summarise(after = n(), .groups = "drop"),
      by = "contrast"
    ) %>%
    mutate(
      after = ifelse(is.na(after), 0, after),
      pct = round(100 * after / before, 1)
    )
  
  for (i in 1:nrow(contrast_summary)) {
    cat(sprintf("  • %-20s: %4d → %4d (%.1f%%)\n",
                contrast_summary$contrast[i],
                contrast_summary$before[i],
                contrast_summary$after[i],
                contrast_summary$pct[i]))
  }
}

# Output Files
cat("\nOutput Files:\n")
cat("  • filtered_gsea_results.csv\n")
cat("  • filtering_summary.png\n")
cat("  • enrichment_direction.png\n")

cat("\n=====================================================\n\n")

# Save filtered results
cat("=== Saving Results ===\n")
write.csv(filtered_results, output_file, row.names = FALSE)
cat(sprintf("Filtered results saved to: %s\n", output_file))

cat("\n=== GSEA Filter Complete ===\n")
