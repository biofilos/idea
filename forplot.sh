#!/bin/bash

printf "%s\n" "set terminal svg size 330,120 fsize 8" >> $1.gp
printf "%s\n" "set output '$1plot.svg'" >> $1.gp
printf "%s\n" "set title '$1'" >> $1.gp
printf "%s\n" "set ylabel 'Changes / Tree length'"  >> $1.gp
printf "%s\n" "set xlabel 'Position'" >> $1.gp
printf "%s\n" "unset key" >> $1.gp
maxy=( `awk '{print $2}' forplot/$1.parsed | sort | tail -n 1 | awk '{printf"%.2f\n", $1+0.05}'` )
printf "%s\n" "set yrange [0:$maxy]" >> $1.gp
maxx=( `awk 'END{print $1}' forplot/$1.parsed`)
printf "%s\n" "set xrange [1:$maxx]" >> $1.gp
printf "%s\n" "set style fill solid 1" >> $1.gp
printf "%s\n" "plot 'forplot/$1.parsed' w boxes" >> $1.gp

gnuplot $1.gp
mv $1{plot.svg,.gp} forplot/.
