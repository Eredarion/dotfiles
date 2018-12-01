#!/bin/bash
# MEM = used / total
FREE="$(free --mega)"
MB=$(awk 'NR==2 {print $3}' <<< "$FREE")
GB=$(awk 'NR==2 {print $3 / 1000}' <<< "$FREE")
TOT=$(awk 'NR==2 {print $2 / 1000}' <<< "$FREE")
(( MB > 1000 )) && MEM="${GB:0:5}gb / ${TOT/\.*}gb" || MEM="${MB}mb / ${TOT/\.*}gb"
echo $MEM