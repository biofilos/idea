#!/bin/bash
#./itolrunner trees_prefix

	./iTOL_uploader.pl `echo "\
	--treeFile $1.aln.tre \
	--treeFormat newick \
	--treename $1 \
	--projectName Disorder \
	--dataset1File $1.iupred.parse.final \
	--dataset1Label Disorder \
	--dataset1Separator tab \
	--dataset1Type heatmap \
	--dataset1HeatmapBoxWidth 1 \
	--dataset1MinPointValue 0 \
	--dataset1MidPointValue 0.4 \
	--dataset1MaxPointValue 1 \
	--dataset1MinPointColor #2200FF \
	--dataset1MidPointColor #FFFFFF \
	--dataset1MaxPointColor #FF0000"` > $1.upitol

	#Extract tree number
	uptree=( `grep -o [[:digit:]].*[[:digit:]] $1.upitol` )
	#Download trees
	./iTOL_downloader.pl `echo "\
	--tree ${uptree} \
	--outputFile $1.1.svg \
	--format svg \
	--ignoreBRL 1 \
	--fontsize 20 \
	--displayMode normal \
	--alignLabels 1 \
	--datasetList dataset1"` 2> /dev/null
