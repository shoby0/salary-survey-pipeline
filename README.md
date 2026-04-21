# Salary Survey Data Cleaning Pipeline

**Author:** Shoaib  
**Dataset:** Ask A Manager Salary Survey 2021  
**Assessment:** Bureau of Statistics Guyana | Analytical Unit  
**Duration:** 3 weeks  
**Repo:** shoby0/salary-survey-pipeline

## Overview

This repository contains an end to end data cleaning and imputation pipeline built in R, producing a cleaned dataset in multiple formats and an automated Word report.

## Repository Structure

```
salary-survey-pipeline/
│
├── raw/                    # Raw dataset (unmodified)
├── data/                   # Intermediate processed data
├── outputs/                # Final cleaned datasets and report
│   ├── cleaned.sav
│   ├── cleaned.dta
│   ├── cleaned.xlsx
│   ├── cleaned.rds
│   ├── data_dictionary.csv
│   └── report.docx
├── reports/                # Weekly Friday progress reports
│   ├── week1_report.docx
│   ├── week2_report.docx
│   └── week3_report.docx
├── presentation/           # Final PowerPoint
│   └── final_presentation.pptx
├── scripts/                # R pipeline scripts
│   ├── 00_config.R
│   ├── 01_ingest.R
│   ├── 02_diagnose.R
│   ├── 03_clean.R
│   ├── 04_impute.R
│   ├── 05_export.R
│   └── 06_report.qmd
├── run_pipeline.R          # Single entry point runs everything
└── README.md
```

## How to Run

Full instructions will be completed by end of Week 3.

```r
# Clone the repo
# Open RStudio and open the project
# Then run:
source("run_pipeline.R")
```

This single command will:

1. Ingest the raw data
2. Run exploratory diagnostics
3. Execute all cleaning stages
4. Apply imputation
5. Export cleaned data in all four formats
6. Render the Word report

## Dataset

**Source:** Ask A Manager Salary Survey 2021  
**Raw size:** 28,215 rows x 18 columns  
**Download date:** April 2026  
**Assigned variables:** To be confirmed by evaluating office  

## Dependencies

Full package list will be added after environment setup.

Key R packages anticipated:

| Package | Purpose |
|---------|---------|
| tidyverse, janitor | Data cleaning |
| naniar, visdat | Missingness diagnostics |
| stringdist | Approximate string matching |
| haven, openxlsx | Multi format export |
| VIM | Hot deck imputation |
| quarto or rmarkdown | Automated Word report |

## Pipeline Stages

| Script | Purpose | Status |
|--------|---------|--------|
| 00_config.R | Paths, thresholds, parameters | Pending |
| 01_ingest.R | Read raw data, validate load | Pending |
| 02_diagnose.R | Exploratory diagnostics and logging | Pending |
| 03_clean.R | Cleaning stages by issue class | Pending |
| 04_impute.R | Basic imputation | Pending |
| 05_export.R | Multi format export | Pending |
| 06_report.qmd | Automated Word report | Pending |

## Weekly Progress

| Week | Focus | Friday Report |
|------|-------|--------------|
| Week 1 | Setup, ingest, diagnostics, problem inventory | Pending |
| Week 2 | Cleaning pipeline, data dictionary, report scaffold | Pending |
| Week 3 | Imputation, exports, finalise, present | Pending |

## Notes

Raw data is never edited in place. All transformations are applied in scripts only.

Python users read .sav and .dta outputs via pyreadstat. No separate Python export is produced.

All cleaning decisions are logged with row counts before and after each stage.

This README will be updated progressively as the pipeline is built.
