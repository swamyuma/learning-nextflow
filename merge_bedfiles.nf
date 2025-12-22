nextflow.enable.dsl=2

// Import the process from our module file
include { MERGE_BEDS } from './modules/bedtools'

workflow {
    // 1. Define inputs
    bed_a = channel.fromPath("data/sample1.bed")
    bed_b = channel.fromPath("data/sample2.bed")

    // 2. Execute the imported process
    MERGE_BEDS(bed_a, bed_b)
    
    // 3. Access the output later if needed
    MERGE_BEDS.out.view { "Output file is: $it" }
}
