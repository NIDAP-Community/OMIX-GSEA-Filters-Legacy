#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = FALSE)
script <- sub("^--file=", "", args[grepl("^--file=", args)])
root <- normalizePath(file.path(dirname(script), ".."))
source(file.path(root, "code", "adapter_io.R"))

fixture_root <- tempfile("gsea-adapter-io-")
dir.create(file.path(fixture_root, "one"), recursive = TRUE)
on.exit(unlink(fixture_root, recursive = TRUE, force = TRUE), add = TRUE)

fixture <- data.frame(
  contrast = "B-A",
  collection = "H",
  pathway = "HALLMARK_TEST",
  check.names = FALSE
)
tsv_path <- file.path(fixture_root, "one", "gsea_results.tsv")
write.table(fixture, tsv_path, sep = "\t", quote = FALSE, row.names = FALSE)

resolved <- resolve_gsea_input(data_root = fixture_root)
stopifnot(
  identical(resolved$path, normalizePath(tsv_path)),
  identical(resolved$source, "attached data asset"),
  identical(read_gsea_results(tsv_path), fixture)
)

csv_path <- file.path(fixture_root, "explicit.csv")
write.csv(fixture, csv_path, row.names = FALSE)
resolved_explicit <- resolve_gsea_input(csv_path, data_root = fixture_root)
stopifnot(
  identical(resolved_explicit$path, normalizePath(csv_path)),
  identical(resolved_explicit$source, "uploaded file")
)

dir.create(file.path(fixture_root, "two"))
file.copy(tsv_path, file.path(fixture_root, "two", "gsea_results.txt"))
multiple_error <- tryCatch(
  { resolve_gsea_input(data_root = fixture_root); NULL },
  error = identity
)
stopifnot(
  inherits(multiple_error, "error"),
  grepl("Multiple GSEA results candidates", conditionMessage(multiple_error), fixed = TRUE)
)

empty_root <- tempfile("gsea-adapter-empty-")
dir.create(empty_root)
on.exit(unlink(empty_root, recursive = TRUE, force = TRUE), add = TRUE)
missing_error <- tryCatch(
  { resolve_gsea_input(data_root = empty_root); NULL },
  error = identity
)
stopifnot(
  inherits(missing_error, "error"),
  grepl("No GSEA results table", conditionMessage(missing_error), fixed = TRUE)
)

message("GSEA Filters adapter I/O checks passed")
