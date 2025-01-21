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

- [User Themes](https://extensions.gnome.org/extension/19/user-themes/)
- [Dash to Panel](https://extensions.gnome.org/extension/1160/dash-to-panel/)
- [Date Menu Formatter](https://extensions.gnome.org/extension/4655/date-menu-formatter/)
- [Arc Menu](https://extensions.gnome.org/extension/3628/arcmenu/)
- [Window Calls](https://extensions.gnome.org/extension/4724/window-calls/)
- [Pop Shell](https://github.com/pop-os/shell)
- [Pomodoro Timer](https://extensions.gnome.org/extension/53/pomodoro/)
- [Focus](https://extensions.gnome.org/extension/3924/focus/)
- [Undecorate Windows](https://extensions.gnome.org/extension/1208/undecorate/)
- [Improved workspace monitor](https://extensions.gnome.org/extension/3968/improved-workspace-indicator/)
- [Mouse follow focus](https://extensions.gnome.org/extension/7656/mouse-follows-focus/)
- [Media Controls](https://extensions.gnome.org/extension/4470/media-controls/)


**extension setting loading**

dconf load /org/gnome/shell/extensions/ < gnome-extensions-settings.dconf

**keybind loading**

dconf load /org/gnome/settings-daemon/plugins/media-keys/ < gnome-keybindings.dconf

## Config2 folder is reserver for hyprland
