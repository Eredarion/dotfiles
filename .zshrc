# shell opts
setopt autocd
setopt completealiases
setopt histignorealldups
setopt histfindnodups
setopt incappendhistory
setopt sharehistory

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
  export ZSH="/home/ranguel/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(  
  zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# aliases
alias l='ls'
alias la='ls -A'
alias ll='ls -lA'
alias ls='ls --color=auto'
alias music='ncmpcpp -S visualizer'
alias wifi='sudo create_ap wlp3s0b1 enp4s0 WiFi'
alias upd='yay -Syu'
alias pac='sudo pacman --color auto'
alias merge='xrdb -merge ~/.Xresources'
alias reloadXres='xrdb ~/.Xresources'
alias grubup='sudo grub-mkconfig -o /boot/grub/grub.cfg'
alias mirrors='sudo reflector --score 100 --fastest 25 \
    --sort rate --save /etc/pacman.d/mirrorlist --verbose'
alias calc='bc -q'
# alias nvidia-setting='optirun -b none nvidia-settings -c :8'

# aliases config
alias zshc='nvim ~/.zshrc'
alias i3c='nvim ~/.config/i3/config'
alias comptonc='nvim ~/.config/compton.conf'
alias polybarc='nvim ~/.config/polybar/config'
alias xinitrcc='nvim ~/.xinitrc'
alias ncmpcppc='nvim ~/.config/ncmpcpp/config'
alias neofetchc='nvim ~/.config/neofetch/config.conf'
alias rangerc='nvim ~/.config/ranger/rc.conf'
alias vi='nvim'

# aliases game
alias poe='primusrun ~/Games/Pillars of Eternity/start.sh'

#aliases android 
# export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/X11/bin:path/to/android_sdk/platform-tools/"
# export ANDROID_HOME=~/Android/Sdk
alias aapt="$ANDROID_HOME/build-tools/28.0.3/aapt"
alias apkinstall="adb devices | tail -n +2 | cut -sf 1 | xargs -I X adb -s X install -r $1"
alias buildAndInstallApk='./gradlew --info --stacktrace assembleDebug && apkinstall ./app/build/outputs/apk/debug/app-debug.apk'
alias launchDebugApk="adb shell monkey -p 'aapt dump badging ./app/build/outputs/apk/debug/app-debug.apk | grep -e 'package: name' | cut -d \' -f 2' 1"
alias buildInstallLaunchDebugApk="buildAndInstallApk && launchDebugApk"

# aliases weather 
alias weather="curl -H 'Accept-Language: ru' 'wttr.in/Губиниха?1?n'"
alias weatherCurrent="curl -H 'Accept-Language: ru' 'wttr.in/Губиниха?0?Q'"
alias weatherFull="curl -H 'Accept-Language: ru' 'wttr.in/Губиниха'"


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
	#time          #
)

# PROMPT
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=false
SPACESHIP_PROMPT_FIRST_PREFIX_SHOW=false
SPACESHIP_PROMPT_PREFIXES_SHOW=false
SPACESHIP_PROMPT_SUFFIXES_SHOW=true
SPACESHIP_TIME_SHOW=true
SPACESHIP_TIME_COLOR=red
SPACESHIP_PROMPT_DEFAULT_PREFIX="${SPACESHIP_PROMPT_DEFAULT_PREFIX="via "}"
SUFFIX="${SPACESHIP_PROMPT_DEFAULT_SUFFIX=" "}"
SPACESHIP_DIR_COLOR=red
SPACESHIP_USER_COLOR=red
SPACESHIP_CHAR_COLOR_SUCCESS=red
SPACESHIP_CHAR_COLOR_SECONDARY=red

neofetch
#information

