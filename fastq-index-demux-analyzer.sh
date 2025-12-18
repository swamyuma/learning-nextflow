#!/bin/bash

## Identifying the Indices

## When looking at the results, the highest counts should correspond to the expected sample sheet barcodes. If you see high counts for index pairs you didn't expect, it often indicates Index Hopping, a common phenomenon on patterned flowcells where indices "swap" between libraries.

# Check if files are provided
[[ $# -eq 0 ]] && { echo "Usage: $0 *.fastq.gz"; exit 1; }

# Header for the final output
printf "%-10s\t%-30s\t%-20s\n" "COUNT" "FILENAME" "INDEX_PAIR"

# Process files and capture output for global sorting
for file in "$@"; do
    zcat -f "$file" | \
        awk 'NR % 4 == 1' | \
        rev | cut -d':' -f1 | rev | \
        sort | \
        uniq -c | \
        while read -r count index; do
            printf "%d\t%s\t%s\n" "$count" "$file" "$index"
        done
done | sort -rnk1 | awk '{printf "%-10s\t%-30s\t%-20s\n", $1, $2, $3}'
