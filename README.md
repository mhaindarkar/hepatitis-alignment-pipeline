# Hepatitis Delta Alignment Pipeline

This is a Nextflow pipeline to align Hepatitis delta virus genomes to a reference genome from GenBank.

## 🧬 What It Does

- Downloads a reference genome using an NCBI accession (default: `M21012`)
- Combines it with local `.fasta` genomes from `hepatitis/`
- Aligns all sequences using `mafft`
- Cleans the alignment using `trimal -automated1`
- Outputs cleaned alignment and an HTML report
