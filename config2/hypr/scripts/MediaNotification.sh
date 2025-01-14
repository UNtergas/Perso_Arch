#!/bin/bash
music_icon="$HOME/.config/swaync/icons/music.png"
previous_song=""
previous_status=""

# Automatically send notifications when ANY media player changes track or resumes playback
playerctl --follow metadata | while read -r line; do
    sleep 0.3
    status=$(playerctl status 2>/dev/null)

    if [[ "$status" == "Playing" ]]; then
        # Get metadata from the active player
        song_title=$(playerctl metadata title 2>/dev/null)
        song_artist=$(playerctl metadata artist 2>/dev/null)
        album_url=$(playerctl metadata mpris:artUrl 2>/dev/null)
        player_name=$(playerctl metadata --format '{{playerName}}' 2>/dev/null)

        # Check if the song has changed or playback has resumed from pause
        if [[ "$song_title - $song_artist" != "$previous_song" || "$previous_status" == "Paused" ]]; then
            # Update the previous song and status trackers
            previous_song="$song_title - $song_artist"
            previous_status="$status"

            # Set a temporary path for the downloaded album art
            album_path="/tmp/album_art.png"

            # Download album art if available, otherwise use default icon
            if [[ -n "$album_url" ]]; then
                curl -sL "$album_url" -o "$album_path"
            else
                album_path="$music_icon"
            fi

            # Send notification with the player name and song info
            notify-send -e -u low -i "$album_path" "$player_name - Now Playing" "$song_title\nby $song_artist"

            # Clean up the temporary album art if it was downloaded
            if [[ -n "$album_url" ]]; then
                rm -f "$album_path"
            fi
        fi

    elif [[ "$status" == "Paused" ]]; then
        # Notify on pause only once
        if [[ "$previous_status" != "Paused" ]]; then
            notify-send -e -u low -i "$music_icon" "Playback Paused" "Your media playback has been paused."
            previous_status="Paused"
        fi
    fi
done
