#!/usr/bin/env nextflow

// Define parameters
params.inputFile = null // User must provide the input file
params.cutoff = null    // User must provide the GC content cutoff

process filterGC {
    input:
    path fastaFile from params.inputFile

    output:
    path 'output.txt' into resultsChannel

    script:
    """
      #!/usr/bin/env python
      import os
      import sys

      def calc_gc(seq):
          // Calculate GC content
          return (seq.count('G') + seq.count('C')) / float(len(seq))

      // Check if the input file exists
      if not os.path.exists("$fastaFile"):
          sys.exit("FASTA file not found")

      // Check if cutoff is a valid number
      try:
          cutoff = float(${params.cutoff})
      except ValueError:
          sys.exit("Invalid cutoff value")

      with open("$fastaFile", "r") as f, open("output.txt", "w") as out:
          for line in f:
              if line.startswith(">"):
                  header = line.strip()
              else:
                  seq = line.strip()
                  if calc_gc(seq) > cutoff:
                      out.write(f"{header}\\n{seq}\\n")
    """
}

// Define the workflow
workflow {
    Channel.fromPath(params.inputFile) | filterGC
    resultsChannel.view { "Results written to ${it}" }
}
