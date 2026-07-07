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
  
  # Check the USER'S filtering parameter (not what ended up in results)
  # to properly count direction-specific pathways
  if (opt$enrichment_score_sign == "-") {
    # Negative only - count DN pathways before
    before_total <- length(unique(gsea_table$pathway[gsea_table$NES < 0]))
    after_total <- length(unique(filtered_results$pathway))
    retention_pct <- round(100 * after_total / before_total, 1)
    before_label <- paste0(before_total, "\nUnique DN\nPathways\nBefore")
    after_label <- paste0(after_total, "\nUnique DN\nPathways\nAfter\n(", retention_pct, "%)")
  } else if (opt$enrichment_score_sign == "+") {
    # Positive only - count UP pathways before
    before_total <- length(unique(gsea_table$pathway[gsea_table$NES > 0]))
    after_total <- length(unique(filtered_results$pathway))
    retention_pct <- round(100 * after_total / before_total, 1)
    before_label <- paste0(before_total, "\nUnique UP\nPathways\nBefore")
    after_label <- paste0(after_total, "\nUnique UP\nPathways\nAfter\n(", retention_pct, "%)")
  } else {
    # Both directions - count all pathways (no DN/UP breakdown since pathways can be both across contrasts)
    before_total <- length(unique(gsea_table$pathway))
    after_total <- length(unique(filtered_results$pathway))
    retention_pct <- round(100 * after_total / before_total, 1)
    before_label <- paste0(before_total, "\nUnique\nPathways\nBefore")
    after_label <- paste0(after_total, "\nUnique\nPathways\nAfter\n(", retention_pct, "%)")
  }
  
  # Top panel: Text summary
  summary_text <- data.frame(
    x = c(1, 2, 3),
    y = c(1, 1, 1),
    label = c(
      before_label,
      "→",
      after_label
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
    
    # Prepare UP/DN annotation data - only for bars that actually exist in the data
    # Calculate the total height of each stacked bar (sum of all collections per contrast-direction)
    bar_heights <- direction_data %>%
      group_by(contrast, direction) %>%
      summarise(total_count = sum(count), .groups = "drop")
    
    # Detect which directions exist in the actual data
    has_negative <- any(bar_heights$direction == "Negative NES")
    has_positive <- any(bar_heights$direction == "Positive NES")
    
    # Create a mapping of contrast-direction to x-position based on actual data
    # This handles cases where some contrasts might only have UP or only have DN
    bar_heights <- bar_heights %>%
      arrange(contrast, direction) %>%
      mutate(x_pos = row_number())
    
    # Find the maximum bar height across all bars for uniform label positioning
    max_bar_height <- max(bar_heights$total_count, na.rm = TRUE)
    
    # Build annotation data only for bars that exist
    # All labels positioned at the same level (max height)
    annotation_data <- bar_heights %>%
      mutate(
        label = ifelse(direction == "Negative NES", "DN", "UP"),
        y_pos = max_bar_height  # Use uniform height for all labels
      ) %>%
      select(contrast, direction, x_pos, y_pos, label)
    
    # Match factor levels
    annotation_data$direction <- factor(
      annotation_data$direction, 
      levels = c("Negative NES", "Positive NES")
    )
    
    # Recalculate separator positions based on actual bar layout
    # Find positions where contrast changes
    contrast_changes <- bar_heights %>%
      mutate(
        next_contrast = lead(contrast),
        is_boundary = contrast != next_contrast & !is.na(next_contrast)
      ) %>%
      filter(is_boundary) %>%
      mutate(sep_pos = x_pos + 0.5) %>%
      pull(sep_pos)
    
    separator_positions <- contrast_changes
    
    # Calculate x-axis label positions (one per contrast, centered)
    contrast_positions <- bar_heights %>%
      group_by(contrast) %>%
      summarise(
        x_min = min(x_pos),
        x_max = max(x_pos),
        x_center = mean(c(x_min, x_max)),
        .groups = "drop"
      )
    
    contrast_label_positions <- contrast_positions$x_center
    contrast_levels_ordered <- contrast_positions$contrast
    
    # Color palette for main collections (using a colorblind-friendly palette)
    collection_colors <- setNames(
      RColorBrewer::brewer.pal(min(12, n_main_collections), "Set3"),
      sort(unique(direction_data$main_collection))
    )
    
    p2 <- ggplot(direction_data, aes(x = interaction(contrast, direction), y = count, fill = main_collection)) +
      geom_col(position = "stack", width = 0.7) +
      scale_x_discrete(
        breaks = contrast_label_positions,
        labels = contrast_levels_ordered
      ) +
      # Add vertical separator lines between contrast groups
      {if (length(separator_positions) > 0) {
        geom_vline(xintercept = separator_positions, linetype = "solid", 
                   color = "gray60", linewidth = 0.6)
      }} +
      # Add UP/DN labels above bars (color-coded to match bars)
      geom_text(
        data = annotation_data,
        aes(x = x_pos, y = y_pos, label = label, color = direction),
        vjust = -0.2,
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
        caption = if (has_negative && has_positive) {
          "Each contrast shows two bars: DN (down-regulated, negative NES) and UP (up-regulated, positive NES)"
        } else if (has_negative) {
          "Bars show DN (down-regulated, negative NES) pathways only"
        } else {
          "Bars show UP (up-regulated, positive NES) pathways only"
        }
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
    
    # Prepare UP/DN annotation data - only for bars that actually exist in the data
    # Calculate the total height of each stacked bar (sum of all collections per contrast-direction)
    bar_heights <- direction_data %>%
      group_by(contrast, direction) %>%
      summarise(total_count = sum(count), .groups = "drop")
    
    # Detect which directions exist in the actual data
    has_negative <- any(bar_heights$direction == "Negative NES")
    has_positive <- any(bar_heights$direction == "Positive NES")
    
    # Create a mapping of contrast-direction to x-position based on actual data
    # This handles cases where some contrasts might only have UP or only have DN
    bar_heights <- bar_heights %>%
      arrange(contrast, direction) %>%
      mutate(x_pos = row_number())
    
    # Find the maximum bar height across all bars for uniform label positioning
    max_bar_height <- max(bar_heights$total_count, na.rm = TRUE)
    
    # Build annotation data only for bars that exist
    # All labels positioned at the same level (max height)
    annotation_data <- bar_heights %>%
      mutate(
        label = ifelse(direction == "Negative NES", "DN", "UP"),
        y_pos = max_bar_height  # Use uniform height for all labels
      ) %>%
      select(contrast, direction, x_pos, y_pos, label)
    
    # Match factor levels
    annotation_data$direction <- factor(
      annotation_data$direction, 
      levels = c("Negative NES", "Positive NES")
    )
    
    # Recalculate separator positions based on actual bar layout
    # Find positions where contrast changes
    contrast_changes <- bar_heights %>%
      mutate(
        next_contrast = lead(contrast),
        is_boundary = contrast != next_contrast & !is.na(next_contrast)
      ) %>%
      filter(is_boundary) %>%
      mutate(sep_pos = x_pos + 0.5) %>%
      pull(sep_pos)
    
    separator_positions <- contrast_changes
    
    # Calculate x-axis label positions (one per contrast, centered)
    contrast_positions <- bar_heights %>%
      group_by(contrast) %>%
      summarise(
        x_min = min(x_pos),
        x_max = max(x_pos),
        x_center = mean(c(x_min, x_max)),
        .groups = "drop"
      )
    
    contrast_label_positions <- contrast_positions$x_center
    contrast_levels_ordered <- contrast_positions$contrast
    
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
        caption = if (has_negative && has_positive) {
          "Each contrast shows two bars: DN (down-regulated, negative NES) and UP (up-regulated, positive NES)"
        } else if (has_negative) {
          "Bars show DN (down-regulated, negative NES) pathways only"
        } else {
          "Bars show UP (up-regulated, positive NES) pathways only"
        }
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


# Filtering summary removed - all information is in the filtering_summary.png visualization

# Save filtered results
cat("=== Saving Results ===\n")
write.csv(filtered_results, output_file, row.names = FALSE)
cat(sprintf("Filtered results saved to: %s\n", output_file))

cat("\n=== GSEA Filter Complete ===\n")
