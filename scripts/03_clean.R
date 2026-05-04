# 03_clean.R
# Purpose: Clean the raw dataset one issue class at a time
# Each stage is clearly separated with comments explaining what and why
# Row counts are logged before and after every stage
# No imputation happens here - that is handled in 04_impute.R
# Author: Shoaib
# Date: May 2026

source("scripts/00_config.R")
source("scripts/01_ingest.R")

library(dplyr)
library(stringr)

cat("Starting cleaning pipeline\n")
cat("Rows at start:", nrow(df_raw), "\n")
cat("Columns at start:", ncol(df_raw), "\n\n")

# Make a working copy of the raw data
# The raw data is never modified - all changes happen on this copy
df <- df_raw

# Give columns short readable names so the code is easier to read
colnames(df) <- c(
  "timestamp",
  "age",
  "industry",
  "job_title",
  "job_title_context",
  "annual_salary",
  "additional_comp",
  "currency",
  "currency_other",
  "income_context",
  "country",
  "us_state",
  "city",
  "exp_overall",
  "exp_field",
  "education",
  "gender",
  "race"
)

cat("Column names standardised to short readable names\n\n")


# ===========================================================================
# STAGE 1: Strip leading and trailing whitespace from all text columns
# Why: 1708 country entries alone had invisible spaces causing duplicates
# This must be done first before any other cleaning
# ===========================================================================

cat("--- STAGE 1: Strip whitespace from all text columns ---\n")

text_cols <- c("age", "industry", "job_title", "job_title_context",
               "currency", "currency_other", "income_context",
               "country", "us_state", "city", "exp_overall",
               "exp_field", "education", "gender", "race")

for (col in text_cols) {
  df[[col]] <- str_trim(as.character(df[[col]]))
  df[[col]][df[[col]] == "" | df[[col]] == "NA"] <- NA
}

cat("Whitespace stripped from all text columns\n")
cat("Whitespace-only entries converted to NA\n\n")


# ===========================================================================
# STAGE 2: Flag timestamp entries outside the 2021 survey period
# Why: The survey was conducted in 2021 but 618 entries have timestamps
# from 2022 through 2026 which are outside the expected collection window
# We flag them but keep them in the dataset
# ===========================================================================

cat("--- STAGE 2: Flag timestamps outside 2021 survey period ---\n")
cat("Rows before:", nrow(df), "\n")

df$timestamp_flag <- ifelse(
  format(df$timestamp, "%Y") != "2021",
  "outside survey year",
  "ok"
)

flagged_ts <- sum(df$timestamp_flag == "outside survey year")
cat("Timestamps flagged as outside 2021:", flagged_ts, "\n")
cat("Rows after:", nrow(df), "(no rows removed)\n\n")


# ===========================================================================
# STAGE 3: Normalise country names
# Why: The country column has 390 unique values but most are the same country
# written in different ways. USA alone has over 50 variants.
# We map all known variants to a single canonical name.
# Entries that cannot be mapped are flagged as invalid.
# ===========================================================================

cat("--- STAGE 3: Normalise country names ---\n")
cat("Unique country values before:", length(unique(df$country)), "\n")

# Fix internal double spaces first
df$country <- str_replace_all(df$country, "\\s+", " ")

