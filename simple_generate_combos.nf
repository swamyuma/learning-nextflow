#!/usr/bin/env nextflow

params.index_file = 'indexes.tsv'
params.outfile = 'valid_combinations.tsv'


workflow {
    def valid_pairs = Channel
        .fromPath(params.index_file)
        .splitCsv(header: true, sep: ',')
        .filter { row -> row.p5 != null && row.p7 != null && row.p5.size() == 8 && row.p7.size() == 8 }
        .map { row -> "${row.p5}\t${row.p7}" }

    def p5_list = valid_pairs.map { it[0] }.distinct()
    def p7_list = valid_pairs.map { it[1] }.distinct()


    // Create all combinations of valid p5 and p7
     def combinations = p5_list
        .cross(p7_list)
        .map { pair -> "${pair[0]}\t${pair[1]}" }

    writeCombinations(combinations)

}

process writeCombinations {
    publishDir '.', mode: 'copy'

    input:
    path combo_file

    output:
    path combo_file

    script:
    """
    cat ${combo_file} > ${params.outfile}
    """
}
