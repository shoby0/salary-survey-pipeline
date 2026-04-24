# 02_diagnose.R
# Purpose: Run exploratory diagnostics on the raw dataset
# Produces missingness counts, data type checks, duplicate checks and range checks
# No cleaning happens in this script
# All findings feed into the problem inventory
# Author: Shoaib
# Date: April 2026

source("scripts/00_config.R")
source("scripts/01_ingest.R")

library(dplyr)

cat("Starting diagnostics...\n")

cat("\n--- Dataset Dimensions ---\n")
cat("Rows:", nrow(df_raw), "\n")
cat("Columns:", ncol(df_raw), "\n")

cat("\n--- Missing Values Per Column ---\n")
missing_counts <- colSums(is.na(df_raw))
missing_pct <- round(missing_counts / nrow(df_raw) * 100, 2)
missing_summary <- data.frame(
  column = names(missing_counts),
  missing_count = missing_counts,
  missing_pct = missing_pct
)
print(missing_summary)

cat("\n--- Duplicate Rows ---\n")
duplicate_count <- sum(duplicated(df_raw))
cat("Number of exact duplicate rows:", duplicate_count, "\n")

cat("\n--- Salary Column Summary ---\n")
salary_col <- df_raw[[6]]
cat("Min salary:", min(salary_col, na.rm = TRUE), "\n")
cat("Max salary:", max(salary_col, na.rm = TRUE), "\n")
cat("Mean salary:", round(mean(salary_col, na.rm = TRUE), 2), "\n")
cat("Median salary:", median(salary_col, na.rm = TRUE), "\n")
cat("Salaries below", salary_min, ":", sum(salary_col < salary_min, na.rm = TRUE), "\n")
cat("Salaries above", salary_max, ":", sum(salary_col > salary_max, na.rm = TRUE), "\n")

cat("\n--- Currency Values ---\n")
print(table(df_raw[["Please indicate the currency"]]))

cat("\n--- Age Values ---\n")
print(table(df_raw[["How old are you?"]]))

cat("\n--- Gender Values ---\n")
print(table(df_raw[["What is your gender?"]]))

cat("\n--- Education Values ---\n")
print(table(df_raw[["What is your highest level of education completed?"]]))

cat("\n--- Top 20 Country Values ---\n")
country_counts <- sort(table(df_raw[["What country do you work in?"]]), decreasing = TRUE)
print(head(country_counts, 20))

cat("\n--- Years Experience Overall ---\n")
print(table(df_raw[["How many years of professional work experience do you have overall?"]]))

cat("\nDiagnostics complete\n")