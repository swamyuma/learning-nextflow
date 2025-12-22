process MERGE_BEDS {
    tag "Merging ${b1}" // Helps identify the task in logs
    
    input:
    path b1
    path b2

    output:
    path "merged.bed"

    script:
    """
    cat $b1 $b2 | sort -k1,1 -k2,2n | bedtools merge -i stdin > merged.bed
    """
}
