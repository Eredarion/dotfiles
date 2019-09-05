#!/bin/zsh

COMPDUMPFILE=${ZDOTDIR:-${HOME}}/.zcompdump

src()
{
    autoload -U zrecompile
    compinit -u -d $COMPDUMPFILE
    for f in ${ZDOTDIR:-$HOME}/.zshrc $COMPDUMPFILE; do
        zrecompile -p $f && command rm -f $f.zwc.old
    done
    source ${ZDOTDIR:-$HOME}/.zshrc
}

fancy-ctrl-z()
{
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line
    else
        zle push-input
        zle clear-screen
    fi
}

pid2 ()
{
    local i
    for i in /proc/<->/stat; do
        [[ "$(< $i)" = *\((${(j:|:)~@})\)* ]] && echo $i:h:t
    done
}

duptree()
{
    dirs=(**/*(/))
    cd -- $dest_root
    mkdir -p -- $dirs
}

list100()
{
    zmodload zsh/stat
    ls -fld $1/**/*(d$(stat +device .)OL[1,100])
}

profile()
{
    ZSH_PROFILE_RC=1 zsh "$@"
}

globalias()
{
    zle _expand_alias

    # this will cause basic shell expressions/variables
    # to be expanded, I prefer to have it only expand aliases
    # zle expand-word

    zle self-insert
}

edalias()
{
    if [[ -z "$1" ]]; then
        printf "usage: edalias <alias_to_edit>\n"
    else
        vared aliases'[$1]'
    fi
}

edfunc()
{
    if [[ -z "$1" ]]; then
        printf "usage: edfunc <function_to_edit>\n"
    else
        autoload -U zed && zed -f "$1"
    fi
}

# see http://zsh.sourceforge.net/Doc/Release/Shell-Builtin-Commands.html#index-tty_002c-freezing
ttyctl -f