# United States variants
us_variants <- c(
  "USA", "US", "U.S.", "Usa", "usa", "United states", "united states",
  "United States of America", "U.S.A.", "Us", "us", "U.S.A", "America",
  "U.S", "United State", "Unites States", "United Stated",
  "The United States", "United Sates", "UnitedStates", "ISA",
  "United Statea", "U.s.", "Unites states", "United states of America",
  "United State of America", "united States", "UNITED STATES",
  "United States of america", "United Stares", "United STates",
  "The US", "U. S.", "U. S", "U.SA", "u.s.", "United Statws",
  "UNited States", "Uniited States", "Uniyed states", "Uniyes States",
  "United States of Americas", "US of A", "Unitef Stated",
  "United Statss", "United Sttes", "Untied States", "United Statues",
  "Uniter Statez", "United Stateds", "United Statees", "Unitied States",
  "United Stattes", "United Statesp", "United statew", "united stated",
  "USaa", "uSA", "UsA", "USAB", "Usat", "united states of america",
  "United States is America", "United states of america",
  "United States- Puerto Rico", "USA-- Virgin Islands",
  "USA tomorrow", "United y", "I.S.", "IS", "U.S>", "USS",
  "Uniteed States", "Virginia", "California", "San Francisco",
  "Hartford", "Puerto Rico", "uS", "U.s.a.", "U.s.a",
  "USA (company is based in a US territory, I work remote)",
  "USA, but for foreign gov't",
  "Worldwide (based in US but short term trips aroudn the world)",
  "United States (I work from home and my clients are all over the US/Canada/PR",
  "US govt employee overseas, country withheld",
  "For the United States government, but posted overseas",
  "Japan, US Gov position",
  "I work for a UAE-based organization, though I am personally in the US.",
  "United States of American", "United Sates of America",
  "United Status", "Unted States", "United States of Americans"
)

# United Kingdom variants
uk_variants <- c(
  "UK", "Uk", "uk", "United Kingdom", "United kingdom", "united kingdom",
  "England", "england", "ENGLAND", "Englang", "Scotland", "Wales",
  "Great Britain", "Britain", "Northern Ireland", "U.K.", "U.K",
  "England, UK", "England, United Kingdom", "England/UK",
  "England, UK.", "England, Gb", "UK (England)", "UK (Northern Ireland)",
  "Scotland, UK", "Wales, UK", "Wales (UK)", "Wales (United Kingdom)",
  "Northern Ireland, United Kingdom", "United Kingdomk", "United Kindom",
  "UK (northern England)", "U.K. (northern England)", "Unites kingdom",
  "United Kingdom (England)", "United Kingdom.", "Isle of Man",
  "Jersey, Channel islands", "UK, remote",
  "UK, but for globally fully remote company", "UK for U.S. company"
)

# Canada variants
canada_variants <- c(
  "canada", "CANADA", "Canda", "Canadw", "Csnada", "Can", "Canad",
  "Canada, Ottawa, ontario", "Canada and USA", "Canad\u00e1",
  "I am located in Canada but I work for a company in the US"
)

# Other country variants
australia_variants    <- c("australia", "Australi", "Australian")
netherlands_variants  <- c("The Netherlands", "netherlands", "the Netherlands", "The netherlands", "Nederland", "NL")
newzealand_variants   <- c("NZ", "New zealand", "new zealand", "New Zealand Aotearoa", "Aotearoa New Zealand", "From New Zealand but on projects across APAC")
germany_variants      <- c("germany")
france_variants       <- c("FRANCE", "france")
ireland_variants      <- c("ireland")
switzerland_variants  <- c("SWITZERLAND", "switzerland")
denmark_variants      <- c("denmark", "Danemark")
india_variants        <- c("india", "INDIA", "ibdia")
italy_variants        <- c("Italia", "Italy (South)")
spain_variants        <- c("spain", "Catalonia")
singapore_variants    <- c("singapore")
japan_variants        <- c("japan")
brazil_variants       <- c("Brasil")
mexico_variants       <- c("M\u00e9xico")
czechrepublic_variants <- c("Czech republic", "czech republic", "\u010cesk\u00e1 republika", "Czechia")
southafrica_variants  <- c("South africa")
croatia_variants      <- c("croatia")
finland_variants      <- c("finland")
pakistan_variants     <- c("pakistan", "Company in Germany. I work from Pakistan.")
philippines_variants  <- c("philippines", "Remote (philippines)")
hongkong_variants     <- c("Hong KongKong", "hong konh")
nigeria_variants      <- c("NIGERIA", "Nigeria + UK")
luxembourg_variants   <- c("Luxemburg")
myanmar_variants      <- c("Burma")
uae_variants          <- c("UAE", "United Arab Emirates")
argentina_variants    <- c("ARGENTINA BUT MY ORG IS IN THAILAND", "I work for an US based company but I'm from Argentina.")
romania_variants      <- c("From Romania, but for an US based company")
austria_variants      <- c("Austria, but I work remotely for a Dutch/British company")

