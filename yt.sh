#!/usr/bin/env bash

# ============================================================
# Script created by Asep5K
# 🎬 YouTube Downloader & Player (Bash + yad)
# ============================================================

# Link icons
ICON_SUCCESS_URL="https://github.com/Asep5K/projek-yt/blob/main/screenshot/2.jpg?raw=true"
ICON_FAIL_URL="https://github.com/Asep5K/projek-yt/blob/main/screenshot/1.jpg?raw=true"

# Icons
ICON_DIR="$HOME/.local/share/asep_icons"
ICON_SUCCESS="$ICON_DIR/icon_success.jpg"
ICON_FAIL="$ICON_DIR/icon_fail.jpg"

# Log directory
LOGFILE="/tmp/yt.log"
: > "$LOGFILE"   # reset log

# Downloads dir
MUSIC_DIR="$HOME/Music/Downloads"
VIDEO_DIR="$HOME/Videos/Downloads"

# Name
MUSIC_NAME="%(artist)s - %(title)s.%(ext)s"
PLAYLIST_MUSIC_NAME="%(playlist_index)02d - %(artist) - %(title)s.%(ext)s"
VIDEO_NAME="%(title)s_%(height)sp.%(ext)s"
PLAYLIST_VIDEO_NAME="%(playlist_index)02d - %(title)s_%(height)sp.%(ext)s"
PLAYLIST_VIDEO_DIR="$VIDEO_DIR/%(playlist_title)s"

# Pastikan folder ada
[ ! -d "$ICON_DIR" ] && mkdir -p "$ICON_DIR"

download_if_missing() {
    local FILE="$1"
    local URL="$2"

    if [ ! -f "$FILE" ]; then
        wget -q -O "$FILE" "$URL" 
    fi
}

# Connection check
check_internet() {
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        notify-send -i "$ICON_FAIL" "✖ No Internet" "Please check your connection!"
        exit 1
    fi
}

# yt-dlp check
if ! command -v yt-dlp >/dev/null 2>&1; then
    # kalo ga ada, kirim notif
    notify-send -i "$ICON_FAIL" "⚠ Warning" "yt-dlp not found!"
    exit 1
else
    # Internet check
    check_internet

    # Input URL
    URL=$(yad --entry \
    --title="Enter YouTube URL" \
    --text="Paste YouTube link here:" \
    --width=500 --button="✔ Ok":0 \
    --button="✖ Exit":1)
fi

# 🔎 Cek dan validasi URL
if [ -z "$URL" ]; then
    exit 0
elif [[ ! "$URL" =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/ ]]; then
    notify-send -i "$ICON_FAIL" "Invalid URL" "Only YouTube links are allowed!"
    exit 1
fi

# Download ikon kalau belum ada
download_if_missing "$ICON_SUCCESS" "$ICON_SUCCESS_URL" &
download_if_missing "$ICON_FAIL" "$ICON_FAIL_URL" &

notify_done() {
    local FILE="$1"
    notify-send -i "$ICON_SUCCESS" "$FILE" "✔ Download Finished"
}

# Log
log() {
    case "$1" in
    "ytlog")
        shift               # buang argumen pertama (ytlog)
        # jalankan perintah, arahkan stdout+stderr ke tee, ambil exit status dari command asli
        "$@" 2>&1 | tee "$LOGFILE"
        # ambil exit status dari program pertama di pipeline (yt-dlp)
        local st=${PIPESTATUS[0]}
        return $st
        ;;
    "showlog")
        # kalau viewer udah jalan, jangan buka lagi
        if [ -f /tmp/yt_log_viewer.pid ]; then
            pid=$(cat /tmp/yt_log_viewer.pid)
            if kill -0 "$pid" 2>/dev/null; then
                return 0
            else
                rm -f /tmp/yt_log_viewer.pid
            fi
        fi

        # pakai tail -n +1 supaya isi file yang sudah ada langsung muncul
        tail -n +1 -f "$LOGFILE" | yad --text-info --title="Log Status" --width=500 --height=300 --button="Close Log":2 &
        echo $! > /tmp/yt_log_viewer.pid
        ;;
    "hideview")
        if [ -f /tmp/yt_log_viewer.pid ]; then
            pid=$(cat /tmp/yt_log_viewer.pid)
            kill "$pid" 2>/dev/null || true
            rm -f /tmp/yt_log_viewer.pid
        fi
        ;;
    *)
        return 1
        ;;
    esac
}

