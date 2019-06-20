#!/bin/bash

# A simple alarm clock script

echo "What time should the alarm go off? (HH:MM)"
read target

# sleep interval is 15 minutes
snooze=`dc -e "15 60 *p"`

# convert wakeup time to seconds
target_h=`echo $target | awk -F: '{print $1}'`
target_m=`echo $target | awk -F: '{print $2}'`
target_s_t=`dc -e "$target_h 60 60 ** $target_m 60 *+p"`

# get current time and convert to seconds
clock=`date | awk '{print $4}'`
clock_h=`echo $clock | awk -F: '{print $1}'`
clock_m=`echo $clock | awk -F: '{print $2}'`
clock_s=`echo $clock | awk -F: '{print $3}'`
clock_s_t=`dc -e "$clock_h 60 60 ** $clock_m 60 * $clock_s ++p"`

# calculate difference in times, add number of sec. in day and mod by same
sec_until=`dc -e "24 60 60 **d $target_s_t $clock_s_t -+r%p"`

echo "The alarm will go off at $target."

sleep $sec_until

# snooze loop
while :
do
  echo -e "\nWake up!"
  pamixer -i 100
  mpc play
  bpid=$!
  disown $bpid                          # eliminates termination message
  read -n1 input
  for bsub in $(ps -o pid,ppid -ax | \
                awk "{ if (\$2 == $bpid) { print \$1 }}")
  do
    kill $bsub                          # kill children
  done
  kill $bpid
  if [ "$input" == "Q" ]
  then
    echo -e "\nGood morning!"
    mpc pause
    exit
  else
    echo -e "\nSnoozing for $snooze seconds..."
    sleep $snooze
  fi
done