# Check if enough command line arguments are provided
if (length(commandArgs(trailingOnly = TRUE)) < 3) {
  cat("Usage: Rscript alignment_stats.R <output_directory> <sample_name_1> <sample_name_2> ...\n\n")
  cat("Arguments:\n")
  cat("- output_directory: Directory where output files will be saved\n")
  cat("- sample_name_1, sample_name_2, ...: Names of the samples for which statistics will be calculated\n")
  quit(status = 0)
}

# Load necessary library
library(stringr)

# Get arguments from command line
args <- commandArgs(trailingOnly = TRUE)
output_dir <- args[1]
sampleNames <- args[-1]

# Check if sample names are provided
if (length(sampleNames) < 1) {
  stop("Usage: Rscript alignment_stats.R <output_directory> <sample_name_1> <sample_name_2> ...")
}

# File names for duplicate statistics
dupstat_files <- paste0(sampleNames, "_removed_duplicates.txt")

# Initialize an empty table for duplicate statistics
dupstat_table <- NULL

# Read each file and extract statistics
for (i in seq_along(dupstat_files)) {
  lines <- readLines(dupstat_files[i])
  lines <- lines[-1]  # Remove header line
  lines <- sub(" ", "_", lines)  # Replace spaces with underscores
  lines <- sub(" ", "_", lines)  # Double check for spaces (redundant in your script)

  # Extract columns from lines
  col1 <- c(str_extract(lines, "[A-Za-z_]+"))  # Extract column 1
  col2 <- c(as.numeric(str_extract(lines, "\\d+")))  # Extract column 2

  # Combine into a data frame
  if (is.null(dupstat_table)) {
    dupstat_table <- as.data.frame(cbind(col1, col2))
  } else {
    dupstat_table <- as.data.frame(cbind(dupstat_table, col2))
  }
}

# Rename columns
colnames(dupstat_table) <- c("stat", sampleNames)

# Calculate duplicate percentage for each sample
percen_dup_line <- c(apply(dupstat_table[, -1], 2, function(x) (as.numeric(x[14]) / as.numeric(x[1])) * 100))
percen_dup_line <- round(percen_dup_line, 0)
percen_dup_line <- c("DUPLICATE_PERCENTAGE", percen_dup_line)
dupstat_table <- as.data.frame(rbind(dupstat_table, percen_dup_line))

# Write duplicate statistics to a TSV file
write.table(dupstat_table, paste0(output_dir, "duplicates_stats.tsv"), row.names = FALSE, quote = FALSE)

# File names for alignment statistics
alignstat_files <- paste0(sampleNames, "_aligned.bam.summary")

# Read the first file for alignment statistics
alignstat_table <- read.table(alignstat_files[1])

# Read subsequent files and append to the alignment statistics table
for (i in 2:length(alignstat_files)) {
  alignstat_n <- read.table(alignstat_files[i])
  alignstat_table <- as.data.frame(cbind(alignstat_table, alignstat_n[, 2]))
}

# Rename columns for alignment statistics
colnames(alignstat_table) <- c("stat", sampleNames)

# Calculate mapped percentage for each sample
percen_map_line <- c(apply(alignstat_table[, -1], 2, function(x) (as.numeric(x[2]) / as.numeric(x[1])) * 100))
percen_map_line <- round(percen_map_line, 0)
percen_map_line <- as.vector(percen_map_line)
percen_map_line <- c("MAPPED_PERCENTAGE", as.numeric(percen_map_line))
alignstat_table <- as.data.frame(rbind(alignstat_table, percen_map_line))

# Write alignment statistics to a TSV file
write.table(alignstat_table, paste0(output_dir, "alignment_stats.tsv"), row.names = FALSE, quote = FALSE)
