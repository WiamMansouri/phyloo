import pandas as pd
from snakemake.utils import validate
import subprocess,sys
import glob
from os.path import join
from Bio import SeqIO
from Bio.Seq import Seq
from Bio.Alphabet import generic_dna
from Bio.SeqRecord import SeqRecord
from snakemake.utils import R
import subprocess

configfile:'config/config.yml'
rule all :
    input:
        'ressources/downloadfa.fasta',
        'ressources/genes.fasta',
        'ressources/genesconcat.fasta',
        'ressources/mergeseqs.fasta',
        'ressources/aligned.fasta',
        'ressources/trimal.fasta',
        'results/tree.png'

from snakemake.remote.NCBI import RemoteProvider as NCBIRemoteProvider
NCBI = NCBIRemoteProvider(email="someone@example.com")
accessions =config["accessions"]
input_files = expand("{acc}.fasta", acc=accessions)

# GENOMES download from NCBI

rule download:
    input:
        NCBI.remote(input_files, db="nuccore")
    output:
        "ressources/downloadfa.fasta"

    shell:
        """
        cat {input} > ressources/downloadfa.fasta
        """
# combine GENE files into one file
genes= config['samples']
rule combine_genes:
    input:
        expand("{g}",g=genes)
    output:
        "ressources/genes.fasta"
    shell:
        """cat {input} > {output}"""
#merge multifasta genes into a single sequence
rule concat_genes:
    input :
        'ressources/genes.fasta'
    output :
        'ressources/genesconcat.fasta'
    conda:
        "environment.yml"
    shell:
        """union -filter {input} > {output}"""


#combine  merged sequence file and GENOMES file downloaded into one file
rule combine_seqs_genes:
    input:
        'ressources/genesconcat.fasta',
        'ressources/downloadfa.fasta'
    output:
        'ressources/mergeseqs.fasta'
    shell:
        """
        cat {input} > {output}
        """
# Alignement multiple 
rule muscle:
    input:
        'ressources/mergeseqs.fasta'

    output:
        'ressources/aligned.fasta'
    conda:
        "environment.yml"
    script:
        "workflow/scripts/muscle.R"
# Trimming 
rule trimal:
    input:
        'ressources/aligned.fasta'
    output:
         'ressources/trimal.fasta'
    conda:
        "environment.yml"
    shell:
        """ trimal -in {input} -out {output} -strictplus -keepheader """
#construction arbre phylogenetique 
rule tree:
    input:
        'ressources/trimal.fasta'
    conda:
        "environment.yml"
    output:
        'results/tree.png'
    script:
        "workflow/scripts/build.py"