# Apply all mappings
df$country[df$country %in% us_variants]            <- "United States"
df$country[df$country %in% uk_variants]            <- "United Kingdom"
df$country[df$country %in% canada_variants]        <- "Canada"
df$country[df$country %in% australia_variants]     <- "Australia"
df$country[df$country %in% netherlands_variants]   <- "Netherlands"
df$country[df$country %in% newzealand_variants]    <- "New Zealand"
df$country[df$country %in% germany_variants]       <- "Germany"
df$country[df$country %in% france_variants]        <- "France"
df$country[df$country %in% ireland_variants]       <- "Ireland"
df$country[df$country %in% switzerland_variants]   <- "Switzerland"
df$country[df$country %in% denmark_variants]       <- "Denmark"
df$country[df$country %in% india_variants]         <- "India"
df$country[df$country %in% italy_variants]         <- "Italy"
df$country[df$country %in% spain_variants]         <- "Spain"
df$country[df$country %in% singapore_variants]     <- "Singapore"
df$country[df$country %in% japan_variants]         <- "Japan"
df$country[df$country %in% brazil_variants]        <- "Brazil"
df$country[df$country %in% mexico_variants]        <- "Mexico"
df$country[df$country %in% czechrepublic_variants] <- "Czech Republic"
df$country[df$country %in% southafrica_variants]   <- "South Africa"
df$country[df$country %in% croatia_variants]       <- "Croatia"
df$country[df$country %in% finland_variants]       <- "Finland"
df$country[df$country %in% pakistan_variants]      <- "Pakistan"
df$country[df$country %in% philippines_variants]   <- "Philippines"
df$country[df$country %in% hongkong_variants]      <- "Hong Kong"
df$country[df$country %in% nigeria_variants]       <- "Nigeria"
df$country[df$country %in% luxembourg_variants]    <- "Luxembourg"
df$country[df$country %in% myanmar_variants]       <- "Myanmar"
df$country[df$country %in% uae_variants]           <- "United Arab Emirates"
df$country[df$country %in% argentina_variants]     <- "Argentina"
df$country[df$country %in% romania_variants]       <- "Romania"
df$country[df$country %in% austria_variants]       <- "Austria"

# Handle emoji USA flag
df$country[df$country == "\U0001f1fa\U0001f1f8"]   <- "United States"

# Handle accented Canada
df$country[df$country == "Canad\u00e1"]            <- "Canada"

# Flag clearly invalid entries
invalid_country_patterns <- c(
  "ss", "ff", "dbfemf", "LOUTREALAND", "1", "na", "Y", "uS",
  "Remote", "Global", "International", "Africa", "europe",
  "Currently finance", "Policy", "USD",
  "n/a (remote from wherever I want)",
  "We don't get raises, we get quarterly bonuses, but they periodically asses income in the area you work, so I got a raise because a 3rd party assessment showed I was paid too little for the area we were located",
  "bonus based on meeting yearly goals set w/ my supervisor",
  "I earn commission on sales. If I meet quota, I'm guaranteed another 16k min. Last year i earned an additional 27k. It's not uncommon for people in my space to earn 100k+ after commission.",
  "$2,175.84/year is deducted for benefits",
  "I was brought in on this salary to help with the EHR and very quickly was promoted to current position but compensation was not altered."
)

df$country_flag <- ifelse(
  df$country %in% invalid_country_patterns | is.na(df$country),
  "invalid or missing",
  "ok"
)

flagged_country <- sum(df$country_flag == "invalid or missing")
cat("Country entries flagged as invalid or missing:", flagged_country, "\n")
cat("Unique country values after:", length(unique(df$country[df$country_flag == "ok"])), "\n\n")


