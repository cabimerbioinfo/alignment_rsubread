# Use Ubuntu as the base image
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive

# Update repositories and install necessary packages
RUN apt-get update && apt-get install -y \
    build-essential \
    zlib1g-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libxml2-dev \
    curl \
    wget \
    git \
    samtools \
    r-base

# Install the Rsubread package from Bioconductor
RUN R -e "install.packages('BiocManager', repos='http://cran.rstudio.com/')"
RUN R -e "BiocManager::install('Rsubread')"
RUN R -e "install.packages('stringr', repos='http://cran.rstudio.com/')"

# Clean the apt-get cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Copy the scripts to the working directory
COPY alignment_subread.R /scripts/
COPY alignment_stats.R /scripts/
COPY index_reference_genome.R /scripts/
 
# Make the scripts executable
RUN chmod +x /scripts/alignment_subread.R /scripts/alignment_stats.R /scripts/index_reference_genome.R

# Set the default command to execute the R script using ENTRYPOINT
ENTRYPOINT ["Rscript"]
