#!/bin/zsh

# expand escapes within the prompt and allow comments
setopt prompt_subst interactivecomments

# better cd handling
setopt autocd autopushd pushdminus pushdsilent pushdtohome pushd_ignore_dups

# completion
setopt correct nonomatch extendedglob completealiases
setopt auto_menu always_to_end complete_in_word auto_param_slash

# history
setopt hist_verify share_history append_history extended_history
setopt hist_ignore_dups hist_save_no_dups hist_ignore_space
setopt inc_append_history hist_ignore_all_dups hist_expire_dups_first

# job control
setopt auto_continue long_list_jobs

