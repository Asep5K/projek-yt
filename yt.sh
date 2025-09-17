#!/usr/bin/env bash

# ============================================================
# Script created by Asep5K
# 🎬 YouTube Downloader & Player (Bash + Rofi)
# ============================================================

# ██╗   ██╗ ██████╗ ██╗   ██╗████████╗██╗   ██╗██████╗ ███████╗
# ╚██╗ ██╔╝██╔═══██╗██║   ██║╚══██╔══╝██║   ██║██╔══██╗██╔════╝
#  ╚████╔╝ ██║   ██║██║   ██║   ██║   ██║   ██║██████╔╝█████╗  
#   ╚██╔╝  ██║   ██║██║   ██║   ██║   ██║   ██║██╔══██╗██╔══╝  
#    ██║   ╚██████╔╝╚██████╔╝   ██║   ╚██████╔╝██████╔╝███████╗
#    ╚═╝    ╚═════╝  ╚═════╝    ╚═╝    ╚═════╝ ╚═════╝ ╚══════╝
# ██████╗  ██████╗ ██╗    ██╗███╗   ██╗██╗      ██████╗  █████╗ ██████╗ ███████╗██████╗ 
# ██╔══██╗██╔═══██╗██║    ██║████╗  ██║██║     ██╔═══██╗██╔══██╗██╔══██╗██╔════╝██╔══██╗
# ██║  ██║██║   ██║██║ █╗ ██║██╔██╗ ██║██║     ██║   ██║███████║██║  ██║█████╗  ██████╔╝
# ██║  ██║██║   ██║██║███╗██║██║╚██╗██║██║     ██║   ██║██╔══██║██║  ██║██╔══╝  ██╔══██╗
# ██████╔╝╚██████╔╝╚███╔███╔╝██║ ╚████║███████╗╚██████╔╝██║  ██║██████╔╝███████╗██║  ██║
# ╚═════╝  ╚═════╝  ╚══╝╚══╝ ╚═╝  ╚═══╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝

# 🎨 Themes
theme1="$HOME/.config/rofi/themes/yt-dlp.rasi"
theme2="$HOME/.config/rofi/themes/list.rasi"
f="/var/lib/AccountsService/icons/$USER"

ICON_SUCCESS_URL="https://pbs.twimg.com/profile_images/1937897644816265216/R9fhEWX3_400x400.jpg"
ICON_FAIL_URL="https://pbs.twimg.com/media/Gzho6tiXUAAEXyj?format=jpg&name=medium"
ICON_DIR="$HOME/.local/share/asep_icons"
ICON_SUCCESS="$ICON_DIR/icon_success.jpg"
ICON_FAIL="$ICON_DIR/icon_fail.jpg"

# Pastikan folder ada
[ ! -d "$ICON_DIR" ] && mkdir -p "$ICON_DIR"

# Download ikon kalau belum ada
[ ! -f "$ICON_SUCCESS" ] && wget -q -O "$ICON_SUCCESS" "$ICON_SUCCESS_URL"
[ ! -f "$ICON_FAIL" ] && wget -q -O "$ICON_FAIL" "$ICON_FAIL_URL"

trap 'pkill -P $$ mpv yt-dlp' EXIT

check_internet() {
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        notify-send -i "$ICON_FAIL" "❌ No Internet" "Please check your connection!"
        exit 1
    fi
}

# yt-dlp check
if ! command -v yt-dlp >/dev/null 2>&1; then
    # kalo ga ada, kirim notif
    notify-send -i "$ICON_FAIL" "⚠ Warning" "yt-dlp not found!"
    exit 1
else
    check_internet
    # 📥 Input URL
    url=$(rofi -dmenu -p "Enter YouTube URL:" -theme "$theme1")
fi

if pidof rofi > /dev/null; then
    pkill rofi
fi

# 🔎 Cek dan validasi URL
if [ -z "$url" ]; then
    exit 0
elif [[ ! "$url" =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/ ]]; then
    notify-send -i "$ICON_FAIL" "Invalid URL" "Only YouTube links are allowed!"
    exit 1
fi

# 📌 Menu options
options="Download Videos\nDownload Music\nPlay Music/Videos"
choice=$(echo -e "$options" | rofi -dmenu -p "Select option:" -theme "$theme1")
[ -z "$choice" ] && exit 0

download_videos() {
    download_options="Download 240p\nDownload 360p\nDownload 480p\nDownload 720p\nDownload 1080p\nDownload 2K\nDownload 4K\nBest Resolution\nExit"
    download_choice=$(echo -e "$download_options" | rofi -dmenu -p "Select option:" -theme "$theme1")
    [ -z "$download_choice" ] && exit 0
}

play() {
    play_options="Play Music\nPlay 240p\nPlay 360p\nPlay 480p\nPlay 720p\nPlay 1080p\nPlay 2K\nPlay 4K\nBest Resolution\nExit"
    play_choice=$(echo -e "$play_options" | rofi -dmenu -p "Select option" -theme "$theme1")
    [ -z "$play_choice" ] && exit 0
}

music_download() {
    music_options="Download Mp3\nDownload Playlist Mp3\nDownload Flac\nDownload Playlist Flac\nExit"
    music_choice=$(echo -e "$music_options" | rofi -dmenu -p "Select option:" -theme "$theme1")
    [ -z "$music_choice" ] && exit 0
}

