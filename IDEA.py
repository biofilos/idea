from glob import glob
import os
from Bio import SeqIO, Phylo
from subprocess import Popen, PIPE
import pandas as pd
import numpy as np
import ete2
from ete2 import ClusterTree, TreeStyle, AttrFace, ProfileFace, TextFace
from ete2.treeview.faces import add_face_to_node
import matplotlib.pyplot as plt

def IDEA(family):
    '''
    Runs IUPred for the sequences in the directory, map the results
    to the alignments and plot them in the context of their trees
    Input: sequence name (must end in .aln, and a newick tree file
    should match the sequence name, but ending in .tre instead of .aln)
    '''
    iupDic = {}
    #Disorder threshold
    dis_thresh = 0.4
    #Gap character
    gap_char = np.nan
    aln = family
    tree = family.replace('aln','tre')
    #check that tree file exists and matches alignment name
    if not os.path.exists(tree):
        print("Tree file not found for {}".format(aln.replace('.aln','')))
    else:
        print "Tree file found for {}".format(aln.replace('.aln',''))
        #Work on each sequence
        for seq in SeqIO.parse(aln,'fasta'):
            #Write sequence in fasta
            SeqIO.write(seq,'foriup.fa','fasta')
            runiup = "iupred foriup.fa long"
            #Run IUPred on sequence, and save the output as foriup.fa
            process = Popen(["iupred", "foriup.fa", "long"], stdout=PIPE)
            #Save output in outiup variable
            (outiup, err) = process.communicate()
            outiup = outiup.split('\n')
            #Parse comments from IUPred output
            iupSites = [line.replace('  ','').split(' ')[-2:] for line in outiup if not line.startswith("#")]
            iup_gaps = []
            iup_discrete = []
            #Include gaps in IUPred matrix
            for site in seq.seq:
                if site == '-':
                    iup_gaps.append(gap_char)
                elif site == iupSites[0][0]:
                    iup_gaps.append(float(iupSites.pop(0)[1]))
            iupDic[seq.name] = iup_gaps
            iupData = pd.DataFrame.from_dict(iupDic,orient='index')
            #Format table for ete2
            iupData.index.names = ['#Names']
            iupData.to_csv('matrix',sep='\t')

        ###Plotting!
        #Tree file including IUPred data in matrix
        t = ClusterTree(str(tree),text_array='matrix')
        #Set the heatmap, so that 'white' goes on dis_thresh (0.4)
        profileF = ProfileFace(1, 0, dis_thresh,300, 20, "heatmap")
        nameFace = AttrFace("name", fsize=12)

        def addMatrix(node):
            if node.is_leaf():
                pass
                #Modify text in leaf labels
                add_face_to_node(nameFace,node,0,position='branch-right')
                #Add heatmap row
                add_face_to_node(profileF,node,1,position='branch-right',aligned=True)
            node.img_style['size'] = 0
        #Organize leaves
        t.ladderize()
        ts = TreeStyle()
        #Don't use default leaf label
        ts.show_leaf_name = False
        #Set rectangular tree
        ts.mode ='r'
        #Include modifications
        ts.layout_fn = addMatrix
        #Output file name
        out_heat = "heatmap_{}".format(tree.replace('.tre','.svg'))
        #generate heatmap as svg
        t.render(out_heat,tree_style=ts)
        #Remove temporary files
        [os.remove(trash) for trash in ['foriup.fa','matrix']]
        return t,ts,iupData
