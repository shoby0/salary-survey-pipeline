# Salary Survey Data Cleaning Pipeline

**Author:** Shoaib
**Dataset:** Ask A Manager Salary Survey 2021
**Assessment:** Bureau of Statistics Guyana | Analytical Unit
**Duration:** 3 weeks
**Repository:** shoby0/salary-survey-pipeline

## Overview

This repository contains an end to end data cleaning and imputation pipeline built in R. The pipeline ingests the Ask A Manager Salary Survey 2021 dataset, diagnoses data quality issues, applies cleaning and imputation across all 18 variables, exports the cleaned dataset in four formats and renders an automated Word report.

## How to Run

Clone the repository and open the project in RStudio. Make sure the raw dataset is placed in the raw/ folder. Then run a single command:

```r
source("run_pipeline.R")
```

This single command will execute the following in order:

1. Load all paths and parameters from 00_config.R
2. Ingest the raw data and validate row and column counts
3. Run exploratory diagnostics and log all findings
4. Apply 16 cleaning stages one issue class at a time
5. Apply imputation to education, gender, race and additional compensation
6. Export the cleaned dataset in all four formats
7. Render the automated Word report

All outputs are saved to the outputs/ folder.

## Repository Structure

| Folder or File | Purpose |
|---|---|
| raw/ | Raw dataset stored here and never modified |
| data_clean/ | Intermediate cleaned data saved between pipeline stages |
| outputs/ | Final cleaned datasets in all four formats, data dictionary and Word report |
| reports/ | Weekly Friday progress reports and problem inventory |
| presentation/ | Final PowerPoint presentation |
| scripts/ | All R pipeline scripts |
| run_pipeline.R | Single entry point that runs the full pipeline |
| README.md | This document |

## Pipeline Scripts

| Script | Purpose |
|---|---|
| 00_config.R | All paths, thresholds and parameters. Change settings here only. |
| 01_ingest.R | Reads raw Excel file and validates row and column counts |
| 02_diagnose.R | Exploratory diagnostics covering missingness, types, duplicates and ranges |
| 03_clean.R | 16 cleaning stages applied one issue class at a time with logging |
| 04_impute.R | Basic imputation applied to 4 variables with documented justification |
| 05_export.R | Exports cleaned dataset as .sav, .dta, .xlsx and .rds |
| 06_report.qmd | Quarto report rendered as Word document with 5 charts |

## Dataset

| Field | Detail |
|---|---|
| Source | Ask A Manager Salary Survey 2021 |
| Raw size | 28,215 rows x 18 columns |
| Download date | April 2026 |
| Scope | All 18 variables cleaned |

## Outputs

The outputs/ folder contains:

- cleaned_salary_survey.rds — native R format preserving all attributes
- cleaned_salary_survey.xlsx — Excel with cleaned data and data dictionary sheets
- cleaned_salary_survey.sav — SPSS format with variable labels
- cleaned_salary_survey.dta — Stata version 15 format with variable labels
- data_dictionary.csv — one row per variable with all required fields
- report.docx — automated Word report rendered by the pipeline

## Dependencies

Install required packages before running:

```r
install.packages(c("readxl", "dplyr", "stringr", "haven", "openxlsx"))
```

Quarto must be installed to render the Word report. Download from https://quarto.org

| Package | Purpose |
|---|---|
| readxl | Read raw Excel file |
| dplyr | Data manipulation |
| stringr | String cleaning and standardisation |
| haven | Export to SPSS and Stata formats |
| openxlsx | Export to Excel with multiple sheets |

## Notes

Raw data is never edited in place. All transformations are applied to a working copy only.

Python users can read the .sav and .dta outputs using pyreadstat. No separate Python export is produced.

All cleaning decisions are logged with row counts before and after each stage. All parameters including thresholds and file paths are stored in 00_config.R only.