# 🎵 Audio only
music() {
    filename="%(title)s.%(ext)s"
    playlistname="%(playlist_index)s - %(title)s.%(ext)s"
    outdir="$HOME/Music/Downloads"
    mkdir -p "$outdir"
    if [ "$1" = "mp3" ]; then
        notify-send -i "$ICON_SUCCESS" "Downloading..." "Audio Mp3"
        if yt-dlp -x --audio-format mp3 \
            -o "$outdir/$filename" \
            "$url"; then
            latest_music=$(ls -t "$outdir" | head -n 1)
            notify-send -i "$ICON_SUCCESS" "$latest_music" "Download complete"
        else 
            notify-send -i "$ICON_FAIL" "❌ Download Failed" "Check the URL or network"
        fi
    elif [ "$1" = "flac" ]; then
        notify-send -i "$ICON_SUCCESS" "Downloading..." "Audio Flac"
        if yt-dlp -x --audio-format flac \
            -o "$outdir/$filename" \
            "$url"; then
            latest_music=$(ls -t "$outdir" | head -n 1)
            notify-send -i "$ICON_SUCCESS" "$latest_music" "Download complete"
        else 
            notify-send -i "$ICON_FAIL" "❌ Download Failed" "Check the URL or network"
        fi
    elif [ "$1" = "playlistmp3" ]; then
        notify-send -i "$ICON_SUCCESS" "Downloading Playlist Mp3"
        if yt-dlp --continue \
            -f bestaudio -x --audio-format mp3 \
            -o "$outdir/$playlistname" \
            "$url"; then
            latest_music=$(ls -t "$outdir" | head -n 1)
            notify-send -i "$ICON_SUCCESS" "$latest_music" "✔ Download Finished"
        else
            notify-send -i "$ICON_FAIL" "❌ Download Failed" "Check the URL or network"
        fi
    else
        notify-send -i "$ICON_SUCCESS" "Downloading Playlist Flac"
        if yt-dlp --continue \
            -f bestaudio -x --audio-format flac \
            -o "$outdir/$playlistname" \
            "$url"; then
            latest_music=$(ls -t "$outdir" | head -n 1)
            notify-send -i "$ICON_SUCCESS" "$latest_music" "✔ Download Finished"
        else 
            notify-send -i "$ICON_FAIL" "❌ Download Failed" "Check the URL or network"
        fi
    fi
}

download() {
    vid_dir="$HOME/Videos/Downloads"
    filename="%(title)s_%(height)sp.%(ext)s"
    mkdir -p "$vid_dir"
    if [ "$1" = "best" ]; then
        notify-send -i "$ICON_SUCCESS" "Downloading..." "Best quality videos"
        if yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 \
            -o "$vid_dir/$filename" "$url"; then
            latest_video=$(ls -t "$vid_dir" | head -n 1)
            notify-send -i "$ICON_SUCCESS" "✔ Download Finished" "$latest_video saved in $vid_dir"
        else
            notify-send -i "$ICON_FAIL" "❌ Download Failed" "Check the URL or network"
        fi
    else
        notify-send -i "$ICON_SUCCESS" " Downloading..." "${1}p auto fallback"
        if yt-dlp -f "bv[height<=$1]+bestaudio/best" \
            -o "$vid_dir/$filename" "$url"; then
            latest_video=$(ls -t "$vid_dir" | head -n 1)
            notify-send -i "$ICON_SUCCESS" "✔ Download Finished" "$latest_video saved in $vid_dir"
        else
            notify-send -i "$ICON_FAIL" "❌ Download Failed" "Check the URL or network"
        fi 
    fi
}

play_select() {
      if [ "$1" = "best" ]; then
            mpv "$url" & 
            notify-send -i "$ICON_SUCCESS" "Playing best video"
        elif [ "$1" == "music" ]; then
            mpv --no-video "$url" &
            notify-send -i "$ICON_SUCCESS" "Playing audio"
        else    
            mpv --ytdl-format="bv[height<=$1]+bestaudio/best" "$url" &
            notify-send -i "$ICON_SUCCESS" "Playing ${1}p auto fallback"
      fi
}

if [ -n "$choice" ]; then
    if [ "$choice" = "Download Videos" ]; then
        download_videos
        case "$download_choice" in
            "Download 240p") download 240 ;;
            "Download 360p") download 360 ;;
            "Download 480p") download 480 ;;
            "Download 720p") download 720 ;;
            "Download 1080p") download 1080 ;;
            "Download 2K") download 1440 ;;
            "Download 4K") download 2160 ;;
            "Best Resolution") download "best" ;;
            "Exit") exit 0 ;;
         esac
    elif [ "$choice" = "Play Music/Videos" ]; then
            play
        case "$play_choice" in
            "Play Music") play_select "music" ;;
            "Play 240p") play_select 240 ;;
            "Play 360p") play_select 360 ;;
            "Play 480p") play_select 480 ;;
            "Play 720p") play_select 720 ;;
            "Play 1080p") play_select 1080 ;; 
            "Play 2K") play_select 1440 ;;
            "Play 4K") play_select 2160 ;;
            "Best Resolution") play_select "best" ;;
            "Exit") exit 0 ;;
        esac  
    elif [ "$choice" = "Download Music" ]; then
            music_download
        case "$music_choice" in
            "Download Mp3") music "mp3" ;;
            "Download Playlist Mp3") music "playlistmp3" ;;
            "Download Flac") music "flac" ;;
            "Download Playlist Flac") music "playlistflac";;
            "Exit") exit 0 ;;
        esac
    fi
fi