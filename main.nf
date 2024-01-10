#!/usr/bin/env nextflow

params.inputFile = null
params.cutoff = null

Channel
    .fromPath(params.inputFile)
    .set{ fastaFile }

process filterByGCContent {
    input:
        path fasta from fastaFile

    output:
        path 'output.txt'

    script:
    """
    #!/usr/bin/env python3
    from Bio import SeqIO
    with open('output.txt', 'w') as out:
        for record in SeqIO.parse('${fasta}', 'fasta'):
            seq = str(record.seq)
            gc_content = (seq.count('G') + seq.count('C')) / len(seq)
            if gc_content > ${params.cutoff}:
                SeqIO.write(record, out, 'fasta')
    """
}

workflow {
    filterByGCContent(fastaFile)
}
