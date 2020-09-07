from Bio import AlignIO
from Bio import Phylo
import matplotlib.pyplot as plt
from Bio.Phylo.TreeConstruction import *
from Bio.Phylo.Consensus import *
def build_tre(data_path,out_path):
    aln = AlignIO.read(open(data_path), 'fasta')
    constructor = DistanceTreeConstructor()
    calculator = DistanceCalculator('identity')
    dm = calculator.get_distance(aln)
    njtree = constructor.nj(dm)
    njtree.rooted=True
    scorer=ParsimonyScorer()
    searcher = NNITreeSearcher(scorer)
    constructor =ParsimonyTreeConstructor(searcher,njtree)
    paras_tree=constructor.build_tree(aln)
    trees= bootstrap_trees(aln,100,constructor)
    tree=[]
    tree=list(trees)
    target_tree=tree[0]
    support_tree=get_support(target_tree,tree)
    fig=plt.figure(figsize=(10, 20),dpi=100)
    axes=fig.add_subplot(1,1,1)
    Phylo.draw(support_tree,axes=axes,do_show=False)
    plt.savefig(out_path)
build_tre(snakemake.input[0],snakemake.output[0])
