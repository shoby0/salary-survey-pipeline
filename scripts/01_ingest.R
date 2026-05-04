# 01_ingest.R
# Purpose: Read the raw dataset and verify it loaded correctly
# Checks row and column counts against expected values from 00_config.R
# Saves a copy of the raw data to the data_raw folder for reference
# No changes are made to the data in this script
# Author: Shoaib
# Date: April 2026

source("scripts/00_config.R")

library(readxl)

cat("Loading raw dataset...\n")

df_raw <- read_excel(raw_data_path)

cat("Rows loaded:", nrow(df_raw), "\n")
cat("Columns loaded:", ncol(df_raw), "\n")

if (nrow(df_raw) == expected_rows) {
  cat("Row count check passed\n")
} else {
  cat("WARNING row count does not match expected", expected_rows, "\n")
}

if (ncol(df_raw) == expected_cols) {
  cat("Column count check passed\n")
} else {
  cat("WARNING column count does not match expected", expected_cols, "\n")
}

cat("Column names:\n")
print(names(df_raw))

cat("Data types for each column:\n")
print(sapply(df_raw, class))

saveRDS(df_raw, file = paste0(raw_path, "raw_data.rds"))

cat("Raw data saved to data_raw folder\n")
cat("Ingest complete\n")