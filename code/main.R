#!/usr/bin/env Rscript

# Main script to run GSEA Filter
# Reads GSEA results table, applies filters, saves filtered output

# Load required libraries
suppressPackageStartupMessages({
  library(dplyr)
  library(ggplot2)
  library(tidyr)
  library(stringr)
  library(plotly)
  library(RColorBrewer)
  library(optparse)
  library(patchwork)
})

# Source the GSEA filter function
source("/code/filter_gsea_function.R")

# Define command line options
option_list <- list(
  make_option("--input_file", type = "character", default = NULL,
              help = "Path to uploaded GSEA results CSV file (takes priority over data assets)"),
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
# Priority: uploaded file > attached data asset
input_file <- NULL
file_format <- NULL
input_source <- NULL

# 1. Check if user uploaded a file via App Panel
if (!is.null(opt$input_file) && opt$input_file != "" && opt$input_file != "NULL") {
  input_file <- opt$input_file
  input_source <- "uploaded file"
  
  # Detect format from file extension
  if (grepl("\\.rds$", input_file, ignore.case = TRUE)) {
    file_format <- "rds"
  } else if (grepl("\\.(csv|tsv|txt)$", input_file, ignore.case = TRUE)) {
    file_format <- "csv"
  } else {
    # Default to CSV for unknown extensions
    file_format <- "csv"
    cat("Warning: Unknown file extension, assuming CSV format\n")
  }
  
  cat("Using uploaded file:", input_file, "\n")
}

# 2. Otherwise, auto-detect GSEA results from attached data asset
if (is.null(input_file)) {
  # Data assets are mounted under /data/<mount_point>
  # Search for gsea_results.csv or gsea_results.rds in /data subdirectories
  data_dirs <- list.dirs("/data", recursive = FALSE, full.names = TRUE)
  
  for (dir in data_dirs) {
    # Check for CSV first
    candidate_csv <- file.path(dir, "gsea_results.csv")
    if (file.exists(candidate_csv)) {
      input_file <- candidate_csv
      file_format <- "csv"
      input_source <- "attached data asset"
      break
    }
    
    # Check for RDS
    candidate_rds <- file.path(dir, "gsea_results.rds")
    if (file.exists(candidate_rds)) {
      input_file <- candidate_rds
      file_format <- "rds"
      input_source <- "attached data asset"
      break
    }
  }
  
  if (!is.null(input_file)) {
    cat("Using file from attached data asset:", input_file, "\n")
  }
}

# 3. Error if no input found
if (is.null(input_file)) {
  stop("Error: No GSEA results file found. Please either:\n",
       "  1. Upload a CSV file via the 'Upload GSEA Results File' parameter, OR\n",
       "  2. Attach a data asset containing 'gsea_results.csv' or 'gsea_results.rds'")
}

output_file <- "../results/filtered_gsea_results.csv"

# Read input GSEA table
cat("Reading GSEA table from:", input_file, "\n")
cat("Input source:", input_source, "\n")
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

# Generate summary visualization
cat("\n=== Generating Summary Visualization ===\n")

cat("Creating filtering summary plot...\n")

# Check if we have the required columns
if ("pathway" %in% colnames(gsea_table) && "NES" %in% colnames(filtered_results) && 
    "contrast" %in% colnames(filtered_results)) {
  
  # Count UNIQUE pathways for top panel
  before_total <- length(unique(gsea_table$pathway))
  after_total <- length(unique(filtered_results$pathway))
  retention_pct <- round(100 * after_total / before_total, 1)
  
  # Top panel: Text summary
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
      values = c("before" = "#EF5350", "arrow" = "#757575", "after" = "#66BB6A"),
      guide = "none"
    ) +
    labs(title = "Total Unique Pathways Filtered") +
    theme_void() +
    theme(
      plot.title = element_text(hjust = 0.5, face = "bold", size = 16, margin = margin(b = 10)),
      plot.margin = margin(10, 10, 5, 10)
    ) +
    coord_cartesian(xlim = c(0.5, 3.5), ylim = c(0.5, 1.5))
  
  # Bottom panel: Enrichment direction by contrast
  # Extract main collection prefix (e.g., "C5:BP:..." -> "C5", "H: hallmark..." -> "H")
  if ("collection" %in% colnames(filtered_results)) {
    filtered_results <- filtered_results %>%
      mutate(main_collection = str_extract(collection, "^[^:]+"))
    
    n_main_collections <- length(unique(filtered_results$main_collection))
  } else {
    n_main_collections <- 0
  }
  
  # Decide whether to use stacked bars by collection (≤12 collections) or simple grouped bars
  use_stacked <- n_main_collections > 0 && n_main_collections <= 12
  
  if (use_stacked) {
    # Stacked bars by main collection
    direction_data <- filtered_results %>%
      mutate(direction = ifelse(NES > 0, "Positive NES", "Negative NES")) %>%
      group_by(contrast, direction, main_collection) %>%
      summarise(count = n(), .groups = "drop") %>%
      mutate(direction = factor(direction, levels = c("Negative NES", "Positive NES")))
    
    # Dynamic width based on number of contrasts
    n_contrasts <- length(unique(direction_data$contrast))
    plot_width <- max(12, 2 + 1.5 * n_contrasts)
    
    # Get contrast order for annotations and separators
    contrast_levels <- unique(direction_data$contrast)
    
    # Calculate vertical separator positions (between contrasts, at midpoints)
    if (n_contrasts > 1) {
      separator_positions <- seq(1.5, n_contrasts - 0.5, by = 1)
    } else {
      separator_positions <- numeric(0)
    }
    
    # Prepare UP/DN annotation data
    annotation_data <- data.frame(
      contrast = rep(contrast_levels, each = 2),
      label = rep(c("DN", "UP"), times = n_contrasts),
      direction = rep(c("Negative NES", "Positive NES"), times = n_contrasts)
    )
    # Match factor levels
    annotation_data$direction <- factor(
      annotation_data$direction, 
      levels = c("Negative NES", "Positive NES")
    )
    
    # Calculate y position for annotations (slightly above max count)
    max_count <- max(direction_data$count, na.rm = TRUE)
    annotation_y <- max_count * 1.05
    
    # Color palette for main collections (using a colorblind-friendly palette)
    collection_colors <- setNames(
      RColorBrewer::brewer.pal(min(12, n_main_collections), "Set3"),
      sort(unique(direction_data$main_collection))
    )
    
    p2 <- ggplot(direction_data, aes(x = contrast, y = count, fill = main_collection)) +
      geom_col(aes(group = direction), position = position_dodge(width = 0.8), width = 0.35) +
      # Add vertical separator lines between contrast groups
      {if (length(separator_positions) > 0) {
        geom_vline(xintercept = separator_positions, linetype = "solid", 
                   color = "gray60", linewidth = 0.6)
      }} +
      # Add UP/DN labels above bars (color-coded to match bars)
      geom_text(
        data = annotation_data,
        aes(x = contrast, y = annotation_y, label = label, color = direction, group = direction),
        position = position_dodge(width = 0.8),
        vjust = -0.5,
        size = 3.5,
        fontface = "bold",
        inherit.aes = FALSE,
        show.legend = FALSE
      ) +
      scale_color_manual(
        values = c("Negative NES" = "#1565C0", "Positive NES" = "#D32F2F")
      ) +
      scale_fill_manual(
        values = collection_colors,
        name = "Collection"
      ) +
      labs(
        title = "Filtered Pathways by Contrast",
        x = "",
        y = "Number of Pathways",
        caption = "Each contrast shows two bars: DN (down-regulated, negative NES) and UP (up-regulated, positive NES)"
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 15),
        plot.caption = element_text(hjust = 0.5, size = 10, color = "gray40", margin = margin(t = 10)),
        axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = 11),
        axis.text.y = element_text(size = 11),
        axis.title.y = element_text(size = 13, face = "bold"),
        legend.position = "right",
        legend.text = element_text(size = 11),
        legend.title = element_text(size = 12, face = "bold"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank()
      ) +
      # Expand y-axis to accommodate UP/DN labels
      scale_y_continuous(expand = expansion(mult = c(0.02, 0.12)))
  } else {
    # Simple grouped bars by direction (fallback)
    direction_data <- filtered_results %>%
      mutate(direction = ifelse(NES > 0, "Positive NES", "Negative NES")) %>%
      group_by(contrast, direction) %>%
      summarise(count = n(), .groups = "drop") %>%
      mutate(direction = factor(direction, levels = c("Negative NES", "Positive NES")))
    
    # Dynamic width based on number of contrasts
    n_contrasts <- length(unique(direction_data$contrast))
    plot_width <- max(12, 2 + 1.5 * n_contrasts)
    
    # Get contrast order for annotations and separators
    contrast_levels <- unique(direction_data$contrast)
    
    # Calculate vertical separator positions (between contrasts, at midpoints)
    if (n_contrasts > 1) {
      separator_positions <- seq(1.5, n_contrasts - 0.5, by = 1)
    } else {
      separator_positions <- numeric(0)
    }
    
    # Prepare UP/DN annotation data
    annotation_data <- data.frame(
      contrast = rep(contrast_levels, each = 2),
      label = rep(c("DN", "UP"), times = n_contrasts),
      direction = rep(c("Negative NES", "Positive NES"), times = n_contrasts)
    )
    # Match factor levels
    annotation_data$direction <- factor(
      annotation_data$direction, 
      levels = c("Negative NES", "Positive NES")
    )
    
    # Calculate y position for annotations (slightly above max count)
    max_count <- max(direction_data$count, na.rm = TRUE)
    annotation_y <- max_count * 1.05
    
    p2 <- ggplot(direction_data, aes(x = contrast, y = count, fill = direction)) +
      geom_bar(stat = "identity", position = "dodge", width = 0.7) +
      # Add vertical separator lines between contrast groups
      {if (length(separator_positions) > 0) {
        geom_vline(xintercept = separator_positions, linetype = "solid", 
                   color = "gray60", linewidth = 0.6)
      }} +
      # Add UP/DN labels above bars (color-coded to match bars)
      geom_text(
        data = annotation_data,
        aes(x = contrast, y = annotation_y, label = label, color = direction, group = direction),
        position = position_dodge(width = 0.7),
        vjust = -0.5,
        size = 3.5,
        fontface = "bold",
        inherit.aes = FALSE,
        show.legend = FALSE
      ) +
      scale_color_manual(
        values = c("Negative NES" = "#1565C0", "Positive NES" = "#D32F2F")
      ) +
      scale_fill_manual(
        values = c("Negative NES" = "#1565C0", "Positive NES" = "#D32F2F"),
        name = ""
      ) +
      labs(
        title = "Filtered Pathways by Contrast",
        x = "",
        y = "Number of Pathways",
        caption = "Each contrast shows two bars: DN (down-regulated, negative NES) and UP (up-regulated, positive NES)"
      ) +
      theme_minimal(base_size = 13) +
      theme(
        plot.title = element_text(hjust = 0.5, face = "bold", size = 15),
        plot.caption = element_text(hjust = 0.5, size = 10, color = "gray40", margin = margin(t = 10)),
        axis.text.x = element_text(angle = 45, hjust = 1, vjust = 1, size = 11),
        axis.text.y = element_text(size = 11),
        axis.title.y = element_text(size = 13, face = "bold"),
        legend.position = "top",
        legend.text = element_text(size = 12),
        panel.grid.major.x = element_blank(),
        panel.grid.minor = element_blank()
      ) +
      # Expand y-axis to accommodate UP/DN labels
      scale_y_continuous(expand = expansion(mult = c(0.02, 0.12)))
  }
  
  # Combine plots using patchwork
  combined_plot <- p1 / p2 + plot_layout(heights = c(1, 2))
  
  # Save combined plot with dynamic width
  ggsave(
    "../results/filtering_summary.png",
    plot = combined_plot,
    width = plot_width,
    height = 8,
    dpi = 150
  )
  
  cat("Filtering summary saved to: ../results/filtering_summary.png\n")
} else {
  cat("Skipping filtering summary plot (missing required columns)\n")
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
