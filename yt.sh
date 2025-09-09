#!/bin/bash

# 🎨 Themes
theme1="$HOME/.config/rofi/themes/yt-dlp.rasi"
theme2="$HOME/.config/rofi/themes/list.rasi"
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"

# 📥 Input URL
url=$(rofi -dmenu -p "Enter YouTube URL:" -theme "$theme1")

if ! curl -Is https://youtube.com >/dev/null 2>&1; then
    notify-send "❌ Error" "No Internet connection!"
    exit 1
fi

# 🔎 Cek dan validasi URL
if [ -z "$url" ]; then
    exit 0
elif [[ ! "$url" =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/ ]]; then
    notify-send -t 3000 "Invalid URL" "Only YouTube links are allowed!"
    exit 1
fi

# 📌 Menu options
options="Download MP3\nBest Quality Video\nChoose Resolution\nPlay Mp3\nPlay Best Video\nPlay With Your Option"
choice=$(echo -e "$options" | rofi -dmenu -p "Select option:" -theme "$theme1")

# 🎵 Audio only
mp3() {
    filename="%(title)s.%(ext)s"
    outdir="$HOME/Music"
    mkdir -p "$outdir"
    notify-send "🎵 Downloading..." "Audio (MP3)"

    yt-dlp -x --audio-format mp3 \
        -o "$outdir/$filename" \
        "$url"

    notify-send "Download complete"
}

# 🎬 Best quality video
bestvideo() {
    filename="%(title)s.%(ext)s"
    outdir="$HOME/Videos"
    mkdir -p "$outdir"
    notify-send "🎬 Downloading..." "Best quality video"

    yt-dlp -f bestvideo+bestaudio/best --merge-output-format mp4 \
        -o "$outdir/$filename" \
        "$url"

    notify-send "Download complete"
}

# 🎚️ Manual resolution
choose() {
    filename="%(title)s.%(ext)s"
    outdir="$HOME/Downloads"
    mkdir -p "$outdir"


    notify-send "Fetching..." "Available formats"
    format=$(yt-dlp -F "$url" | awk '/^-/{flag=1; next} flag' | rofi -dmenu -p "Choose format:" -theme "$theme2")
    [ -z "$format" ] && exit 0

    format_id=$(awk '{print $1}' <<< "$format")
    notify-send "🎬 Downloading..." "Format $format_id"

    yt-dlp -f "$format_id"+bestaudio/best \
        -o "$outdir/$filename" \
        "$url"

    notify-send "Download complete"
}

play_mp3() {
    mpv --no-video "$url"
    notify-send "Playing Mp3"
}

play_best_video() {
    mpv "$url"
}

choose2() {
     format=$(yt-dlp -F "$url" | awk '/^18/{flag=1; next} flag' | rofi -dmenu -p "Choose format:" -theme "$theme2")
    [ -z "$format" ] && exit 0

    format_id=$(awk '{print $1}' <<< "$format")

    mpv --ytdl-format="$format_id+bestaudio/best" "$url"
}


# 🔀 Dispatcher
case "$choice" in
    "Download MP3") 
        mp3 
        ;;
    "Best Quality Video") 
        bestvideo
        ;;
    "Choose Resolution")
        choose
        ;;
    "Play Mp3")
        play_mp3
        ;;
    "Play Best Video")
        play_best_video
        ;;
    "Play With Your Option")
        choose2
        ;;
    *) notify-send "❌ Error" "Unrecognized option!" ;
     exit 1
      ;;
esac