download_file() {
    local type="$1"   # best, mp3, flac, playlistmp3, playlistflac, atau resolusi
    local outdir="$2" # folder tujuan, VIDEO_DIR atau MUSIC_DIR
    local name="$3"   # nama file
    local format="$4" # untuk audio: mp3/flac, untuk video kosong

    notify-send -i "$ICON_SUCCESS" "Downloading..." "$type"
    
    log showlog

    if [ -n "$format" ]; then
        # download audio
        log ytlog yt-dlp -x --audio-format "$format" --audio-quality 0 -o "$outdir/$name" "$URL"
    else
        if [ "$type" = "best" ]; then
            # download video terbaik
            log ytlog yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 -o "$outdir/$name" "$URL"
        else
            # download video dengan resolusi tertentu
            log ytlog yt-dlp -f "bv[height<=$type]+bestaudio/best" -o "$outdir/$name" "$URL"
        fi
    fi

    local status=$?   # simpan exit status yt-dlp
    

    if [ $status -eq 0 ]; then
        log hideview
        latest_file=$(ls -t "$outdir" | head -n 1)  # ambil file terbaru
        notify_done "$latest_file"  &&
        exit 0                  # kirim notifikasi selesai
    else
        notify-send -i "$ICON_FAIL" "✖ Download Failed" "Check the URL or network"
    fi
}

# Menu download selector
download_videos() {
    while true; do
        download_videos=$(yad --list --title="Video options" --column="Option Download Videos" \
            "Download 240p" "Download 360p" "Download 480p" \
            "Download 720p" "Download 1080p" "Download 2K" \
            "Download 4K" "Best Resolution" "Back" \
            --width=600 --height=320 \
            --button="✔ Ok":0 --button="✖ Exit":1 \
            --print-column=1)

        download_videos="${download_videos%|}"
        
        if [[ -z "$download_videos" || "$download_videos" == "✖ Exit" ]]; then
            echo "User ✖ Canceled"
            exit 0
        fi
        
        case "$download_videos" in
            "Download 240p") 
                download_file 240 "$VIDEO_DIR" "$VIDEO_NAME" 
                ;;
            "Download 360p") 
                download_file 360 "$VIDEO_DIR" "$VIDEO_NAME" 
                ;;
            "Download 480p") 
                download_file 480 "$VIDEO_DIR" "$VIDEO_NAME"
                ;;
            "Download 720p") 
                download_file 720 "$VIDEO_DIR" "$VIDEO_NAME" 
                ;;
            "Download 1080p") 
                download_file 1080 "$VIDEO_DIR" "$VIDEO_NAME"
                ;;
            "Download 2K") 
                download_file 1440 "$VIDEO_DIR" "$VIDEO_NAME"
                ;;
            "Download 4K") 
                download_file 2160 "$VIDEO_DIR" "$VIDEO_NAME"
                ;;
            "Best Resolution") 
                download_file "best" "$VIDEO_DIR" "$VIDEO_NAME"
                ;;
            "Back") 
                return  # Kembali ke menu utama
                ;;
        esac
    done
}

# Play menu selector
play() {
    while true; do
        play=$(yad --list --title="Play options" --column="Option Play Music/Videos" \
            "Play Music" "Play 240p" "Play 360p" "Play 480p" \
            "Play 720p" "Play 1080p" "Play 2K" \
            "Play 4K" "Best Resolution" "Back" \
            --width=600 --height=320 \
            --button="▶ Play":0 --button="✖ Exit":1 \
            --print-column=1)
        
        play="${play%|}"
        
        if [[ -z "$play" || "$play" == "✖ Exit" ]]; then
            echo "User ✖ Canceled"
            exit 0
        fi

        case "$play" in
            "Play Music") 
                play_select "music" 
                exit 0
                ;;
            "Play 240p") 
                play_select 240 
                exit 0
                ;;
            "Play 360p") 
                play_select 360 
                exit 0
                ;;
            "Play 480p") 
                play_select 480 
                exit 0
                ;;
            "Play 720p") 
                play_select 720 
                exit 0
                ;;
            "Play 1080p") 
                play_select 1080 
                exit 0
                ;; 
            "Play 2K") 
                play_select 1440 
                exit 0
                ;;
            "Play 4K") 
                play_select 2160 
                exit 0
                ;;
            "Best Resolution") 
                play_select "best" 
                exit 0
                ;;
            "Back") 
            return ;;
        esac  
    done
}

