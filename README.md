# RNA-Seq Analysis with nf-core/rnaseq

Training materials for running RNA-Seq analysis on Tufts HPC using the [nf-core/rnaseq](https://nf-co.re/rnaseq) pipeline.

## Getting Started

### Prerequisites

- A Tufts UTLN (username) and password
- VPN connection to the Tufts network (required for off-campus access)

### Log in to Tufts Open OnDemand

Navigate to the Open OnDemand portal: https://ondemand-prod.pax.tufts.edu

After logging in with your Tufts credentials, you will see the OnDemand dashboard.

![OnDemand Dashboard](images/ondemand_dashboard.png)

From the dashboard, choose **nf-core pipelines**, then select the version of the rnaseq pipeline you'd like to run. Generally speaking, the latest version is recommended.

![nf-core Dashboard](images/nfcore_dashboard.png)

### Setting up Your Working Directory

Before submitting the pipeline, you need to set up a working directory where your input files are located and where the output will be written. You can create this directory using the terminal in Open OnDemand.
Click **Clusters** in the top menu, then select **>\_Tufts HPC Shell Access**. This will open a terminal session on the cluster.
![Terminal Access](images/ondmeand_shell.png)
In the terminal, create a working directory and navigate into it:

```bash
mkdir -p /cluster/tufts/iyerlab/$USER/rnaseq_workshop
cd /cluster/tufts/iyerlab/$USER/rnaseq_workshop
```

Then copy the prepared **samplesheet.csv** to your working directory:

```bash
cp /cluster/tufts/workshop/public/2026summer/iyerlab/part1/samplesheet.csv .
## confirm the file is there
ls -l samplesheet.csv
```

### Preparing the Sample Sheet

Before submitting the pipeline, you need to create a `samplesheet.csv` file that tells nf-core/rnaseq where your FASTQ files are and how they are organized. Place this file in your working directory.

The sample sheet is a comma-separated file with the following columns:

| Column         | Description                                                                                                       |
| -------------- | ----------------------------------------------------------------------------------------------------------------- |
| `sample`       | Sample name. Replicates of the same sample should have the same name — the pipeline will automatically merge them |
| `fastq_1`      | Full path to the Read 1 (forward) FASTQ file                                                                      |
| `fastq_2`      | Full path to the Read 2 (reverse) FASTQ file. Leave empty for single-end data                                     |
| `strandedness` | Library strandedness: `auto`, `forward`, `reverse`, or `unstranded`                                               |

Here is an example for paired-end data with two conditions (PRMT5kd and GFPkd):

```csv
sample,fastq_1,fastq_2,strandedness
PRMT5kd_rep1,/path/to/PRMT5kd_rep1_R1.fastq.gz,/path/to/PRMT5kd_rep1_R2.fastq.gz,auto
PRMT5kd_rep2,/path/to/PRMT5kd_rep2_R1.fastq.gz,/path/to/PRMT5kd_rep2_R2.fastq.gz,auto
PRMT5kd_rep3,/path/to/PRMT5kd_rep3_R1.fastq.gz,/path/to/PRMT5kd_rep3_R2.fastq.gz,auto
GFPkd_rep1,/path/to/GFPkd_rep1_R1.fastq.gz,/path/to/GFPkd_rep1_R2.fastq.gz,auto
GFPkd_rep2,/path/to/GFPkd_rep2_R1.fastq.gz,/path/to/GFPkd_rep2_R2.fastq.gz,auto
GFPkd_rep3,/path/to/GFPkd_rep3_R1.fastq.gz,/path/to/GFPkd_rep3_R2.fastq.gz,auto
```

> **Tip:** Setting `strandedness` to `auto` lets Salmon infer the library type automatically. This is recommended unless you know your library prep protocol.

For single-end data, simply leave the `fastq_2` column empty:

```csv
sample,fastq_1,fastq_2,strandedness
sample1,/path/to/sample1_R1.fastq.gz,,auto
```

### Pipeline Arguments

Fill in the following arguments on the Open OnDemand submission form:

#### Cluster Settings

| Parameter                               | Value                                          | Description                                    |
| --------------------------------------- | ---------------------------------------------- | ---------------------------------------------- |
| Number of hours                         | `24`                                           | Maximum wall time for the job                  |
| Which Nextflow executor should be used? | `slurm`                                        | Tasks will be submitted as separate slurm jobs |
| Working directory                       | `/cluster/tufts/iyerlab/$USER/rnaseq_workshop` | Directory where the pipeline runs              |

#### Input/output options

| Parameter     | Value             | Description                                            |
| ------------- | ----------------- | ------------------------------------------------------ |
| input         | `samplesheet.csv` | Sample sheet listing FASTQ files and conditions        |
| outdir        | `output`          | Where results will be written, you can use other names |
| multiqc_title | `PRJNA638768`     | Title shown in the MultiQC report                      |

#### Reference Genome Options

> Pre-built references and indices for human are available on the cluster so you don't need to download or build them yourself.

| Parameter                | Value                                                                                                         | Description                            |
| ------------------------ | ------------------------------------------------------------------------------------------------------------- | -------------------------------------- |
| fasta                    | `/cluster/tufts/biocontainers/datasets/references/gencodes/human/GRCh38.primary_assembly.genome.fa`           | FASTA sequence of the reference genome |
| gtf                      | `/cluster/tufts/biocontainers/datasets/references/gencodes/human/gencode.v49.primary_assembly.annotation.gtf` | Gene annotation file in GTF format     |
| star_index               | `/cluster/tufts/biocontainers/datasets/references/gencodes/human/index/star`                                  | Pre-built STAR index                   |
| salmon_index             | `/cluster/tufts/biocontainers/datasets/references/gencodes/human/index/salmon`                                | Pre-built Salmon index                 |
| gencode                  | `true`                                                                                                        | Use GENCODE gene annotation format     |
| featurecounts_group_type | `gene_type`                                                                                                   | Group type attribute for featureCounts |

#### Alignment options

| Parameter | Value         | Description                                          |
| --------- | ------------- | ---------------------------------------------------- |
| aligner   | `star_salmon` | Use STAR for alignment and Salmon for quantification |

#### Quality Control

| Parameter             | Value                                                                 | Description                                       |
| --------------------- | --------------------------------------------------------------------- | ------------------------------------------------- |
| contaminant_screening | `kraken2`                                                             | Screen for contaminants using Kraken2             |
| kraken2_db            | `/cluster/tufts/biocontainers/datasets/kraken2/k2_standard_20260226/` | Kraken2 database to use for contaminant screening |

### Submitting Your Job

After filling in the form, click the **Submit** button at the bottom of the page. This will submit your job to the Slurm scheduler on the Tufts HPC cluster.

### Monitoring Your Job

From **My Interactive Sessions** in the Open OnDemand dashboard, you can monitor the status of your job.
![My Interactive Sessions](images/running_status.png)

### Active jobs

Our cluster has a home-built job monitoring tool that provides detailed information about your running jobs and history jobs, including resource usage and logs.
Click **Jobs** in the top menu, then select **Active Jobs**. This will open the job monitoring interface.

![Active Jobs](images/active_jobs.png)

### Logs are the key to debugging any issues that arise during pipeline execution.

Click the link next to **Session ID** to find the `output.log` file, which contains the Nextflow execution logs.

![Job Monitoring](images/output_log.png)

### Resuming a Failed Job

If your job fails for any reason, you can resume it without losing progress. Check **Resume previous run** at the bottom of the submission form. This will allow you to select the previous run and resume from where it left off.
![Resume Job](images/resume.png)
