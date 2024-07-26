The alignment_rsubread Docker container is based on Ubuntu 22.04 and includes Samtools and R with the stringr and Rsubread packages. It provides three key scripts:

**Create Reference Genome**: index_reference_genome.R creates a reference genome.

*Usage*: docker run --rm -v $(pwd):/workspace alignment_rsubread:v1 /scripts/index_reference_genome.R </workspace/pathway_to_reference_genome>

**Perform Alignment**: alignment_subread.R aligns uniquely mapped reads to the reference genome using Rsubread with default parameters and maximum processing capacity (nthreads). It also uses Samtools to generate BAM files of mapped reads, including both with and without duplicates, along with their corresponding index files. Additionaly, for each sample, alignment.summary and duplicates.txt files (stats files needed for the next script) are generated.

*Usage*: docker run --rm -v $(pwd):/workspace alignment_rsubread:v1 /scripts/alignment_subread.R </workspace/pathway_to_reference_genome> </workspace/pathway_to_output_folder> </workspace/pathway_to_SE_or_R1.fastq.gz /workspace/pathway_to_R2.fastq.gz>

**Generate Alignment Statistics**: alignment_stats.R calculates the percentage of mapped reads and the percentage of duplicates among the mapped reads.

*Usage*: docker run --rm -v $(pwd):/workspace alignment:v1 /scripts/alignment_stats.R /workspace/path_to_output_folder> </workspace/path_to_sample_name_1> </workspace/path_to_sample_name_2> </workspace/path_to_sample_name_n>
