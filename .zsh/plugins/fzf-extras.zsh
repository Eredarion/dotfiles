#!/bin/zsh

# fe [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fe() {
    IFS=$'\n'
    local preview='(highlight -O ansi -l {} || cat {} || tree -C {}) 2> /dev/null | head -200'
    local declare files=($(fzf-tmux --query="$1" --select-1 --exit-0 --preview ${preview}))
    [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
    unset IFS
}

# utility function used to write the command in the shell
writecmd() {
    perl -e '$TIOCSTI = 0x5412; $l = <STDIN>; $lc = $ARGV[0] eq "-run" ? "\n" : ""; $l =~ s/\s*$/$lc/; map { ioctl STDOUT, $TIOCSTI, $_; } split "", $l;' -- $1
}

# fh - repeat history
fh() {
    ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -re 's/^\s*[0-9]+\s*//' | writecmd -run
}

# fhe - repeat history edit
fhe() {
    ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -re 's/^\s*[0-9]+\s*//' | writecmd
}

# fkill - kill process
fkill() {
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ "x$pid" != "x" ]; then
        kill -${1:-9} $pid
    fi
}

is_in_git_repo() {
    git rev-parse HEAD >/dev/null 2>&1
}

fzf-down() {
    fzf --height 50% "$@" --border
}

# fbr - checkout git branch (including remote branches)
fbr() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) &&
        branch=$(fzf-down -d $(( 2 + $(wc -l <<< "$branches") )) +m <<< "${branches}") &&
        git checkout $(sed "s/.* //" <<< "${branch}" | sed "s#remotes/[^/]*/##")
}

# fco - checkout git branch/tag
fco() {
    local tags branches target
    tags=$(
    git tag | awk '{print "\x1b[31;1mtag\x1b[m\t" $1}') || return
    branches=$(
    git branch --all | grep -v HEAD | sed "s/.* //" | sed "s#remotes/[^/]*/##" |
        sort -u | awk '{print "\x1b[34;1mbranch\x1b[m\t" $1}') || return
    target=$(
    (echo "$tags"; echo "$branches") | fzf-tmux -l40 -- --no-hscroll --ansi +m -d "\t" -n 2 -1 -q "$*") || return
    git checkout $(echo "$target" | awk '{print $2}')
}

# fcoc - checkout git commit
fcoc() {
    local commits commit
    commits=$(git log --pretty=oneline --abbrev-commit --reverse) &&
        commit=$(echo "$commits" | fzf --tac +s +m -e) &&
        git checkout $(echo "$commit" | sed "s/ .*//")
}

# fshow - git commit browser
fshow() {
    git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
        fzf --ansi --no-sort --reverse --tiebreak=index --bind=ctrl-s:toggle-sort --bind "ctrl-m:execute:
    (grep -o '[a-f0-9]\{7\}' | head -1 |
        xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
    {}
    FZF-EOF"
}

# fcs - get git commit sha
# example usage: git rebase -i `fcs`
fcs() {
    local commits commit
    commits=$(git log --color=always --pretty=oneline --abbrev-commit --reverse) &&
        commit=$(echo "$commits" | fzf --tac +s +m -e --ansi --reverse) &&
        echo -n $(echo "$commit" | sed "s/ .*//")
}

# fstash - easier way to deal with stashes
# type fstash to get a list of your stashes
# enter shows you the contents of the stash
# ctrl-d shows a diff of the stash against your current HEAD
# ctrl-b checks the stash out as a branch, for easier merging
fstash() {
    local out q k sha
    while out=$(
        git stash list --pretty="%C(yellow)%h %>(14)%Cgreen%cr %C(blue)%gs" |
            fzf --ansi --no-sort --query="$q" --print-query --expect=ctrl-d,ctrl-b)
    do
        mapfile -t out <<< "$out"
        q="${out[0]}"
        k="${out[1]}"
        sha="${out[-1]}"
        sha="${sha%% *}"
        [[ -z "$sha" ]] && continue
        if [[ "$k" == 'ctrl-d' ]]; then
            git diff $sha
        elif [[ "$k" == 'ctrl-b' ]]; then
            git stash branch "stash-$sha" $sha
            break;
        else
            git stash show -p $sha
        fi
    done
}

# ftpane - switch pane (@george-b)
ftpane() {
    local panes current_window current_pane target target_window target_pane
    panes=$(tmux list-panes -s -F '#I:#P - #{pane_current_path} #{pane_current_command}')
    current_pane=$(tmux display-message -p '#I:#P')
    current_window=$(tmux display-message -p '#I')
    target=$(grep -v "$current_pane" <<< "$panes" | fzf +m --reverse) || return
    target_window=$(awk 'BEGIN{FS=":|-"} {print$1}' <<< "$target")
    target_pane=$(awk 'BEGIN{FS=":|-"} {print$2}' | cut -c 1 <<< "$target")

    if [[ $current_window -eq $target_window ]]; then
        tmux select-pane -t ${target_window}.${target_pane}
    else
        tmux select-pane -t ${target_window}.${target_pane} && tmux select-window -t $target_window
    fi
}
