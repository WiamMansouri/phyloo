if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager", repos="http//cran.us.r-project.org" )
BiocManager::install("muscle")
library(muscle)
fastaFile <- readDNAStringSet(snakemake@input[[1]])
aln <- muscle(stringset = fastaFile)

alignment2Fasta <- function(alignment, filename) {
  sink(filename)
  n <- length(rownames(alignment))
  for(i in seq(1, n)) {
      cat(paste0('>', rownames(alignment)[i]))
      cat('\n')
      the.sequence <- toString(unmasked(alignment)[[i]])
      cat(the.sequence)
      cat('\n')
  }

  sink(NULL)
}
alignment2Fasta(aln, snakemake@output[[1]])
