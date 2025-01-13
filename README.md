# EndeavousOS And Ubuntu Gnome Config
i3 and rofi with basic setup for duo monitor

## Dependancy Requirement 
beside already installed by endeavousOs with i3wm

autorandr
after installing and config run>> systemctl --user enable autorandr

alacritty

redshift

oh-my-zsh

oh-my-zsh (autosuggestion)

zsh

powerlevel10k (for oh-my-zsh)

spotify

discord

i3lock-color

picom

obsidian

polybar

pomodorino

maim + xdotool (for rofi screenshot)

brigthnessctl (since the xbacklight dont work for some reason)

for changing the grub theme to tartaurus following this guide:
https://github.com/AllJavi/tartarus-grub


For hyprland
pre-installed package:

yad
thunar
mpv
imagemagick
xorg-xwayland
playerctl
rofi

install require:
-from pacman
hyprland
swaybg
swayidle
swaylock
wlroots
wl-clipboard
waybar
wofi
foot
mako
grim
slurp
wf-recorder
geany
mpd
mpc
viewnior
xdg-desktop-portal-wlr
pastel
python-pywal

from yay
light
xfce-polkit

### Polybar on gnome wayland
since xwindow won work on wayland, to achieve the same result replace xwindow with a script module using the window calls extension
https://github.com/ickyicky/window-calls

Adding a script to refresh polybar scaling using dpi, replace with your monitor using xrandr
### Replicate the i3wm tiling look on gnome wayland
extension needed:

- [Just Perfection Desktop](https://extensions.gnome.org/extension/3843/just-perfection/)
- [User Themes](https://extensions.gnome.org/extension/19/user-themes/)
- [Dash to Panel](https://extensions.gnome.org/extension/1160/dash-to-panel/)
- [Vitals](https://extensions.gnome.org/extension/1460/vitals/)
- [Space Bar](https://extensions.gnome.org/extension/5338/space-bar/)
- [Date Menu Formatter](https://extensions.gnome.org/extension/4655/date-menu-formatter/)
- [Arc Menu](https://extensions.gnome.org/extension/3628/arcmenu/)
- [Window Calls](https://extensions.gnome.org/extension/4724/window-calls/)
- [Auto Move Windows](https://extensions.gnome.org/extension/16/auto-move-windows/)
- [Pop Shell](https://github.com/pop-os/shell)
- [Pomodoro Timer](https://extensions.gnome.org/extension/53/pomodoro/)

**extension setting loading**

dconf load /org/gnome/shell/extensions/ < gnome-extensions-settings.dconf

**keybind loading**

dconf load /org/gnome/settings-daemon/plugins/media-keys/ < gnome-keybindings.dconf

## Config2 folder is reserver for hyprland
