#!/bin/bash
music_icon="$HOME/.config/swaync/icons/music.png"
previous_song=""

# Automatically send notifications when Spotify changes track
playerctl --player=spotify metadata --follow | while read -r line; do
    sleep 0.3
    status=$(playerctl --player=spotify status 2>/dev/null)

    if [[ "$status" == "Playing" ]]; then
        song_title=$(playerctl --player=spotify metadata title 2>/dev/null)
        song_artist=$(playerctl --player=spotify metadata artist 2>/dev/null)
        album_url=$(playerctl --player=spotify metadata mpris:artUrl 2>/dev/null)

        # Check if the song has changed before sending a notification
        if [[ "$song_title - $song_artist" != "$previous_song" ]]; then
            # Set the new song as the previous one
            previous_song="$song_title - $song_artist"

            # Set a temporary path for the downloaded album art
            album_path="/tmp/spotify_album_art.png"

            # Download album art only if a URL is provided
            if [[ -n "$album_url" ]]; then
                curl -sL "$album_url" -o "$album_path"
            else
                album_path="$HOME/.config/swaync/icons/music.png"
            fi

            # Send notification using swaync
            notify-send -e -u low -i "$album_path" "Now Playing" "$song_title\nby $song_artist"

            # Clean up temporary file if downloaded
            if [[ -n "$album_url" ]]; then
                rm -f "$album_path"
            fi
        fi
    fi
done
