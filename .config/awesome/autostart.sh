#!/usr/bin/env bash
# ---
# Use "run program" to run it only if it is not already running
# Use "program &" to run it regardless
# ---
# NOTE: This script runs with every restart of AwesomeWM
# TODO: run_once

function run {
    if ! pgrep $1 > /dev/null ;
    then
        $@&
    fi
}


# Music
# run mpd ~/.config/mpd/mpd.conf

# Emacs daemon
#run emacs --daemon

# Load terminal colorscheme and settings
#xrdb ~/.Xresources

# Urxvt daemon
#run urxvtd -q -o -f