# Music menu selector
music_download() {
    while true; do
        music_download=$(yad --list --title="Play options" --column="Option Download Music" \
            "Download Mp3" "Download Playlist Mp3" \
            "Download Flac" "Download Playlist Flac" "Back" \
            --width=600 --height=210 \
            --button="✔ Ok":0 --button="✖ Exit":1 \
            --print-column=1)

        music_download="${music_download%|}"

        if [[ -z "$music_download" || "$music_download"  == "✖ Exit" ]]; then
            echo "User ✖ Canceled"
            exit 0
        fi

        case "$music_download" in
            "Download Mp3") 
                download_file "mp3" "$MUSIC_DIR" "$MUSIC_NAME" "mp3"
                ;;
            "Download Playlist Mp3") 
                download_file "playlistmp3" "$MUSIC_DIR" "$PLAYLIST_MUSIC_NAME" "mp3" 
                ;;
            "Download Flac")
                download_file "flac" "$MUSIC_DIR" "$MUSIC_NAME" "flac" 
                ;;
            "Download Playlist Flac") 
                download_file "playlistflac" "$MUSIC_DIR" "$PLAYLIST_MUSIC_NAME" "flac"
                ;;
            "Back") 
                return 
                ;;
        esac
    done
}

playlist_download() {
    while true; do
        playlist_download=$(yad --list --title="Video options" --column="Option Download Playlist Video" \
            "Playlist 240p" "Playlist 360p" "Playlist 480p" \
            "Playlist 720p" "Playlist 1080p" "Playlist 2K" \
            "Playlist 4K" "Best Resolution" "Back" \
            --width=600 --height=320 \
            --button="✔ Ok":0 --button="✖ Exit":1 \
            --print-column=1)
        
        playlist_download="${playlist_download%|}"
        
        if [[ -z "$playlist_download" || "$playlist_download" == "✖ Exit" ]]; then
            echo "User ✖ Canceled"
            exit 0
        fi   

        case "$playlist_download" in
            "Playlist 240p") 
                download_file 240 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" 
                ;;
            "Playlist 360p") 
                download_file 360 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" 
                ;;
            "Playlist 480p") 
                download_file 480 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME"
                ;;
            "Playlist 720p") 
                download_file 720 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" 
                ;;
            "Playlist 1080p") 
                download_file 1080 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME"
                ;;
            "Playlist 2K") 
                download_file 1440 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME"
                ;;
            "Playlist 4K") 
                download_file 2160 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME"
                ;;
            "Best Resolution") 
                download_file "best" "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME"
                ;;
            "Back") 
                return 
                ;;
         esac
    done 
    exit 1
}

# Select option
play_select() {
    if [ "$1" = "best" ]; then
        mpv "$URL" & 
        notify-send -i "$ICON_SUCCESS" "Playing best video"
    elif [ "$1" == "music" ]; then
        mpv --no-video "$URL" &
        notify-send -i "$ICON_SUCCESS" "Playing audio"
    else    
        mpv --ytdl-format="bv[height<=$1]+bestaudio/best" "$URL" &
        notify-send -i "$ICON_SUCCESS" "Playing ${1}p auto fallback"
    fi
}

# Loop utama
while true; do
    # Tampilkan menu utama
    options=$(yad --list --no-multiple \
        --title="Download Options" \
        --column="Option" \
        "Download Videos" \
        "Download Music" \
        "Download Playlist Video" \
        "Play Music/Videos" \
        --width=600 --height=200 \
        --button="✔ Ok":0 \
        --button="✖ Exit":1 \
        --print-column=1)

    options="${options%|}"
    
    if [[ -z "$options" || "$options" == "✖ Exit" ]]; then
        echo "User ✖ Canceled"
        exit 0
    fi
    
    # Proses pilihan
    case "$options" in
        "Download Videos")
            download_videos
            ;;
        "Download Music")
            music_download
            ;;
        "Download Playlist Video")
            playlist_download
            ;;
        "Play Music/Videos")
            play
            ;;
    esac
done