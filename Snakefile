SRA_ACCESSIONS = [l.strip() for l in open("SRR_Acc_List.txt").readlines()]

rule fastq:
  """run download"""
  input:
    expand("data/{accession}_pass_1.fastq.gz", accession=SRA_ACCESSIONS)

rule rsem:
  """run rsem"""
  input:
    expand("rsem/{accession}.genes.results", accession=SRA_ACCESSIONS)

rule download_fastq:
  """download fastq"""
  output:
    "data/{accession}_pass_1.fastq.gz"
  params:
    accession="{accession}"
  conda:
    "envs/fastq.yml"
  shell:
    "fastq-dump --outdir fastq "
    "--gzip --skip-technical --readids "
    "--read-filter pass --dumpbase --split-files --clip {params.accession}"

rule run_rsem:
  """align using rsem"""
  threads: 8
  input:
    "data/{accession}_pass_1.fastq.gz"
  output:
    "rsem/{accession}.genes.results",
    "rsem/{accession}.isoforms.results"
  params:
    accession="{accession}"
  conda:
    "envs/mapping.yml"
  shell:
    "rsem-calculate-expression -p 8 "
    " --star --star-gzipped-read-file "
    " --no-bam-output --append-names "
    " --single-cell-prior "
    " {input} "
    " /storage/data/reference/homo_sapiens/GRCh38/rsem/ensemble/hsa_rsem_ensembl "
    " rsem/{params.accession} "
