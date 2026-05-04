# 04_impute.R
# Purpose: Apply basic imputation to the cleaned dataset
# Imputation is applied only to variables where it is justified
# Each decision is documented with the method used and the reason
# Only methods permitted by the brief are used
# Allowed methods: mean, median, mode, hot-deck, constant, leave missing
# Author: Shoaib
# Date: May 2026

source("scripts/00_config.R")

cat("Loading cleaned dataset for imputation\n")
df <- readRDS(paste0(data_clean_path, "df_clean.rds"))

cat("Rows loaded:", nrow(df), "\n")
cat("Columns loaded:", ncol(df), "\n\n")


# ===========================================================================
# IMPUTATION 1: Education - Mode imputation
# Method: Mode
# Reason: Education is a categorical variable. College degree is the
# dominant category accounting for 48% of all responses. Mode imputation
# is the most defensible basic method for categorical variables with a
# clearly dominant category as stated in the brief.
# Missing count: 240 entries (0.85%)
# ===========================================================================

cat("--- IMPUTATION 1: Education - mode imputation ---\n")
cat("Missing before:", sum(is.na(df$education)), "\n")

education_mode <- names(sort(table(df$education), decreasing = TRUE))[1]
cat("Mode value:", education_mode, "\n")
cat("Mode frequency:", sum(df$education == education_mode, na.rm = TRUE), "entries\n")

df$education[is.na(df$education)] <- education_mode
df$education_flag[df$education_flag == "missing - to be imputed in 04_impute.R"] <-
  paste0("imputed with mode: ", education_mode)

cat("Missing after:", sum(is.na(df$education)), "\n\n")


# ===========================================================================
# IMPUTATION 2: Gender - Constant imputation
# Method: Constant fill with existing category value
# Reason: Gender missingness is informative. Respondents who did not
# answer most likely preferred not to disclose. Filling with the existing
# category Other or prefer not to answer preserves this meaning and is
# more honest than guessing at actual gender identity.
# Missing count: 185 entries (0.66%)
# ===========================================================================

cat("--- IMPUTATION 2: Gender - constant imputation ---\n")
cat("Missing before:", sum(is.na(df$gender)), "\n")

df$gender[is.na(df$gender)] <- "Other or prefer not to answer"
df$gender_flag[df$gender_flag == "missing"] <-
  "imputed with constant: Other or prefer not to answer"

cat("Missing after:", sum(is.na(df$gender)), "\n\n")


# ===========================================================================
# IMPUTATION 3: Race - Constant imputation
# Method: Constant fill with informative label
# Reason: Race missingness is informative. Respondents who did not answer
# chose not to disclose their race. Filling with Prefer not to answer
# preserves this meaning rather than guessing at actual race identity.
# Missing count: 196 entries (0.69%)
# ===========================================================================

cat("--- IMPUTATION 3: Race - constant imputation ---\n")
cat("Missing before:", sum(is.na(df$race)), "\n")

df$race[is.na(df$race)] <- "Prefer not to answer"
df$race_flag[df$race_flag == "missing - to be imputed in 04_impute.R"] <-
  "imputed with constant: Prefer not to answer"

cat("Missing after:", sum(is.na(df$race)), "\n\n")


# ===========================================================================
# IMPUTATION 4: Additional compensation - Constant imputation with 0
# Method: Constant fill with 0
# Reason: The survey question asks how much additional compensation the
# respondent gets IF ANY. The phrase if any signals that a non-response
# means no additional compensation rather than a skipped question.
# This interpretation is supported by the 7977 respondents who explicitly
# entered 0. Constant imputation with 0 is the most defensible treatment.
# Missing count: 7372 entries (26.13%)
# ===========================================================================

cat("--- IMPUTATION 4: Additional compensation - constant imputation with 0 ---\n")
cat("Missing before:", sum(is.na(df$additional_comp)), "\n")