# ===========================================================================
# STAGE 4: Flag salary outliers using IQR method
# Why: Salaries range from 0 to 6 billion. We use IQR to identify
# statistical outliers and flag them. Zero salaries are flagged separately.
# We never drop any rows.
# ===========================================================================

cat("--- STAGE 4: Flag salary outliers ---\n")
cat("Rows before:", nrow(df), "\n")

q1          <- quantile(df$annual_salary, 0.25, na.rm = TRUE)
q3          <- quantile(df$annual_salary, 0.75, na.rm = TRUE)
iqr_val     <- q3 - q1
upper_fence <- q3 + 1.5 * iqr_val

cat("IQR Q1:", q1, "\n")
cat("IQR Q3:", q3, "\n")
cat("IQR upper fence:", upper_fence, "\n")

df$salary_flag <- case_when(
  df$annual_salary == 0         ~ "zero salary",
  df$annual_salary < 1000       ~ "below minimum threshold",
  df$annual_salary > upper_fence ~ "above IQR upper fence",
  TRUE                          ~ "ok"
)

cat("Zero salaries flagged:", sum(df$salary_flag == "zero salary"), "\n")
cat("Below 1000 flagged:", sum(df$salary_flag == "below minimum threshold"), "\n")
cat("Above IQR upper fence flagged:", sum(df$salary_flag == "above IQR upper fence"), "\n")
cat("Rows after:", nrow(df), "(no rows removed)\n\n")


# ===========================================================================
# STAGE 5: Flag additional compensation issues
# Why: 34 entries above 500k, max is 120 million. Missing entries flagged
# as unknown since we cannot tell if zero or skipped.
# ===========================================================================

cat("--- STAGE 5: Flag additional compensation issues ---\n")

df$additional_comp_flag <- case_when(
  is.na(df$additional_comp)       ~ "missing - unknown if zero or skipped",
  df$additional_comp > 500000     ~ "above 500k - potential outlier",
  TRUE                            ~ "ok"
)

cat("Additional comp missing:", sum(df$additional_comp_flag == "missing - unknown if zero or skipped"), "\n")
cat("Additional comp above 500k:", sum(df$additional_comp_flag == "above 500k - potential outlier"), "\n\n")


# ===========================================================================
# STAGE 6: Normalise industry column
# Why: 96 fully lowercase entries and near-duplicates like Library vs Libraries
# ===========================================================================

cat("--- STAGE 6: Normalise industry column ---\n")
cat("Unique industry values before:", length(unique(df$industry)), "\n")

df$industry <- ifelse(
  !is.na(df$industry) & df$industry == tolower(df$industry),
  str_to_title(df$industry),
  df$industry
)

df$industry[!is.na(df$industry) & df$industry == "Libraries"]     <- "Library"
df$industry[!is.na(df$industry) & df$industry == "Public Library"] <- "Library"

cat("Unique industry values after:", length(unique(df$industry)), "\n\n")


# ===========================================================================
# STAGE 7: Flag invalid job title entries
# Why: 4 missing, 2 that are just a dash, 1 that is just the number 1
# ===========================================================================

cat("--- STAGE 7: Flag invalid job title entries ---\n")

df$job_title_flag <- case_when(
  is.na(df$job_title)  ~ "missing",
  df$job_title == "-"  ~ "invalid - punctuation only",
  df$job_title == "1"  ~ "invalid - numeric only",
  TRUE                 ~ "ok"
)

cat("Missing job titles:", sum(df$job_title_flag == "missing"), "\n")
cat("Invalid job titles:", sum(df$job_title_flag %in% c("invalid - punctuation only", "invalid - numeric only")), "\n\n")


# ===========================================================================
# STAGE 8: Normalise gender category
# Why: Prefer not to answer (1 entry) and Other or prefer not to answer
# (298 entries) mean the same thing. Merge into one standard category.
# ===========================================================================

cat("--- STAGE 8: Normalise gender category ---\n")
cat("Gender values before:\n")
print(table(df$gender, useNA = "always"))

