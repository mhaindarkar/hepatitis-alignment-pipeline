#!/usr/bin/env nextflow

params.access_id = "M21012"
params.in_dir = "hepatitis/"
params.out_combined = "combined.fasta"
params.out_mafft = "combined_aligned.fasta"
params.out_trimmed = "combined_aligned_trimmed.fasta"
params.out_html = "trimal_report.html"
params.out_dir = "results"
//  Fetch Data  //
process FETCH_FASTA {
    conda 'bioconda::entrez-direct=24.0'
    input:
    val access_id
    output:
    path "${access_id}.fasta", emit: sequence_fasta
    script:
    """
    esearch -db nucleotide -query "${access_id}" | efetch fasta > "${access_id}.fasta"
    """
}
//  Combine files  //
process COMBINE_SEQS {
    input:
    path input_files
    output:
    path "${params.out_combined}", emit: combined_output
    script:
    """
    cat "${input_files}"/*.fasta > "${params.out_combined}"
    """
}
//  MAFFT Alignment Process  //
process ALIGN_MAFFT {
    conda 'bioconda::mafft=7.525'
    input:
    path input_fasta
    output:
    path "${params.out_mafft}", emit: aligned_fasta
    script:
    """
    mafft --auto --thread -1 "${input_fasta}" > "${params.out_mafft}"
    """
}
//  TrimAl Process  //
process TRIMAL_ALIGNMENT {
    conda 'bioconda::trimal=1.5.0'
    publishDir "${params.out_dir}/trimal_results", mode: 'copy', pattern: '*'
    input:
    path input_aligned_fasta
    output:
    path "${params.out_trimmed}", emit: trimmed_fasta
    path "${params.out_html}", emit: trimal_html_report
    script:
    """
    trimal -in "${input_aligned_fasta}" -out "${params.out_trimmed}" -automated1 -htmlout "${params.out_html}"
    """
}
//  Workflow  //

workflow {
    FETCH_FASTA(params.access_id)
        Channel
        .fromPath(params.in_dir, type: 'dir')
        .set { input_dir_channel }
    COMBINE_SEQS(input_dir_channel)
    ALIGN_MAFFT(COMBINE_SEQS.out.combined_output)
    ALIGN_MAFFT.out.aligned_fasta.view { "MAFFT alignment complete: $it" }
    TRIMAL_ALIGNMENT(ALIGN_MAFFT.out.aligned_fasta)
}
