<p align="center">
  <img src="https://github.com/Eredarion/dotfiles/raw/master/.screenshot/2019.09.05-22:31:55.png" alt="screenshot">
</p>
<!--suppress HtmlDeprecatedAttribute --><p align="center"><a href="https://youtu.be/3PHaO8cdRPw">Old demo video</a></p>

## Dependencies
| Dependency | Description | Why/Where is it needed? |
| --- | --- | --- |
| `awesome` (git master branch) | Window manager | (explains itself) |
| `rofi` | Window switcher, application launcher and dmenu replacement | (explains itself) |
| `xorg-xbacklight` | Gets/Sets screen brightness (intel GPU only) | brightness widget |
| `lm_sensors` | CPU temperature sensor | CPU temperature widget |
| `upower` | Abstraction for enumerating power devices, listening to device events and more | battery widget |
| `pulseaudio`, `pamixer` | Sound system **(You probably already have these)** | volume widget |
| `jq` | Parses `json` output | weather widget |
| `pacman-contrib` [bin/pacman_update](./bin/pacman_update) in your `$PATH` | Check updates | updates widget |
| `lain` | Layouts, widgets and utilities for Awesome | network widget |
| `mpd` | Server-side application for playing music | **sidebar** music widget |
| `mpc` | Minimalist command line interface to MPD | **sidebar** music widget |
| `maim` | Takes screenshots (improved `scrot`) | [bin/screenshot.sh](./bin/screenshot.sh) script |
| [bin/screenshot](./bin/screenshot) in your `$PATH` | Commands to take/view screenshots | screenshot button |
| `feh` | Image viewer and wallpaper setter | screenshot previews, wallpapers |
| Font Awesome | Icon font | text exit screen, *skyfall* bar |
| Nerd Fonts | Icon font, Text font | *skyfall* taglist, *skyfall* bar and Iosevka for text |
| [openweathermap](https://openweathermap.org/) key | Provides weather data | weather widgets |

### Some recommended applications
+ **Terminals**: urxvtd / st / alacritty
+ **File managers**: Thunar
+ **Browsers**: Chromium
+ **Editors**: Nvim / Sublime Text

### More screenshot
<p align="center">
  <img src="https://github.com/Eredarion/dotfiles/raw/master/.screenshot/busy.png" alt="screenshot">
</p>
<p align="center">
  <img src="https://github.com/Eredarion/dotfiles/raw/master/.screenshot/file_manager.png" alt="screenshot">
</p>

### Cover path example
<p align="center">
  <img src="https://github.com/Eredarion/dotfiles/raw/master/.screenshot/2019.04.08-15:50:21.png" alt="screenshot">
</p>