df$gender[!is.na(df$gender) & df$gender == "Prefer not to answer"] <- "Other or prefer not to answer"

df$gender_flag <- ifelse(is.na(df$gender), "missing", "ok")

cat("Gender values after:\n")
print(table(df$gender, useNA = "always"))
cat("Missing gender entries:", sum(df$gender_flag == "missing"), "\n\n")


# ===========================================================================
# STAGE 9: Standardise experience band formatting
# Why: Some bands use 5-7 years and others use 8 - 10 years with spaces
# Standardise all to use spaces around the dash
# ===========================================================================

cat("--- STAGE 9: Standardise experience band formatting ---\n")
cat("Exp overall before:\n")
print(table(df$exp_overall))

df$exp_overall <- str_replace_all(df$exp_overall, "^5-7 years$", "5 - 7 years")
df$exp_field   <- str_replace_all(df$exp_field,   "^5-7 years$", "5 - 7 years")

cat("Exp overall after:\n")
print(table(df$exp_overall))
cat("\n")


# ===========================================================================
# STAGE 10: Flag logical inconsistencies in experience vs age
# Why: 265 rows have field experience exceeding overall experience
# 13 rows show age under 25 but claim 11 or more years experience
# ===========================================================================

cat("--- STAGE 10: Flag experience and age logic errors ---\n")

exp_order <- c(
  "1 year or less"   = 1,
  "2 - 4 years"      = 2,
  "5 - 7 years"      = 3,
  "8 - 10 years"     = 4,
  "11 - 20 years"    = 5,
  "21 - 30 years"    = 6,
  "31 - 40 years"    = 7,
  "41 years or more" = 8
)

overall_rank <- exp_order[df$exp_overall]
field_rank   <- exp_order[df$exp_field]

df$experience_flag <- case_when(
  !is.na(field_rank) & !is.na(overall_rank) & field_rank > overall_rank ~
    "invalid - field experience exceeds overall experience",
  df$age %in% c("under 18", "18-24") & !is.na(overall_rank) & overall_rank >= 5 ~
    "suspicious - high experience for reported age",
  TRUE ~ "ok"
)

cat("Field experience exceeds overall:", sum(df$experience_flag == "invalid - field experience exceeds overall experience"), "\n")
cat("Suspicious age vs experience:", sum(df$experience_flag == "suspicious - high experience for reported age"), "\n\n")


# ===========================================================================
# STAGE 11: Flag invalid city entries
# Why: Zip codes, dashes and remote entries found in city column
# ===========================================================================

cat("--- STAGE 11: Flag invalid city entries ---\n")

remote_terms <- c(
  "Remote", "remote", "Remotely", "WFH", "Work from home",
  "Home", "Remote worker", "From home", "Fully Remote",
  "Work From Home", "Working remotely"
)

df$city_flag <- case_when(
  is.na(df$city)                                       ~ "missing",
  df$city %in% remote_terms                            ~ "remote worker - not a city",
  str_detect(df$city, "^\\d+$")                        ~ "invalid - numeric only",
  df$city == "-"                                       ~ "invalid - punctuation only",
  tolower(df$city) %in% c("na", "n/a", "none", "n.a") ~ "invalid - not applicable entry",
  TRUE                                                 ~ "ok"
)

cat("Missing city:", sum(df$city_flag == "missing"), "\n")
cat("Remote worker entries:", sum(df$city_flag == "remote worker - not a city"), "\n")
cat("Other invalid city entries:", sum(df$city_flag %in% c("invalid - numeric only", "invalid - punctuation only", "invalid - not applicable entry")), "\n\n")


# ===========================================================================
# STAGE 12: Extract first state from multi-state US state entries
# Why: 114 entries have multiple states listed in one cell
# We extract the first one as the primary work location
# ===========================================================================

cat("--- STAGE 12: Extract first state from multi-state entries ---\n")

multi_state_before <- sum(str_detect(df$us_state, ","), na.rm = TRUE)
cat("Multi-state entries before:", multi_state_before, "\n")

