#!/bin/bash
# /* ---- 💫 https://github.com/JaKooLit 💫 ---- */  ##
# Playerctl

music_icon="$HOME/.config/swaync/icons/music.png"

# Play the next track
play_next() {
    playerctl next
    # show_music_notification
}

# Play the previous track
play_previous() {
    playerctl previous
    # show_music_notification
}

# Toggle play/pause
toggle_play_pause() {
    playerctl play-pause
    # show_music_notification
}

# Stop playback
stop_playback() {
    playerctl stop
    # notify-send -e -u low -i "$music_icon" "Playback Stopped"
}

# Display notification with song information
show_music_notification() {
    # Add a slight delay to ensure the metadata is updated
    sleep 0.3

    status=$(playerctl status 2>/dev/null)
    if [[ "$status" == "Playing" ]]; then
        # Fetch updated metadata after delay
        song_title=$(playerctl metadata title 2>/dev/null)
        song_artist=$(playerctl metadata artist 2>/dev/null)
        album_url=$(playerctl metadata mpris:artUrl 2>/dev/null)

        # Set a temporary path for the downloaded album art
        album_path="/tmp/album_art.png"

        # Download the album art only if a URL is provided
        if [[ -n "$album_url" ]]; then
            curl -sL "$album_url" -o "$album_path"
        else
            album_path="$HOME/.config/swaync/icons/music.png"
        fi

        # Send the notification with the updated info
        notify-send -e -u low -i "$album_path" "Now Playing:" "$song_title\nby $song_artist"

        # Clean up the temporary file if downloaded
        if [[ -n "$album_url" ]]; then
            rm -f "$album_path"
        fi

    elif [[ "$status" == "Paused" ]]; then
        notify-send -e -u low -i "$HOME/.config/swaync/icons/music.png" "Playback Paused"
    else
        notify-send -e -u low -i "$music_icon" "No music playing"
    fi
}



# Get media control action from command line argument
case "$1" in
    "--nxt")
        play_next
        ;;
    "--prv")
        play_previous
        ;;
    "--pause")
        toggle_play_pause
        ;;
    "--stop")
        stop_playback
        ;;
    *)
        echo "Usage: $0 [--nxt|--prv|--pause|--stop]"
        exit 1
        ;;
esac
