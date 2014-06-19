#!/bin/bash
chmod +x *.{sh,pl}

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
##Parse IUPred output as a table, generate discrete table, and setup Gloome files
for ((i=0;i<${#files[@]};++i))
do
	python2.7 IDEA_final.py ${files[$i]}
done
#Run Gloome
./forgloom.sh
#Generate heatmaps and plots from Gloome with -g flag
while getopts ":g" opt; do
  case $opt in
    g)
	for ((i=0;i<${#files[@]};++i))
	do
		if [ -e heatmaps/${files[$i]}.1.svg ]
		then
			echo "graphic output for ${files[$i]} already generated"
		else
			echo generating svg graphical output "for" ${files[$i]}
			./itolrunnersvg.sh ${files[$i]}
		fi
		if [ -e forplot/${files[$i]}plot.svg ]
		then
			echo "Gloome plot for ${files[$i]} already generated"
		else
			echo "Generating Gloome plot for ${files[$i]}"
			./forplot.sh ${files[$i]}
		fi
	done
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
  esac
done

if [ ! -d done ] #check if directory done exists
then
	mkdir done
fi
#Check if gloome run was succesful, if that is not the case, delete temp files
#if it was succesful, save running files in directory 'done'
files=( `ls -d gloome_* | sed 's/gloome_//'` )
#
for j in ${files[@]}
do
	isthere=( `grep -c 'TOTAL RUNNING TIME' gloome_${j}/log.txt` )
	if [ $isthere -eq 1 ]
	then
		mv ${j}.rungloome done/. 2>/dev/null
	else
		rm -r gloome_$j/
	fi
done
#organize results
if [ ! -d iupred ]
then
	mkdir iupred
fi
mv *.{discrete,iupred*} iupred/.
rm *.discrete1 2> /dev/null
if [ ! -d heatmaps ]
then
	mkdir heatmaps
fi
mv *.{svg,upitol} heatmaps/. 2> /dev/null
rm namesback.* 2> /dev/null