df$us_state <- str_trim(str_extract(df$us_state, "^[^,]+"))

multi_state_after <- sum(str_detect(df$us_state, ","), na.rm = TRUE)
cat("Multi-state entries after:", multi_state_after, "\n\n")


# ===========================================================================
# STAGE 13: Standardise currency other column
# Why: Case inconsistencies like Dkk vs DKK and numeric entry of 11
# ===========================================================================

cat("--- STAGE 13: Standardise currency other column ---\n")

df$currency_other <- toupper(df$currency_other)

df$currency_other_flag <- case_when(
  is.na(df$currency_other) & df$currency == "Other" ~
    "missing - currency not specified",
  !is.na(df$currency_other) & str_detect(df$currency_other, "^\\d+$") ~
    "invalid - numeric entry",
  TRUE ~ "ok"
)

cat("Currency Other missing when should be filled:", sum(df$currency_other_flag == "missing - currency not specified", na.rm = TRUE), "\n")
cat("Currency Other invalid numeric entries:", sum(df$currency_other_flag == "invalid - numeric entry", na.rm = TRUE), "\n\n")


# ===========================================================================
# STAGE 14: Flag currency vs country cross-column inconsistency
# Why: 46 non-US respondents reported salary in USD
# ===========================================================================

cat("--- STAGE 14: Flag currency vs country inconsistency ---\n")

clearly_non_us <- c(
  "Canada", "United Kingdom", "Australia", "Germany", "France",
  "Ireland", "Netherlands", "Sweden", "Norway", "Denmark",
  "Finland", "Switzerland", "Belgium", "Spain", "Italy",
  "Portugal", "Japan", "South Korea", "Singapore", "New Zealand",
  "India", "Brazil", "Mexico", "Argentina"
)

df$currency_country_flag <- case_when(
  !is.na(df$currency) & !is.na(df$country) &
    df$currency == "USD" & df$country %in% clearly_non_us ~
    "note - USD reported for non-US country",
  TRUE ~ "ok"
)

cat("USD reported for clearly non-US country:", sum(df$currency_country_flag == "note - USD reported for non-US country"), "\n\n")


# ===========================================================================
# STAGE 15: Flag missing education entries
# Why: 240 entries missing - will be imputed in 04_impute.R
# ===========================================================================

cat("--- STAGE 15: Flag missing education entries ---\n")

df$education_flag <- ifelse(
  is.na(df$education),
  "missing - to be imputed in 04_impute.R",
  "ok"
)

cat("Missing education entries:", sum(df$education_flag == "missing - to be imputed in 04_impute.R"), "\n\n")


# ===========================================================================
# STAGE 16: Flag missing race entries
# Why: 196 entries missing - will be imputed in 04_impute.R
# ===========================================================================

cat("--- STAGE 16: Flag missing race entries ---\n")

df$race_flag <- ifelse(
  is.na(df$race),
  "missing - to be imputed in 04_impute.R",
  "ok"
)

cat("Missing race entries:", sum(df$race_flag == "missing - to be imputed in 04_impute.R"), "\n\n")


# ===========================================================================
# FINAL SUMMARY
# ===========================================================================

cat("=== CLEANING COMPLETE ===\n")
cat("Rows at end:", nrow(df), "\n")
cat("Columns at end:", ncol(df), "\n")
cat("No rows were removed during cleaning\n\n")

flag_cols <- names(df)[str_detect(names(df), "_flag")]
cat("Flag columns added:", length(flag_cols), "\n")
cat("Flag columns:", paste(flag_cols, collapse = ", "), "\n\n")

cat("Summary of all flag columns:\n")
for (col in flag_cols) {
  cat("\n", col, ":\n")
  print(table(df[[col]], useNA = "always"))
}

# Save the cleaned dataset to the data_clean folder
saveRDS(df, file = paste0(data_clean_path, "df_clean.rds"))
cat("\nCleaned dataset saved to:", paste0(data_clean_path, "df_clean.rds"), "\n")
cat("Cleaning pipeline complete\n")
