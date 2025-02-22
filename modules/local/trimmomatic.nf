process TRIMMOMATIC {
    tag "$meta.id"
    label 'process_medium'

    publishDir "${params.outdir}/trimmomatic", pattern: "*.fastq.gz", mode: 'copy'
    publishDir "${params.outdir}/trimmomatic", pattern: "*.summary.txt", mode: 'copy'

    conda "bioconda::trimmomatic=0.39"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/trimmomatic:0.39--hdfd78af_2':
        'biocontainers/trimmomatic:0.39--hdfd78af_2'
    }"

    input:
    tuple val(meta), path(reads)

    output:
    tuple val(meta), path("*_paired_R*.fastq.gz"), emit: trimmed_reads
    tuple val(meta), path("*unpaired_R*.fastq.gz"), emit: unpaired_reads
    tuple val(meta), path("*.summary.txt"), emit: summary
    path "versions.yml", emit: versions

    script:
    // I've included the current args here for now, may make a modules config later
    """
    trimmomatic \\
        PE \\
        $reads \\
        -threads $task.cpus \\
        -summary ${meta.id}.summary.txt \\
        ${meta.id}_paired_R1.fastq.gz \\
        ${meta.id}_unpaired_R1.fastq.gz \\
        ${meta.id}_paired_R2.fastq.gz \\
        ${meta.id}_unpaired_R2.fastq.gz \\
        ILLUMINACLIP:TruSeq3-PE.fa:2:30:10:2:True \\
        LEADING:3 \\
        TRAILING:3 \\
        SLIDINGWINDOW:4:20 \\
        MINLEN:100

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        trimmomatic: \$(trimmomatic -version)
    END_VERSIONS
    """
}
