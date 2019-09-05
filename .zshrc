#!/bin/zsh

# catch non-zsh and non-interactive shells
[[ $- == *i* && $ZSH_VERSION ]] && SHELL=/usr/bin/zsh || return 0

# set some defaults
export MANWIDTH=90
export HISTSIZE=10000
export SAVEHIST=10000

# path to the framework root directory
SIMPL_ZSH_DIR=$HOME/.zsh

# add ~/bin to the path if not already, the -U flag means 'unique'
typeset -U path=($HOME/bin "${path[@]:#}")

# used internally by zsh for loading themes and completions
typeset -U fpath=("$SIMPL_ZSH_DIR/"{completion,themes} $fpath)

# initialize the prompt
autoload -U promptinit && promptinit

# source shell configuration files
for f in "$SIMPL_ZSH_DIR"/{settings,plugins}/*?.zsh; do
    . "$f" 2>/dev/null
done

# uncomment these lines to disable the multi-line prompt
# add user@host, and remove the unicode line-wrap characters

# PROMPT_LNBR1=''
# PROMPT_MULTILINE=''
# PROMPT_USERFMT='%n%f@%F{red}%m'
# PROMPT_ECODE="%(?,,%F{red}%? )"

# Path to your oh-my-zsh installation.
export ZSH="/home/ranguel/.oh-my-zsh"

plugins=(  
  zsh-autosuggestions
)

ZSH_AUTOSUGGEST_USE_ASYNC=true

source $ZSH/oh-my-zsh.sh


# load the prompt last
# prompt simpl

autoload -U promptinit; promptinit
prompt spaceship

SPACESHIP_PROMPT_ORDER=(
  #user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  hg            # Mercurial section (hg_branch  + hg_status)
  package       # Package version
  kubecontext   # Kubectl context section
  exec_time     # Execution time
  line_sep      # Line break
  vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)

SPACESHIP_RPROMPT_ORDER=(
  # battery       # Battery level and status  
)

# PROMPT
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=false
SPACESHIP_PROMPT_FIRST_PREFIX_SHOW=false
SPACESHIP_PROMPT_PREFIXES_SHOW=false
SPACESHIP_PROMPT_SUFFIXES_SHOW=true
SPACESHIP_PROMPT_DEFAULT_PREFIX="${SPACESHIP_PROMPT_DEFAULT_PREFIX="via "}"
SUFFIX="${SPACESHIP_PROMPT_DEFAULT_SUFFIX=" "}"
SPACESHIP_DIR_COLOR=red
SPACESHIP_USER_COLOR=red
SPACESHIP_CHAR_COLOR_SUCCESS=red
SPACESHIP_CHAR_COLOR_SECONDARY=red
SPACESHIP_CHAR_SYMBOL="%{$fg[red]%}>%{$fg[green]%}>%{$fg[yellow]%}> "
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_COLOR=blue
SPACESHIP_TIME_SUFFIX=""
SPACESHIP_TIME_PREFIX=""
SPACESHIP_BATTERY_SHOW=true
SPACESHIP_BATTERY_SYMBOL_DISCHARGING="⇣ "
SPACESHIP_BATTERY_SYMBOL_CHARGING="⇡ "
SPACESHIP_BATTERY_SYMBOL_FULL="• "
SPACESHIP_BATTERY_THRESHOLD="99"
