#!/bin/zsh

autoload -Uz terminfo up-line-or-beginning-search down-line-or-beginning-search

typeset -A key=(
[Home]="$terminfo[khome]"
[End]="$terminfo[kend]"
[Insert]="$terminfo[kich1]"
[Backspace]="$terminfo[kbs]"
[Delete]="$terminfo[kdch1]"
[Up]="$terminfo[kcuu1]"
[Down]="$terminfo[kcud1]"
[Left]="$terminfo[kcub1]"
[Right]="$terminfo[kcuf1]"
[PageUp]="$terminfo[kpp]"
[PageDown]="$terminfo[knp]"
[ShiftTab]="$terminfo[kcbt]"
)

[[ -n "$key[Home]" ]] && bindkey -- "$key[Home]" beginning-of-line
[[ -n "$key[End]" ]] && bindkey -- "$key[End]" end-of-line
[[ -n "$key[Insert]" ]] && bindkey -- "$key[Insert]" overwrite-mode
[[ -n "$key[Backspace]" ]] && bindkey -- "$key[Backspace]" backward-delete-char
[[ -n "$key[Delete]" ]] && bindkey -- "$key[Delete]" delete-char
[[ -n "$key[ShiftTab]" ]] && bindkey -- "$key[ShiftTab]" reverse-menu-complete
[[ -n "$key[Up]" ]] && bindkey -- "$key[Up]" up-line-or-beginning-search
[[ -n "$key[Down]" ]] && bindkey -- "$key[Down]" down-line-or-beginning-search
[[ -n "$key[Left]" ]] && bindkey -- "$key[Left]" backward-char
[[ -n "$key[Right]" ]] && bindkey -- "$key[Right]" forward-char

if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
    zle-line-init() { echoti smkx; }
    zle-line-finish() { echoti rmkx; }
    zle -N zle-line-init
    zle -N zle-line-finish
fi

# updates editor information when the keymap changes.
zle-keymap-select() { zle reset-prompt; zle -R; }

# ensures the prompt is redrawn when the terminal size changes.
TRAPWINCH() { zle && zle -R; }

zle -N globalias
zle -N fancy-ctrl-z
zle -N zle-keymap-select
zle -N edit-command-line
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# use vi-mode
bindkey -v

# v to edit the command line (standard behaviour)
autoload -Uz edit-command-line
bindkey -M vicmd 'v' edit-command-line

# Ctrl-p/n for navigate history (standard behaviour)
bindkey '^P' up-history
bindkey '^N' down-history

# Ctrl-h/w/? for char and word deletion (standard behaviour)
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word

# Ctrl-/ to perform backward search in history
bindkey '^_' history-incremental-search-backward

# Ctrl-a/e to move to beginning/end of line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line

# Ctrl-j/k do the same as arrow keys
bindkey "^K" up-line-or-beginning-search
bindkey "^J" down-line-or-beginning-search

# Ctrl-z toggles control flow
bindkey '^Z' fancy-ctrl-z

# Alt-Enter to enter a line break without running the command
bindkey '^[^M' self-insert-unmeta

# space expands aliases
bindkey -M viins " " globalias
bindkey -M viins "^ " magic-space
bindkey -M isearch " " magic-space

# shorter timeouts for escape keys
export KEYTIMEOUT=1
