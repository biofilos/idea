
# coding: utf-8

import pandas as pd
from Bio import AlignIO, SeqIO
import os
import sys


__metaclass__ = type
class disorder:
    #Set names of things
    def seq(self,sequence):
        self.seq = sequence
        
    def discrete_out(self,table):
        self.table = table
    
    def iup_out(self,iup_outT):
        self.iupout = iup_outT
    
    def iup(self):
#        #    open sequence
        seq = AlignIO.read(open(self.seq),"fasta")
        seq_dic = SeqIO.to_dict(seq)
        #    Split sequences
        iupR ={}   
        for record in seq:
            out_seq = open(r"forIUP","w")
            SeqIO.write(record,out_seq,"fasta")
            out_seq.close()
        #        Run IUPred
            iupcmd = "iupred forIUP long > iup_out"
            os.system(iupcmd)
            iup_out_file = open('iup_out')
            outiup = [line for line in iup_out_file]
            os.system('rm iup_out')
            outIUP = outiup
            iupR[record.id] = 0
            newfield = []
            for line in outIUP:
                if not line.startswith("#"):
                    newfield.append(line.split(' ')[-1].split('\n')[0])
        #    Insert gaps
                    newfield_gaps =[]
            for j in seq_dic[record.id]:
                if j == '-':
                    newfield_gaps.append('X')
                else:
                    newfield_gaps.append(newfield.pop(0))
        #        Record into dictionary
            iupR[record.id] = newfield_gaps
        #        copy dictionary as Pandas dataframe
        iupData = pd.DataFrame.from_dict(iupR,orient='index')
        os.system(u'rm forIUP')
        return iupData
    
    #Convert IUPred to discrete things
    def discrete(self):
        def zero(x):
            if x=='X':
                z='?'
            elif (float(x)>0.4):
                z='1'
            elif (float(x)<0.4):
                z='0'
            return z
        data = self.iup_out
        discrete_data = data.applymap(zero)
        return discrete_data

     #Generate fasta file for Gloome   
    def forgloom(self):
        discrete = self.discrete_out
        forgloomF = open(self.gloom_out,'a')
        for j in discrete.index:
            forgloomF.write('>'+discrete.ix[j].name+'\n')
            for i in discrete.ix[j].fillna('?'): forgloomF.write(i)
            forgloomF.write('\n')
        forgloomF.close()


# Run automation


def runall(root):
    """
    The sequence name must be named root.aln.fa, and the tree root.aln.tre
    Fasta file for gloome will be named root.gl
    """
    #Class instance
    result = disorder()
    
    #Sequence and tree names
    result.seq=root+'.aln.fa'
    
    #IUPred output
    iupFile = open(root+'.iupred.parse.final','w')
    
    #IUPred discrete output
    discr_File = open(root+'.discrete','w')
    
    #Fasta file for Gloome
    result.gloom_out = root+'.forgloome'
    
    #Run IUpred
    result.iup_out = result.iup()
    result.iup_out.index.name='LABELS'
    result.iup_out.columns = result.iup_out.columns +1
    result.iup_out.to_csv(iupFile,sep='\t')
    iupFile.close()
    
    #Discrete data
    result.discrete_out = result.discrete()
    result.discrete_out.index.name = 'LABELS'
    result.discrete_out.to_csv(discr_File,sep='\t')
    discr_File.close()

    #Generate files for Gloome
    result.forgloom()
    runG = open(root+'.rungloome','a')
    
    
    runG.write(
          '_seqFile '+result.gloom_out+
          '\n_treeFile ' + root+'.aln.tre1'+
          '''\n_gainLossDist 1
_rateDistributionType GAMMA_PLUS_INV
_calculateGainLoss4site 1
_calculateRate4site 1
_calculatePosteriorExpectationOfChange 1
_calculeMaxParsimonyChange 1
_minNumOfOnes 0
_minNumOfZeros 0'''+
          '\n_outDir '+'gloome_'+root)
    runG.close()
    

    return result.iup_out, result.discrete_out

outIUP,outDIS = runall(sys.argv[1])
