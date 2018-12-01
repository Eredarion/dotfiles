#!/bin/bash
# C = number of cores
C=$(grep -c '^processor' /proc/cpuinfo)
C=${C:-$(grep -c '^core' /proc/cpuinfo)}
C=${C:-1}

# CPU = usage / cores
CPU=$(ps aux | awk 'BEGIN {sum = 0} {sum += $3}; END {print sum}')
CPU=${CPU/\.*}
# For multi core/thread, CPU needs to be divided by # of cores for average
(( C > 1 )) && CPU=$((CPU / C))
(( CPU > 100 )) && CPU="100% avg" || CPU="$CPU% avg"

echo $CPU