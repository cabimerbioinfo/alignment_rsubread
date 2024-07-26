# Load the Rsubread package
library(Rsubread)

# Get the command line arguments
args <- commandArgs(trailingOnly = TRUE)

# Check if at least one argument is provided
if (length(args) < 1) {
  stop("You must provide at least one file path for the reference genome.")
}

# Iterate over each genome file path provided via command line
for (genome_file in args) {
  # Get the directory where the genome file is located
  setwd(dirname(genome_file))

  # Set the output path for the index in the same directory as input
  index_output <- paste0(tools::file_path_sans_ext(basename(genome_file)), "_index")

  # Index the genome using buildindex
  buildindex(basename = tools::file_path_sans_ext(genome_file), reference = genome_file)
}
