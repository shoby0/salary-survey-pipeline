Problem Inventory
Dataset: Ask A Manager Salary Survey 2021
Author: Shoaib
Date: April 23, 2026

Issue 1: Country Name Inconsistency
Column: What country do you work in?
The same country appears in many different formats.
Examples: United States, USA, US, U.S., Usa, usa, United states, united states
At least 9 variants for USA alone were found.
Action: Standardise all variants to one canonical name per country.

Issue 2: Salary Outliers
Column: Annual salary
Salary values range from 0 to 6,000,070,000.
136 salaries are below 1,000 and are likely data entry errors.
79 salaries are above 1,000,000 and will be flagged.
Two rows contained the value 00 which were coerced to 0 on load.
Action: Flag outliers using IQR method. Do not drop any rows.

Issue 3: Additional Compensation Stored as Character
Column: Additional monetary compensation
This column should be numeric but loaded as character type.
Some entries likely contain text or symbols instead of numbers.
Action: Coerce to numeric and log any values that fail coercion.

Issue 4: Structural Missingness in Optional Columns
Columns: Job title context 74%, Income context 89%, Currency other 99%
These columns were optional in the survey form.
Missing values here are expected and informative, not errors.
Action: Leave as is and document as structurally missing.

Issue 5: Incidental Missingness in Key Columns
Additional compensation: 26% missing
US State: 18% missing, expected for non US respondents
Education: 0.85% missing
Gender: 0.66% missing
Race: 0.69% missing
Industry: 0.29% missing
Action: Apply appropriate imputation method per variable.

Issue 6: Gender Category Inconsistency
Column: What is your gender?
Prefer not to answer has 1 entry.
Other or prefer not to answer has 298 entries.
These two categories mean the same thing.
Action: Merge into one standard category.

Issue 7: Experience Band Formatting Inconsistency
Columns: Years of experience overall and in field
Bands use inconsistent spacing.
Examples: 5-7 years vs 8 - 10 years
Action: Standardise all bands to a consistent format.
