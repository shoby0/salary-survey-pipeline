# run_pipeline.R
# Purpose: Single entry point that runs the entire pipeline
# Run this file to produce all outputs
# Usage: source("run_pipeline.R")
# Author: Shoaib
# Date: April 2026

source("scripts/00_config.R")
source("scripts/01_ingest.R")
source("scripts/02_diagnose.R")
source("scripts/03_clean.R")
source("scripts/04_impute.R")
source("scripts/05_export.R")
