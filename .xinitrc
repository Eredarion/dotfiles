#!/bin/sh

session=${1:-awesome}
#    startx ~/.xinitrc WM


# session to run if none passed as first arg ($1)
session=${1:-awesome}

# this file is executed when calling startx

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

    # simulate Alt+F1 with just pressing Super
    if hash ksuperkey &>/dev/null; then
        ksuperkey -e 'Super_L=Alt_L|F1' &
        ksuperkey -e 'Super_R=Alt_L|F1' &
    fi

    xrdb -load "/home/ranguel/.Xresources" &
    feh --bg-fill "/home/ranguel/Изображения/Wallpapers/wallpapers/nZBJAsK.jpg" &
    killall mpd
    mpd &
    compton -b --config "/home/ranguel/.config/compton.conf" --shadow-exclude "x<=3 && x2>= 1000 && y <= 30 && y2 >=700" &
    #compton -b &
    xfsettingsd &
fi

if [[ $session == "2bwm" ]]; then

     # keyring for storing passwords
    if hash gnome-keyring &>/dev/null; then
        gnome-keyring-daemon --start --components=pkcs11 &
    fi

    # gnome polkit
    if [[ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]]; then
        /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 &
    fi

    # simulate Alt+F1 with just pressing Super
    if hash ksuperkey &>/dev/null; then
       ksuperkey -e 'Super_L=Alt_L|F1' &
       ksuperkey -e 'Super_R=Alt_L|F1' &
    fi


    xsetroot -cursor_name left_ptr &
    # xrdb -load ~/.Xresources
    #setxkbmap -option caps:escape
    nitrogen --restore &
    # urxvtd &
    killall mpd
    mpd

    pkill polybar
    polybar example &
    
    # compton -b --config "/home/ranguel/.config/compton.conf" --shadow-exclude "x<=3 && x2>= 1000 && y <= 30 && y2 >=700" &
    #compton -b --config "/home/ranguel/.config/compton.conf" --shadow-exclude "x<=3 && x2>= 1000 && y <= 30 && y2 >=700" &
    compton -b &
    sxhkd &
    
    dunst -config "$HOME"/.config/dunst/dunstrc &
    #hsetroot -solid "#264d73"

    xfsettingsd &
fi

# display timeout and sleep
xset s 3600 3600
xset dpms 3600 3700 4000

# keyboard repeat rate
xset r rate 400 100
kbdrate -d 400 -r 50

# urxvt deamon
urxvtd -q -f -o &

# restore wal colors
# wal -R &

# killall mpd

# do NOT put commands below the exec lines
case $session in
    i3|i3wm)    exec i3 ;;
    bsp|bspwm)  exec bspwm ;;
    xfce|xfce4) exec startxfce4 ;;
    openbox)    exec openbox-session ;;
    awesome)    exec awesome ;;
    *)          exec "$session" # Unknown, try running it
esac
