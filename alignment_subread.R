# Check if enough command line arguments are provided
if (length(commandArgs(trailingOnly = TRUE)) < 4) {
  cat("Usage: Rscript alignment.R <type> <genome_reference> <output_directory> <file_fastq_1> [<file_fastq_2>]\n\n")
  cat("Arguments:\n")
  cat("- type: Type of alignment ('rna' for RNA-seq or 'dna' for DNA-seq)\n")
  cat("- genome_reference: Path to the genome reference index file\n")
  cat("- output_directory: Directory where output files will be saved\n")
  cat("- file_fastq_1: Path to the first FASTQ file\n")
  cat("- file_fastq_2 (optional): Path to the second FASTQ file for paired-end data\n")
  quit(status = 0)
}

# Load required package
library(Rsubread)

# Get arguments from command line
args <- commandArgs(trailingOnly = TRUE)

# Set variables based on command line arguments
refgen <- args[2]
output_dir <- args[3]

if (length(args) == 4) {
  fastq_files_1 <- args[4]
  fastq_files_2 <- NULL
} else if (length(args) == 5) {
  fastq_files_1 <- args[4]
  fastq_files_2 <- args[5]
  # Remove the last character '1' from sampleName if paired-end data is provided
  sampleName <- tools::file_path_sans_ext(fastq_files_1)
  sampleName <- tools::file_path_sans_ext(sampleName)
  sampleName <- sub("_R1$", "", sampleName)
}

# Set sample name based on the first FASTQ file if not already set for paired-end
if (!exists("sampleName")) {
  sampleName <- tools::file_path_sans_ext(basename(fastq_files_1))
  sampleName <- tools::file_path_sans_ext(sampleName)
}

# Define output file names with the specified output directory
bamFile <- paste0(output_dir,basename(sampleName), "_aligned.bam")
sortedBam <- paste0(output_dir,basename(sampleName), "_sorted.bam")
collatedBam <- paste0(output_dir,basename(sampleName), "_collated.bam")
fixmateBam <- paste0(output_dir,basename(sampleName), "_fixmate.bam")
mappedBam <- paste0(output_dir,basename(sampleName), "_mapped.bam")
nodupBam <- paste0(output_dir,basename(sampleName), "_nodup.bam")

# Perform alignment based on RNA or DNA type
if (args[1] == "rna") {
  if (length(args) == 4) {
    subjunc(
      index = refgen,
      readfile1 = fastq_files_1,
      TH1 = 2,
      unique = TRUE,
      output_file = bamFile,
      nthreads = 64
    )
  }
  if (length(args) == 5) {
    subjunc(
      index = refgen,
      readfile1 = fastq_files_1,
      readfile2 = fastq_files_2,
      TH1 = 2,
      unique = TRUE,
      output_file = bamFile,
      nthreads = 64
    )
  }
}

if (args[1] == "dna") {
  if (length(args) == 4) {
    align(
      index = refgen,
      readfile1 = fastq_files_1,
      TH1 = 2,
      type = args[1],
      unique = TRUE,
      output_file = bamFile,
      nthreads = 64
    )
  }
  if (length(args) == 5) {
    align(
      index = refgen,
      readfile1 = fastq_files_1,
      readfile2 = fastq_files_2,
      TH1 = 2,
      type = args[1],
      unique = TRUE,
      output_file = bamFile,
      nthreads = 64
    )
  }
}

# Perform additional processing steps using samtools
system2("samtools", args = c("view -b -F 4 -@ 100", bamFile, ">", mappedBam))
print("Unmapped reads were filtered")
system2("samtools", args = c("collate -@ 100 -o", collatedBam, mappedBam))
print("Sample was collated")
system2("samtools", args = c("fixmate -@ 100 -m", collatedBam, fixmateBam))
print("Sample was fixmated")
system2("samtools", args = c("sort -@ 100", fixmateBam, "-o", sortedBam))
print("Sample was sorted")
system2("samtools", args = c("index -@ 100", sortedBam))
print("Sorted sample was indexed")
system2("samtools", args = c("markdup", "-r -s -f", paste0(output_dir,basename(sampleName), "_removed_duplicates.txt"), sortedBam, nodupBam))
print("Duplicates were removed")
system2("samtools", args = c("index", nodupBam))
print("nodup sample was indexed")
