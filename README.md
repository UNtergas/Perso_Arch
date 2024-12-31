# EndeavousOS Config
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
