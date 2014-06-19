How to run it:
./pipeline_check.sh will start the analysis
by default, it will not generate any graphics, in order to activate graphics generation, run it as
./pipeline_check.sh -g

Summary of analysis
1. collect protein families
2. Run IUPred
3. Generate tables (discrete and continuous) including gaps from alignment
4. Run Gloome
5. Generate graphics (optional)
---------------------------------------------------
Prerequisites
EMBOSS (seqretsplit)
Install for ubuntu: sudo apt-get install emboss
IUPred (iupred)
remember to set environment variables
in bash:
export IUPred_PATH='/path/to/iupred'

Gloome (gloome)
gnu parallel
gnuplot

Perl Modules
    LWP::UserAgent
    HTTP::Request::Common
    Pod::Usage
    Getopt::Regex
    Config::File::Simple
    cpan
    Bioperl

Python modules
	Biopython
	pandas
---------------------------------------------------
Restrictions
alignment files and their corresponding rooted tree files should reside on this directory
the alignment file should be called <rootname>.aln.fa (Fasta) and the tree file <rootname>.aln.tre (Newick). This restriction was imposed, so that analysis of a large number of protein families can be automated
Other restrictions:
the names in both files should match (case-sensitive) (it is highly recommended to avoid special characters or spaces in sequence names. A script in the directory taxa_names was included to parse alignment from Genbank sequences)
The tree file shouldn't have internal node names, or any annotation (the pipeline will try to remove bootstrap values) (Gloome's restriction)
The tree should be rooted (Gloome's restriction)
---------------------------------------------------
Output
Directory contents:
done/: gloome run files for finished analysis
forplot/
*.fortree: per-branch Gloome results (changes per tree length)
*.gp: commands for gnuplot (plotting results)
*.parsed: parsed Gloome results for gnuplot
*plot.svg: plot of parsed Gloome results (changes per tree length)
gloome_*/: raw gloome results (read Gloome documentation)
    in addition to the raw gloome results, *.forgloome: 'sequence' file for gloome
heatmaps/: iTOL output
    *.1.svg: tree + heatmap
    *.upitol: upload log from iTOL
iupred/: IUPred output and parsed tables
    *.discrete: discrete table of IUPred results
    *.iupred.parse.final: Continuous table of IUPred results
