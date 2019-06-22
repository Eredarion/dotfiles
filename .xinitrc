#!/bin/sh

session=${1:-awesome}

# set environment wm for use in scripts
export WM="$session"

# default arch xinit scripts
if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/*.sh; do
        [ -x "$f" ] && . "$f"
    done
fi

# user init scripts and settings
[ -f /etc/X11/xinit/.Xmodmap ] && xmodmap /etc/X11/xinit/.Xmodmap
[ -f ~/.Xmodmap ] && xmodmap ~/.Xmodmap
[ -f ~/.Xresources ] && xrdb -merge ~/.Xresources
[ -f ~/.xprofile ] && source ~/.xprofile

# some things to start for awesome
# other wm already have these started elsewhere
if [[ $session == "awesome" ]]; then

    # gnome polkit
    if [[ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]]; then
        /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
    fi
    
    nitrogen --restore &
    xrdb -load "$HOME/.Xresources" &
    killall mpd
    mpd
    nm-applet &
    compton  --config "$HOME/.config/compton.conf" \
             --shadow-exclude "x<=3 && x2>= 1000 && y <= 30 && y2 >=700" \
             --xrender-sync-fence \
             --vsync-use-glfinish &
             # --use-damage 
    xfsettingsd &
fi

# display timeout and sleep
xset s 1200 1200
xset dpms 1200 1300 1500

# keyboard repeat rate
# xset r rate 400 100
# kbdrate -d 400 -r 50
xset r rate 200 40
kbdrate -d 200 -r 40

# urxvt deamon
urxvtd -q -f -o &

# restore wal colors
# wal -R &

# do NOT put commands below the exec lines
case $session in
    i3|i3wm)    exec i3 ;;
    bsp|bspwm)  exec bspwm ;;
    xfce|xfce4) exec startxfce4 ;;
    openbox)    exec openbox-session ;;
    awesome)    exec awesome ;;
    *)          exec "$session" # Unknown, try running it
esac
