process BRACKEN {
    tag "$meta.id"
    label 'process_low'

    publishDir "${params.outdir}/kraken_bracken", pattern: "*-abundances.tsv", mode: 'copy'
    publishDir "${params.outdir}/kraken_bracken", pattern: "*-braken-breakdown.tsv", mode: 'copy'

    conda "bioconda::bracken=2.9"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/bracken:2.9--py38h2494328_0':
        'biocontainers/bracken:2.9--py38h2494328_0' }"

    input:
    tuple val(meta), path(kraken_report)
    path db

    output:
    tuple val(meta), path('*-abundances.tsv'), emit: abundance
    tuple val(meta), path('*-braken-breakdown.tsv'), emit: breakdown
    path "versions.yml", emit: versions

    script:
    """
    bracken \\
        -d $db \\
        -i $kraken_report \\
        -o ${meta.id}-abundances.tsv \\
        -w ${meta.id}-braken-breakdown.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bracken: \$(echo \$(bracken -v) | cut -f2 -d'v')
    END_VERSIONS
    """
}
