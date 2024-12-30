#!/bin/bash

echo "External monitor detected. Setting environment variables..."
hyprctl keyword env GDK_SCALE 1
hyprctl keyword env XCURSOR_SIZE 24
hyprctl reload