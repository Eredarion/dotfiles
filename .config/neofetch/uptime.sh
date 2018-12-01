#!/bin/bash
# system uptime
UPT="$(uptime -p)"
UPT="${UPT/up /}"
UPT="${UPT/ day?/d}"
UPT="${UPT/ hour?/h}"
UPT="${UPT/ minute?/m}"
echo $UPT