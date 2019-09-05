#!/bin/zsh

zmodload -i zsh/complist

DIRSTACKSIZE=10

# setup LS_COLORS
eval "$(dircolors -b)"

COMPDUMPFILE="${ZDOTDIR:-$HOME}/.zcompdump"
COMPCACHEPATH="${ZDOTDIR:-$HOME}"

# allow insecure completions
autoload -U compinit && compinit -u -d "${COMPDUMPFILE}"

# correction
zstyle ':completion:*:correct:*'             original true
zstyle ':completion:*:correct:*'             insert-unambiguous true
zstyle ':completion:*:approximate:*'         max-errors 1 numeric
zstyle ':completion:*:approximate:*'         max-errors 'reply=( $(( ($#PREFIX + $#SUFFIX) / 3 )) numeric )'

# completion
zstyle ':completion:*'                       use-cache on
zstyle ':completion:*'                       cache-path "${COMPCACHEPATH}"
zstyle ':completion:*:*:*:*:*'               menu select=2
zstyle ':completion::complete:*'             gain-privileges 1
zstyle ':completion:*'                       accept-exact '*(N)'
zstyle ':completion:*'                       completer _complete _match _approximate _ignored
zstyle ':completion:*'                       matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*'                       rehash true
zstyle ':completion:*'                       verbose true
zstyle ':completion:*:-command-:*:'          verbose false
zstyle ':completion:*:match:*'               original only
zstyle ':completion:*:options'               description 'yes'
zstyle ':completion:*:options'               auto-description '%d'
zstyle ':completion:*:matches'               group 'yes'
zstyle ':completion:*'                       group-name ''
zstyle ':completion:*:default'               list-prompt '%S%M matches%s'
zstyle ':completion:*'                       format ' %F{green}->%F{yellow} %d%f'
zstyle ':completion:*:corrections'           format ' %F{green}->%F{green} %d (errors: %e)%f'
zstyle ':completion:*:descriptions'          format ' %F{green}->%F{yellow} %d%f'
zstyle ':completion:*:messages'              format ' %F{green}->%F{purple} %d%f'
zstyle ':completion:*:warnings'              format ' %F{green}->%F{red} no matches found%f'
zstyle ':completion:*'                       squeeze-slashes true
zstyle ':completion:*:default'               list-colors ${(s.:.)LS_COLORS}
zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}
zstyle ':completion:*:cd:*'                  ignore-parents parent pwd
zstyle ':completion:*:cd:*'                  tag-order local-directories directory-stack path-directories
zstyle ':completion:*:(rm|kill|diff):*'      ignore-line other
zstyle ':completion:*:rm:*'                  file-patterns '*:all-files'
zstyle ':completion:*:*:*:*:processes'       command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:processes-names'       command 'ps c -u ${USER} -o command | uniq'
zstyle ':completion:*:*:kill:*:processes'    list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:pacman:*'              force-list always
zstyle ':completion:*:manuals'               separate-sections true
zstyle ':completion:*:manuals.*'             insert-sections true
zstyle ':completion:*:expand:*'              tag-order all-expansions
zstyle ':completion:*:*:-subscript-:*'       tag-order indexes parameters
zstyle ':completion:*:-tilde-:*'             group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*:history-words'         list false
zstyle ':completion:*:history-words'         stop yes
zstyle ':completion:*:history-words'         remove-all-dups yes
zstyle ':completion:hist-complete:*'         completer _history
zstyle ':completion:*:*files'                ignored-patterns '*?.zwc'
zstyle ':completion:*:functions'             ignored-patterns '(_*|pre(cmd|exec))' 'prompt*'
zstyle ':completion:*:*:*:users'             ignored-patterns \
    adm amanda apache at avahi avahi-autoipd beaglidx bin cacti canna \
    clamav daemon dbus distcache dnsmasq dovecot fax ftp games gdm \
    gkrellmd gopher hacluster haldaemon halt hsqldb ident junkbust kdm \
    ldap lp mail mailman mailnull man messagebus mldonkey mysql nagios \
    named netdump news nfsnobody nobody nscd ntp nut nx obsrun openvpn \
    operator pcap polkitd postfix postgres privoxy pulse pvm quagga radvd \
    rpc rpcuser rpm rtkit scard shutdown squid sshd statd svn sync tftp \
    usbmux uucp vcsa wwwrun xfs '_*'
zstyle '*' single-ignored show
zstyle ':completion:*:(scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*'         tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*'         group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host'   ignored-patterns \
    '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns \
    '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns \
    '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'
zstyle ':completion:*:(nano|vim|nvim|vi|emacs|e|v):*' ignored-patterns '*.(wav|mp3|flac|ogg|mp4|avi|mkv|webm|iso|dmg|so|o|a|bin|exe|dll|pcap|7z|zip|tar|gz|bz2|rar|deb|pkg|gzip|pdf|mobi|epub|png|jpeg|jpg|gif)'
zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${=${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) 2>/dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2>/dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

compdef _aliases edalias
compdef _functions edfunc

