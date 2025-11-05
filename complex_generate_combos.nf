#!/usr/bin/env nextflow

params.index_file = 'indexes.tsv'

workflow {
    Channel
        .fromPath(params.index_file)
        .splitCsv(header: true, sep: ',')
        .filter { row -> row.p5 != null && row.p7 != null && row.p5.size() == 8 && row.p7.size() == 8 }
        .map { row -> "${row.p5}\t${row.p7}" }
        .collect()
        .set { pair_lines }

    generateCombinations(pair_lines)
}

process generateCombinations {
    publishDir '.', mode: 'copy'

    input:
    val pair_lines

    output:
    path "combinations.txt"

    script:
    """
    # Write all pairs to a file
    echo -e "${pair_lines.join('\\n')}" > pairs.tsv

    # Extract unique p5 and p7 values
    cut -f1 pairs.tsv | sort | uniq > p5.txt
    cut -f2 pairs.tsv | sort | uniq > p7.txt

    # Generate combinations
    > combinations.txt
    while read p5; do
      while read p7; do
        echo "\$p5\t\$p7" >> combinations.txt
      done < p7.txt
    done < p5.txt
    """
}
