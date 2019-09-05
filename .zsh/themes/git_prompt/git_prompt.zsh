#!/bin/zsh

GIT_PROMPT_DIR="${0:A:h}"

: ${GIT_PROMPT_EXECUTABLE="haskell"}
: ${GIT_PROMPT_PREFIX="("}
: ${GIT_PROMPT_SUFFIX="%f)"}
: ${GIT_PROMPT_SEPARATOR="|"}
: ${GIT_PROMPT_BRANCH="%F{magenta}"}
: ${GIT_PROMPT_CONFLICTS="%F{red}%{x%G%}"}
: ${GIT_PROMPT_CHANGED="%F{blue}%{+%G%}"}
: ${GIT_PROMPT_CLEAN="%F{green}%{✔%G%}"}
: ${GIT_PROMPT_LOCAL=" L"}

# The remote branch will be shown between these two
: ${GIT_PROMPT_UPSTREAM_FRONT=" {%F{blue}"}
: ${GIT_PROMPT_UPSTREAM_END="%f}"}
: ${GIT_PROMPT_MERGING="%F{magenta}|MERGING%f"}
: ${GIT_PROMPT_REBASE="%F{magenta}|REBASE%f "}

# all GUI terminals
if [[ $TERM != 'linux' && $DISPLAY ]]; then
    : ${GIT_PROMPT_STAGED="%F{red}%{•%G%}"}
    : ${GIT_PROMPT_AHEAD="%F{green}%{↑%G%}%f"}
    : ${GIT_PROMPT_BEHIND="%F{red}%{↓%G%}%f"}
    : ${GIT_PROMPT_UNTRACKED="%{…%G%}"}
    : ${GIT_PROMPT_STASHED="%%F{blue}%{⚑%G%}"}
else
    : ${GIT_PROMPT_STAGED="%F{red}%{.%G%}"}
    : ${GIT_PROMPT_AHEAD="%F{green}%{^%G%}%f"}
    : ${GIT_PROMPT_BEHIND="%F{red}%{v%G%}%f"}
    : ${GIT_PROMPT_UNTRACKED="%{...%G%}"}
    : ${GIT_PROMPT_STASHED="%%F{blue}%{S%G%}"}
fi

_chpwd_update_git()
{
    _update_git
}

_preexec_update_git()
{
    case "$2" in
        git*|hub*|gh*|stg*) __EXECUTED_GIT_COMMAND=1 ;;
    esac
}

_precmd_update_git()
{
    if (( __EXECUTED_GIT_COMMAND )); then
        _update_git
        __EXECUTED_GIT_COMMAND=0
    fi
}

_update_git()
{
    __CURRENT_GIT_STATUS=""
    _GIT_STATUS=$(git status --porcelain --branch &>/dev/null |
        $GIT_PROMPT_DIR/$GIT_PROMPT_EXECUTABLE/gitstatus)
    __CURRENT_GIT_STATUS=("${(@s: :)_GIT_STATUS}")
    GIT_BRANCH=$__CURRENT_GIT_STATUS[1]
    GIT_AHEAD=$__CURRENT_GIT_STATUS[2]
    GIT_BEHIND=$__CURRENT_GIT_STATUS[3]
    GIT_STAGED=$__CURRENT_GIT_STATUS[4]
    GIT_CONFLICTS=$__CURRENT_GIT_STATUS[5]
    GIT_CHANGED=$__CURRENT_GIT_STATUS[6]
    GIT_UNTRACKED=$__CURRENT_GIT_STATUS[7]
    GIT_STASHED=$__CURRENT_GIT_STATUS[8]
    GIT_LOCAL_ONLY=$__CURRENT_GIT_STATUS[9]
    GIT_UPSTREAM=$__CURRENT_GIT_STATUS[10]
    GIT_MERGING=$__CURRENT_GIT_STATUS[11]
    GIT_REBASE=$__CURRENT_GIT_STATUS[12]
}

_git_status()
{
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 && __EXECUTED_GIT_COMMAND=1
    _precmd_update_git

    if [[ $__CURRENT_GIT_STATUS ]]; then
        local gstat="%f$GIT_PROMPT_PREFIX$GIT_PROMPT_BRANCH$GIT_BRANCH%f"

        if [[ -n $GIT_REBASE && $GIT_REBASE -ne 0 ]]; then
            gstat+="$GIT_PROMPT_REBASE$GIT_REBASE%f"
        elif (( GIT_MERGING != 0 )); then
            gstat+="$ZSH_THEME_GIT_PROMPT_MERGING%f"
        fi

        if (( GIT_LOCAL_ONLY != 0 )); then
            gstat+="$GIT_PROMPT_LOCAL%f"
        elif [[ $GIT_PROMPT_SHOW_UPSTREAM -gt 0 && -n $GIT_UPSTREAM && $GIT_UPSTREAM != ".." ]]; then
            local parts=("${(s:/:)GIT_UPSTREAM}")
            [[ $GIT_PROMPT_SHOW_UPSTREAM -eq 2 && $parts[2] == "$GIT_BRANCH" ]] &&
                GIT_UPSTREAM="$parts[1]"
            gstat+="$GIT_PROMPT_UPSTREAM_FRONT$GIT_UPSTREAM$GIT_PROMPT_UPSTREAM_END%f"
        fi

        (( GIT_BEHIND != 0 )) && gstat+="$GIT_PROMPT_BEHIND$GIT_BEHIND%f"
        (( GIT_AHEAD != 0 )) && gstat+="$GIT_PROMPT_AHEAD$GIT_AHEAD%f"
        gstat+="$GIT_PROMPT_SEPARATOR"
        (( GIT_STAGED != 0 )) && gstat+="$GIT_PROMPT_STAGED$GIT_STAGED%f"
        (( GIT_CONFLICTS != 0 )) && gstat+="$GIT_PROMPT_CONFLICTS$GIT_CONFLICTS%f"
        (( GIT_CHANGED != 0 )) && gstat+="$GIT_PROMPT_CHANGED$GIT_CHANGED%f"
        (( GIT_UNTRACKED != 0 )) && gstat+="$GIT_PROMPT_UNTRACKED%f"
        (( GIT_STASHED != 0 )) && gstat+="$GIT_PROMPT_STASHED$GIT_STASHED%f"
        (( GIT_CHANGED == 0 && GIT_CONFLICTS == 0 && GIT_STAGED == 0 && GIT_UNTRACKED == 0 )) &&
            gstat+="$GIT_PROMPT_CLEAN"
        gstat+="%f$GIT_PROMPT_SUFFIX%f"
        print -n "$gstat"
    fi
}

# add the hook functions
chpwd_functions+=(_chpwd_update_git)
precmd_functions+=(_precmd_update_git)
preexec_functions+=(_preexec_update_git)
