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
# export PATH="$PATH:$HOME/.cargo/bin:$HOME/.local/bin"
ICON_SUCCESS_URL="https://pbs.twimg.com/profile_images/1937897644816265216/R9fhEWX3_400x400.jpg"
ICON_FAIL_URL="https://pbs.twimg.com/media/Gzho6tiXUAAEXyj?format=jpg&name=medium"
ICON_DIR="$HOME/.local/share/asep_icons"
ICON_SUCCESS="$ICON_DIR/icon_success.jpg"
ICON_FAIL="$ICON_DIR/icon_fail.jpg"
LOG_DIR=/tmp/yt
LOGFILE=yt.log
# Pastikan folder ada
[ ! -d "$ICON_DIR" ] && mkdir -p "$ICON_DIR"

# Download ikon kalau belum ada
[ ! -f "$ICON_SUCCESS" ] && wget -q -O "$ICON_SUCCESS" "$ICON_SUCCESS_URL"
[ ! -f "$ICON_FAIL" ] && wget -q -O "$ICON_FAIL" "$ICON_FAIL_URL"

# trap 'pkill -P $$ mpv; pkill -P $$ yt-dlp' EXIT

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
    url=$(yad --entry \
    --title="Enter YouTube URL" \
    --text="Paste YouTube link here:" \
    --width=500)
fi

if pidof yad > /dev/null; then
    pkill yad
fi

# 🔎 Cek dan validasi URL
if [ -z "$url" ]; then
    exit 0
elif [[ ! "$url" =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/ ]]; then
    notify-send -i "$ICON_FAIL" "Invalid URL" "Only YouTube links are allowed!"
    exit 1
fi

# 📌 Menu options
    options=$(yad --list \
        --title="Download Options" \
        --column="Option" \
        "Download Videos" \
        "Download Music" \
        "Play Music/Videos" \
        "Download Playlist Flac" \
        --width=600 --height=200 \
        --button=ok:0 \
        --button=cancel:1 \
        --print-column=1)
    options="${options%|}"
    if [[ -z "$options" ]]; then
        echo "User canceled"
        exit 0
    fi

# Log
log() {
    mkdir -p "$LOG_DIR"
    > "$LOG_DIR/$LOGFILE"
    # yt-dlp --newline "$URL" > "$LOG_DIR/$LOGFILE" 2>&1 &
    # yad --progress --title="Downloading..." --text="Please wait..." --percentage=0 --auto-close --file="$LOG_DIR/$LOGFILE"
    # (
    #   while IFS= read -r line; do
    #     # parse persentase dari yt-dlp output
    #     percent=$(echo "$line" | grep -oP '\d+(?=%)' | head -n1)
    #     [ -n "$percent" ] && echo $percent
    #   done < <(tail -f "$LOG_DIR/$LOGFILE")
    # ) | yad --progress --title="Downloading..." --auto-close --percentage=0
    yad --progress-teks="$LOG_DIR/$LOGFILE"
}

# Download videos
download_videos() {
    download_videos=$(yad --list --title="Video options" --column=Option \
        "Download 240p" "Download 360p" "Download 480p" \
        "Download 720p" "Download 1080p" "Download 2K" \
        "Download 4K" "Best Resolution" "Exit" \
        --width=600 --height=320 \
        --button=ok:0 --button=cancel:1 \
        --print-column=1)
    download_videos="${download_videos%|}"
    if [[ -z "$download_videos" ]]; then
        echo "User canceled"
        exit 0
    fi
}
play() {
    play=$(yad --list --title="Play options" --column=Option \
        "Play Music" "Play 240p" "Play 360p" "Play 480p" \
        "Play 720p" "Play 1080p" "Play 2K" \
        "Play 4K" "Best Resolution" "Exit" \
        --width=600 --height=320 \
        --button=ok:0 --button=cancel:1 \
        --print-column=1)
    play="${play%|}"
    if [[ -z "$play" ]]; then
        echo "User canceled"
        exit 0
    fi
}

music_download() {
    music_download=$(yad --list --title="Play options" --column=Option \
        "Download Mp3" "Download Playlist Mp3" \
        "Download Flac" "Download Playlist Flac" "Exit" \
        --width=600 --height=320 \
        --button=ok:0 --button=cancel:1 \
        --print-column=1)
    music_download="${music_download%|}"
    if [[ -z "$music_download" ]]; then
        echo "User canceled"
        exit 0
    fi
}

# 🎵 Audio only
music() {
    outdir="$HOME/Music/Downloads"
    filename="%(title)s.%(ext)s"
    playlistname="%(playlist_index)02d - %(title)s.%(ext)s"
    renamefile() {
        for f in "$outdir"/*.{flac,mp3}; do
            [ -e "$f" ] || continue
            new=$(echo "$f" | sed -E 's/^0([0-9]{2})/\1/')
            mv "$f" "$new"
        done
    }
    mkdir -p "$outdir"
    if [ "$1" = "mp3" ]; then
        # log &
        notify-send -i "$ICON_SUCCESS" "Downloading..." "Audio Mp3"
        if yt-dlp -x --audio-format mp3 \
            -o "$outdir/$filename" \
            "$url"; then #> "$LOG_DIR/$LOGFILE" 2>&1; then
            latest_music=$(ls -t "$outdir" | head -n 1)
            notify-send -i "$ICON_SUCCESS" "$latest_music" "Download complete"
        else 
            notify-send -i "$ICON_FAIL" "❌ Download Failed" "Check the URL or network"
        fi
    elif [ "$1" = "flac" ]; then
        notify-send -i "$ICON_SUCCESS" "Downloading..." "Audio Flac"
        if  yt-dlp -x --audio-format flac \
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
            -o "$outdir"/"$playlistname" \
            "$url"; then
            latest_music=$(ls -t "$outdir" | head -n 1)
            notify-send -i "$ICON_SUCCESS" "$latest_music" "✔ Download Finished"
            # renamefile
        else
            notify-send -i "$ICON_FAIL" "❌ Download Failed" "Check the URL or network"
        fi
    else
        notify-send -i "$ICON_SUCCESS" "Downloading Playlist Flac"
        if yt-dlp --continue \
            -f bestaudio -x --audio-format flac \
            -o "$outdir"/"$playlistname" \
            "$url"; then
            latest_music=$(ls -t "$outdir" | head -n 1)
            notify-send -i "$ICON_SUCCESS" "$latest_music" "✔ Download Finished"
            # renamefile
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

if [ -n "$options" ]; then
    if [ "$options" = "Download Videos" ]; then
        download_videos
        case "$download_videos" in
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
    elif [ "$options" = "Play Music/Videos" ]; then
            play
        case "$play" in
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
    elif [ "$options" = "Download Music" ]; then
            music_download
        case "$music_download" in
            "Download Mp3") music "mp3" ;;
            "Download Playlist Mp3") music "playlistmp3" ;;
            "Download Flac") music "flac" ;;
            "Download Playlist Flac") music "playlistflac";;
            "Exit") exit 0 ;;
        esac
    fi
fi