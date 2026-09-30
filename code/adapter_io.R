# Code Ocean input translation for the OMIX GSEA Filters adapter.
# Scientific filtering remains in code/functions/filter_gsea_function.R.

resolve_gsea_input <- function(explicit_input = NULL, data_root = "/data") {
  if (!is.null(explicit_input) && nzchar(trimws(explicit_input)) &&
      !identical(explicit_input, "NULL")) {
    if (!file.exists(explicit_input)) {
      stop("ERROR: Uploaded GSEA results file was not found: ", explicit_input)
    }
    return(list(path = normalizePath(explicit_input), source = "uploaded file"))
  }

  candidates <- character()
  if (dir.exists(data_root)) {
    candidates <- list.files(
      data_root,
      pattern = "^gsea_results\\.(csv|tsv|txt|rds)$",
      recursive = TRUE,
      full.names = TRUE,
      ignore.case = TRUE
    )
    candidates <- sort(normalizePath(candidates))
  }

  if (length(candidates) == 0L) {
    stop(
      "ERROR: No GSEA results table was found. Upload one explicitly or ",
      "attach a data asset containing exactly one file named ",
      "gsea_results.csv, gsea_results.tsv, gsea_results.txt, or gsea_results.rds."
    )
  }
  if (length(candidates) > 1L) {
    stop(
      "ERROR: Multiple GSEA results candidates were found. Upload the intended ",
      "file explicitly:\n", paste(candidates, collapse = "\n")
    )
  }

  list(path = candidates[[1L]], source = "attached data asset")
}

read_gsea_results <- function(path) {
  if (!file.exists(path)) {
    stop("ERROR: Input file was not found: ", path)
  }

  extension <- tolower(tools::file_ext(path))
  value <- switch(
    extension,
    rds = readRDS(path),
    csv = read.csv(path, stringsAsFactors = FALSE, check.names = FALSE),
    tsv = read.delim(path, stringsAsFactors = FALSE, check.names = FALSE),
    txt = read.delim(path, stringsAsFactors = FALSE, check.names = FALSE),
    stop("ERROR: Unsupported GSEA results format: ", path)
  )
  if (!is.data.frame(value)) {
    stop("ERROR: GSEA results input must contain a data frame: ", path)
  }
  value
}
