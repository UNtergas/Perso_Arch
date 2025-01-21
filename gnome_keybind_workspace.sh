#!/bin/bash

# Set keybindings for switching to workspaces (Super+0-9)
for i in {1..9}; do
  gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-$i "['<Super>$i']"
done

gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-10 "['<Super>0']"

# Set keybindings for moving windows to workspaces (Shift+Super+0-9)
for i in {1..9}; do
  gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-$i "['<Shift><Super>$i']"
done

gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-10 "['<Shift><Super>0']"

# Confirmation message
echo "Workspace keybindings have been updated successfully."

