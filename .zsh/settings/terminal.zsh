#!/bin/zsh

# load bracketed paste
autoload -Uz bracketed-paste-magic url-quote-magic
zle -N bracketed-paste bracketed-paste-magic
zle -N self-insert url-quote-magic

# support colors in less, the standard pager
export LESS_TERMCAP_mb=$'\E[31m'
export LESS_TERMCAP_md=$'\E[31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[47;30m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[32m'

if [[ $TERM == 'linux' ]]; then
    # linux console 0-15 colors
    colors=(
    "\e]P0191919"  # #191919
    "\e]P1D15355"  # #D15355
    "\e]P2609960"  # #609960
    "\e]P3FFCC66"  # #FFCC66
    "\e]P4255A9B"  # #255A9B
    "\e]P5AF86C8"  # #AF86C8
    "\e]P62EC8D3"  # #2EC8D3
    "\e]P7949494"  # #949494
    "\e]P8191919"  # #191919
    "\e]P9D15355"  # #D15355
    "\e]PA609960"  # #609960
    "\e]PBFF9157"  # #FF9157
    "\e]PC4E88CF"  # #4E88CF
    "\e]PDAF86C8"  # #AF86C8
    "\e]PE2ec8d3"  # #2ec8d3
    "\e]PFE1E1E1"  # #E1E1E1
    )
    for col in "${colors[@]}"; do
        printf "$col"
    done
    clear
fi
