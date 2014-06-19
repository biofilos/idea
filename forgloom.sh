#!/bin/bash
#./forgloom.sh matrix.discrete
prefiles=( `ls *.fa | sed 's/.aln.fa//'` )
#Check if a tree exists for each alignment
files=()
for ((i=0;i<${#prefiles[@]};++i))
do
        if [ -e ${prefiles[$i]}.aln.tre ]
        then
        files=("${files[@]}" ${prefiles[$i]})
        fi
done

for ((i=0;i<${#files[@]};++i))
do
	sed ':repeat; s/)[0-9]/)/; t repeat' ${files[$i]}.aln.tre | tr -d '\n' > ${files[$i]}.aln.tre1
done
#run gloome
echo "Running Gloome"
ls *.rungloome | parallel -j 3 gloome {}
for ((i=0;i<${#files[@]};++i))
do
	mv ${files[$i]}.forgloome gloome_${files[$i]}
	if [ -e forplot/ ]
	then
		echo ""
	else
		mkdir forplot
	fi
	rm ${files[$i]}.aln.tre1
##parse output for gnuplot
	nodes=( `./NodeCounter.pl ${files[$i]}.aln.tre | grep treelength | awk '{print $NF}'`)
	awk -v nodes=$nodes '{print $1, (($2+$3)/nodes)}' gloome_${files[$i]}/gainLossMP.2.00099.PerPos.txt | grep -v '#' | grep -v POS > forplot/${files[$i]}.parsed
##parse changes per site for figtree annotation
	nodes=( `infoseq ${files[$i]}.aln.fa 2> /dev/null | awk 'END {print $NF}'`)
	awk -v nodes=$nodes '{print $1, (($6+$7)/nodes)}' gloome_${files[$i]}/gainLossMP.2.00099.PerBranch.txt | grep -v '#' | grep -v POS | grep -v branch > forplot/${files[$i]}.fortree
done
