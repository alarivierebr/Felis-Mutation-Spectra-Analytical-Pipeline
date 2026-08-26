#!/user/bin/env Rscript

#-------------
# Goals:
# 1. Input multiqc informartion csv and clean it up
# 2. Output barplot of statistics
# 3. Output or print summary statistics

# ------ Package install ------#

required_packages <- c(
    "tidyverse",
    "janitor"
)

for (pkg in required_packages) {
    if (!requireNamespace(pkg, quietly = TRUE)) {
        stop(
            "Required package '", pkg,
            "' is not installed in this environment."
        )
    }
}

library(tidyverse)
library(janitor)

# Set input csv file

input_file <- "/mnt/autofs/data/userdata/project0076/annalise/filtering/R_plots/multiqc_general_stats_edited2.csv"
merged_output <- "/mnt/autofs/data/userdata/project0076/annalise/filtering/R_plots/multiqc_general_stats_merged.csv"
summary_stats_out <- "/mnt/autofs/data/userdata/project0076/annalise/filtering/R_plots/multiqc_summary_stats.csv"

data <- read_csv(input_file, na = c("", "NA", "N/A", "NULL"))

#janitor function to tidy up the column names in csv
data <- clean_names(data)

# cleaning columns
cat("Columns", ncol(data), "\n\n")

data <- data %>%
    mutate(
        Sample_ID = sample %>%
            str_remove("\\.(md|recal|deepvariant)$") %>%
            str_remove("_[0-9]+$") %>%
            str_remove("-SRX[0-9]+$") %>%
            str_remove("-ERX[0-9]+$")
    )

#setting the columns other than sample to metrics
metric_columns <- setdiff(
    names(data),
    c("sample", "Sample_ID")
)

#removing empty rows
data <- data %>%
    filter(
        !if_all(
            all_of(metric_columns),
            is.na
        )
    )


#setting row priority because I want it to prioritize the recalibrated values over the markduplicates values.
data <- data %>%
    mutate(
        row_priority = case_when(
            str_detect(sample, "\\.recal$") ~1,
            str_detect(sample, "\\.md$") ~2,
            str_detect(sample, "\\.deepvariant$") ~3,
            TRUE ~ 4
        )
    )


data <- data %>%
    arrange(Sample_ID, row_priority)

#merging data

merged_data <- data %>%
    group_by(Sample_ID) %>%
    summarise(
        across(
            all_of(metric_columns),
            ~ {
                x <- .x[!is.na(.x)]

                if (length(x) == 0) {
                    NA_real_
                } else {
                    x[1]

                }
            }
        ),
        .groups = "drop"
    )


print(merged_data, n = Inf)
write_csv(merged_data, merged_output)


# ---- Summary statistics  -------#
#in case i want to add more columns later, or remove some
keep_metrics <- c(

    #Alignment related
    
    "percent_duplication",
    "reads_mapped_percent",
    "paired_percent",
    "depth_10x",
    "depth_30x",
    "depth_median_coverage",
    "number_records",
    "number_snps",
    "tstv",
    "multiallelic_sites",
    "multiallelic_snps"
)

missing_metrics <- setdiff(
    keep_metrics,
    names(merged_data)
)

if (length(missing_metrics) >0) {
    stop(
        "Metrics are missing, please check your csv: ",
    paste(missing_metrics, collapse = ", ")
    )
}

merged_data <- merged_data %>%
    select(
        Sample_ID,
        all_of(keep_metrics)
    )

summary_long <- merged_data %>%
    pivot_longer(
        cols = all_of(keep_metrics),
        names_to = "Metric",
        values_to = "Value"
    ) %>%
    mutate(
        Category = case_when(
            Metric %in% c(
                "percent_duplication",
                "reads_mapped_percent",
                "paired_percent"
            ) ~ "Alignment",

            Metric %in% c(
                "depth_10x",
                "depth_30x",
                "depth_median_coverage"
            ) ~ "Depth /Coverage",

            Metric %in% c(
                "number_records",
                "number_snps",
                "tstv",
                "multiallelic_sites",
                "multiallelic_snps"
            ) ~ "Variants",

            TRUE ~ "Other"
        )
    ) %>%
    group_by(Metric) %>%
    summarise(
        N = sum(!is.na(Value)),
        Mean = mean(Value, na.rm = TRUE),
        Median = median(Value, na.rm = TRUE),
        SD = sd(Value, na.rm = TRUE),
        Min = min(Value, na.rm = TRUE),
        Q1 = quantile(Value, 0.25, na.rm = TRUE),
        Q3 = quantile(Value, 0.75, na.rm = TRUE),
        IQR = IQR(Value, na.rm = TRUE),
        Max = max(Value, na.rm = TRUE),
        .groups = "drop"
    )
    

print(summary_long)

write_csv(summary_long, summary_stats_out)