df$additional_comp[is.na(df$additional_comp)] <- 0
df$additional_comp_flag[df$additional_comp_flag == "missing - unknown if zero or skipped"] <-
  "imputed with constant: 0 - survey wording indicates no additional compensation"

cat("Missing after:", sum(is.na(df$additional_comp)), "\n\n")


# ===========================================================================
# VARIABLES LEFT AS MISSING - documented with reasons
#
# industry (85 missing - 0.3%)
# Reason: Industry is a freetext field with 1089 unique values. The mode
# Computing or Tech accounts for only 16.7% of responses which is not
# dominant enough to justify mode imputation on a freetext field. Imputing
# unknown industries with the most common industry would misrepresent the
# data. Left as missing.
#
# job_title (1 missing)
# Reason: Job title is freetext. A single missing entry cannot be imputed
# meaningfully without knowing the actual job title. Left as missing.
#
# job_title_context (20933 missing - 74%)
# Reason: Structural skip pattern. This was an optional clarification field.
# Missing means the respondent did not need to clarify their job title.
# Left as missing.
#
# currency_other (27985 missing - 99%)
# Reason: Structural skip pattern. This field is only filled when currency
# is set to Other. All other respondents skip this field by design.
# Left as missing.
#
# income_context (25155 missing - 89%)
# Reason: Structural skip pattern. This was an optional context field.
# Missing means the respondent did not provide additional context.
# Left as missing.
#
# country (1 missing)
# Reason: Country is a freetext field. One missing entry cannot be imputed
# without knowing the actual country. Left as missing.
#
# city (121 missing)
# Reason: City is a freetext field. Missing city cannot be imputed
# meaningfully without knowing the actual city. Left as missing.
#
# us_state (5070 missing - 18%)
# Reason: Missing US state is expected for non-US respondents. This is
# not incidental missingness but rather a natural skip pattern for
# respondents outside the United States. Left as missing.
# ===========================================================================

cat("--- VARIABLES LEFT AS MISSING WITH DOCUMENTED REASONS ---\n")
cat("industry:", sum(is.na(df$industry)),
    "missing - freetext field, mode at 16.7% not dominant enough to justify imputation\n")
cat("job_title:", sum(is.na(df$job_title)),
    "missing - freetext, single entry cannot be imputed meaningfully\n")
cat("job_title_context:", sum(is.na(df$job_title_context)),
    "missing - structural skip pattern, optional field\n")
cat("currency_other:", sum(is.na(df$currency_other)),
    "missing - structural skip pattern, only filled when currency is Other\n")
cat("income_context:", sum(is.na(df$income_context)),
    "missing - structural skip pattern, optional context field\n")
cat("country:", sum(is.na(df$country)),
    "missing - freetext, cannot impute without knowing actual country\n")
cat("city:", sum(is.na(df$city)),
    "missing - freetext, cannot impute without knowing actual city\n")
cat("us_state:", sum(is.na(df$us_state)),
    "missing - expected for non-US respondents, natural skip pattern\n\n")


# ===========================================================================
# FINAL SUMMARY
# ===========================================================================

cat("=== IMPUTATION COMPLETE ===\n")
cat("Rows:", nrow(df), "\n")
cat("Columns:", ncol(df), "\n\n")

cat("Imputation applied:\n")
cat("  Education: mode imputation with College degree (240 entries)\n")
cat("  Gender: constant imputation with Other or prefer not to answer (185 entries)\n")
cat("  Race: constant imputation with Prefer not to answer (196 entries)\n")
cat("  Additional comp: constant imputation with 0 (7372 entries)\n\n")

cat("Missing values remaining after imputation:\n")
for (col in names(df)[1:18]) {
  n_miss <- sum(is.na(df[[col]]))
  if (n_miss > 0) {
    cat(" ", col, ":", n_miss, "missing\n")
  }
}

saveRDS(df, file = paste0(data_clean_path, "df_imputed.rds"))
cat("\nImputed dataset saved to:", paste0(data_clean_path, "df_imputed.rds"), "\n")
cat("Imputation complete\n")
