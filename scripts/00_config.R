# 00_config.R
# Purpose: Central configuration file for the salary survey cleaning pipeline
# All file paths, folder paths, thresholds and parameters are defined here
# No data processing happens in this script
# Every other script sources this file first before doing anything
# Author: Shoaib
# Date: 23 April 2026

# Path to the raw Excel file provided for the assessment
raw_data_path <- "C:/Users/sharoon/OneDrive - Bureau of Statistics/Documents/Gavin Work Assignments - Test Projects/Ask A Manager Salary Survey 2021/download/Ask A Manager Salary Survey 2021.xlsx"

# Folder where raw data is stored and never modified
data_raw_path <- "data_raw/"

# Folder where intermediate cleaned data is saved between stages
data_clean_path <- "data_clean/"

# Folder where final outputs are saved including all four export formats
outputs_path <- "outputs/"

# Folder where weekly Friday progress reports are saved
reports_path <- "weekly_reports/"

# Expected number of rows and columns when the raw file is loaded
# Used in 01_ingest.R to confirm the data loaded correctly
expected_rows <- 28215
expected_cols <- 18

# Salary values below this threshold are flagged as potentially incorrect
# Based on the assumption that all salaries are reported annually in full
salary_min <- 1000

# Salary values above this threshold are flagged as potentially incorrect
salary_max <- 1000000

# Method used for outlier detection in numeric variables
outlier_method <- "IQR"

# Default imputation method for numeric variables with skew or outliers
impute_numeric <- "median"

# Default imputation method for categorical variables
impute_categorical <- "mode"

# Base file name used when exporting the cleaned dataset in all four formats
cleaned_file_name <- "cleaned_salary_survey"

cat("Config loaded successfully\n")