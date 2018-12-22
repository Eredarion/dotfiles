#!/bin/bash
#battery level
PERCENT=$(cat '/sys/class/power_supply/BAT0/capacity')
STATUS=$(cat '/sys/class/power_supply/BAT0/status')


echo $PERCENT"%" "*"$STATUS"*"