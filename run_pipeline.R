# run_pipeline.R
# Purpose: Single entry point that runs the entire pipeline
# Run this file to produce all outputs including the Word report
# Usage: source("run_pipeline.R")
# Author: Shoaib
# Date: May 2026

source("scripts/00_config.R")
source("scripts/01_ingest.R")
source("scripts/02_diagnose.R")
source("scripts/03_clean.R")
source("scripts/04_impute.R")
source("scripts/05_export.R")

cat("Rendering Word report...\n")
quarto::quarto_render("scripts/06_report.qmd")
file.copy("scripts/06_report.docx", "outputs/report.docx", overwrite = TRUE)
file.remove("scripts/06_report.docx")
cat("Report saved to outputs/report.docx\n")
cat("Pipeline complete\n")