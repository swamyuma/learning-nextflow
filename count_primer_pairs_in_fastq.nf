#!/usr/bin/env nextflow

params.index_file = 'indexes.tsv'
params.fastq_dir  = 'data'
params.outfile    = 'index_counts.tsv'


Channel.fromPath("${params.fastq_dir}/*.fastq.gz")
    .set { fastq_files }

Channel.fromFile(params.index_file)
    .splitCsv(header: true, sep: '\t')
    .map { row -> [row.p5, row.p7] }
    .collect()
    .set { index_pairs }

process countIndexPairs {
    cpus 4
    memory '2 GB'

    tag "$fastq_file.name"

    input:
    path fastq_file
    val index_pairs

    output:
    path "counts_${fastq_file.simpleName}.tsv"

    script:
    """
    zcat $fastq_file | awk 'NR % 4 == 2' > seqs.txt

    > counts_${fastq_file.simpleName}.tsv
    while read -r p5 p7; do
        count=\$(grep "\$p5.*\$p7" seqs.txt | wc -l)
        echo -e "${fastq_file.name}\\t\$p5\\t\$p7\\t\$count" >> counts_${fastq_file.simpleName}.tsv
    done <<< "$(printf '%s\\n' ${index_pairs.collect { it.join('\t') }.join(' ')})"
    """
}

workflow {
    fastq_files
        .combine(index_pairs)
        | countIndexPairs

    countIndexPairs.out
        .collectFile(name: params.outfile, flatten: true)
}
