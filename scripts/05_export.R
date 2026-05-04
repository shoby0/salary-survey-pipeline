# 05_export.R
# Purpose: Export the cleaned and imputed dataset in all four required formats
# Formats: .sav (SPSS), .dta (Stata), .xlsx (Excel), .rds (R native)
# Variable labels and value labels are preserved where supported
# The data dictionary is also included as a sheet in the Excel export
# Author: Shoaib
# Date: May 2026

source("scripts/00_config.R")

library(haven)
library(openxlsx)

cat("Loading imputed dataset for export\n")
df <- readRDS(paste0(data_clean_path, "df_imputed.rds"))

cat("Rows:", nrow(df), "\n")
cat("Columns:", ncol(df), "\n\n")

# Load data dictionary for inclusion in Excel export
data_dict <- read.csv(paste0(outputs_path, "data_dictionary.csv"),
                      stringsAsFactors = FALSE)

# Keep only the original 18 variables for export
# Flag columns are internal pipeline columns not needed in final output
df_export <- df[, 1:18]

cat("Columns in export dataset:", ncol(df_export), "\n\n")


# ===========================================================================
# EXPORT 1: .rds - Native R format
# Why first: Preserves all R attributes and is the most complete format
# ===========================================================================
cat("--- EXPORT 1: Saving as .rds ---\n")

saveRDS(df_export,
        file = paste0(outputs_path, cleaned_file_name, ".rds"))

cat("Saved:", paste0(outputs_path, cleaned_file_name, ".rds"), "\n\n")


# ===========================================================================
# EXPORT 2: .xlsx - Excel format
# Includes two sheets: cleaned data and data dictionary
# ===========================================================================
cat("--- EXPORT 2: Saving as .xlsx ---\n")

wb <- createWorkbook()

addWorksheet(wb, "cleaned_data")
writeData(wb, "cleaned_data", df_export)

addWorksheet(wb, "data_dictionary")
writeData(wb, "data_dictionary", data_dict)

saveWorkbook(wb,
             file = paste0(outputs_path, cleaned_file_name, ".xlsx"),
             overwrite = TRUE)

cat("Saved:", paste0(outputs_path, cleaned_file_name, ".xlsx"), "\n")
cat("Sheets: cleaned_data and data_dictionary\n\n")


# ===========================================================================
# EXPORT 3: .sav - SPSS format
# Variable labels preserved using haven
# Note: Column names must be valid SPSS names so we use short names
# ===========================================================================
cat("--- EXPORT 3: Saving as .sav ---\n")

df_sav <- df_export

# Add variable labels for SPSS
var_labels <- list(
  timestamp         = "Timestamp of survey submission",
  age               = "Age group of respondent",
  industry          = "Industry respondent works in",
  job_title         = "Job title of respondent",
  job_title_context = "Additional context for job title",
  annual_salary     = "Annual salary in stated currency",
  additional_comp   = "Additional monetary compensation",
  currency          = "Currency of salary",
  currency_other    = "Currency name if Other selected",
  income_context    = "Additional income context",
  country           = "Country respondent works in",
  us_state          = "US state respondent works in",
  city              = "City respondent works in",
  exp_overall       = "Years of professional experience overall",
  exp_field         = "Years of professional experience in field",
  education         = "Highest level of education completed",
  gender            = "Gender of respondent",
  race              = "Race of respondent"
)

for (col in names(var_labels)) {
  attr(df_sav[[col]], "label") <- var_labels[[col]]
}

write_sav(df_sav,
          path = paste0(outputs_path, cleaned_file_name, ".sav"))

cat("Saved:", paste0(outputs_path, cleaned_file_name, ".sav"), "\n\n")


# ===========================================================================
# EXPORT 4: .dta - Stata format
# Variable labels preserved using haven
# Note: Stata variable names cannot exceed 32 characters
# ===========================================================================
cat("--- EXPORT 4: Saving as .dta ---\n")

df_dta <- df_sav

write_dta(df_dta,
          path = paste0(outputs_path, cleaned_file_name, ".dta"),
          version = 15)

cat("Saved:", paste0(outputs_path, cleaned_file_name, ".dta"), "\n\n")


# ===========================================================================
# FINAL SUMMARY
# ===========================================================================
cat("=== EXPORT COMPLETE ===\n")
cat("All four formats saved to:", outputs_path, "\n\n")

cat("Files produced:\n")
cat(" ", paste0(cleaned_file_name, ".rds"), "\n")
cat(" ", paste0(cleaned_file_name, ".xlsx"), "\n")
cat(" ", paste0(cleaned_file_name, ".sav"), "\n")
cat(" ", paste0(cleaned_file_name, ".dta"), "\n\n")

cat("Note: Python users can read .sav and .dta files using pyreadstat\n")
cat("No separate Python export is required\n")
cat("Export pipeline complete\n")