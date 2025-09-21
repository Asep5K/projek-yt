#!/usr/bin/env bash

# ============================================================
# Script created by Asep5K
# 🎬 YouTube Downloader & Player (Bash + yad)
# ============================================================

ICON_SUCCESS_URL="https://github.com/Asep5K/projek-yt/blob/main/screenshot/2.jpg?raw=true"
ICON_FAIL_URL="https://github.com/Asep5K/projek-yt/blob/main/screenshot/1.jpg?raw=true"

# Icons
ICON_DIR="$HOME/.local/share/asep_icons"
ICON_SUCCESS="$ICON_DIR/icon_success.jpg"
ICON_FAIL="$ICON_DIR/icon_fail.jpg"

# Log directory
LOGFILE="/tmp/yt.log"
LOGSIZE="/tmp/size.log"
: > "$LOGFILE"   # reset log
: > "$LOGSIZE"

# Downloads dir
MUSIC_DIR="$HOME/Music/Downloads"
VIDEO_DIR="$HOME/Videos/Downloads"

# Url
YTURL='^https?://(www\.)?(youtube\.com|youtu\.be)/[A-Za-z0-9._?&=-]+'
IGURL='^https?://(www\.)?instagram\.com/reels?/[A-Za-z0-9_-]+'
FBURL='^https?://(www\.)?(web\.)?facebook\.com/((share/(r|v)/[A-Za-z0-9_-]+)|(reel/[A-Za-z0-9_-]+))'
XURL='^https?://(www\.)?x\.com/([A-Za-z0-9_]+|i)/status/[0-9]+'

# Name
MUSIC_NAME="%(artist)s - %(title)s.%(ext)s"
PLAYLIST_MUSIC_NAME="%(playlist_index)02d - %(title)s.%(ext)s"
PLAYLIST_MUSIC_DIR="$MUSIC_DIR/%(playlist_title)s"
VIDEO_NAME="%(title)s_%(height)sp.%(ext)s"
PLAYLIST_VIDEO_NAME="%(playlist_index)02d - %(title)s_%(height)sp.%(ext)s"
PLAYLIST_VIDEO_DIR="$VIDEO_DIR/%(playlist_title)s"
REELS_DIR="$VIDEO_DIR/Reels"
REELS_NAME="%(extractor)s_%(id)s.%(ext)s"

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
    --text="Paste link in here:" \
    --width=500 --button="✔ Ok":0 \
    --button="✖ Exit":1)
fi

# 🔧 Fungsi validasi URL
validate_url() {
    local url="$1"

    # kalau kosong → gagal
    if [ -z "$url" ]; then
        exit 0
    fi

    # cek semua regex
    if [[ "$url" =~ $YTURL || "$url" =~ $FBURL || "$url" =~ $IGURL || "$url" =~ $XURL ]]; then
        return 0   # ✅ valid
    else
        return 1   # ❌ invalid
    fi
}

# 🔎 Cek dan validasi URL
if ! validate_url "$URL"; then
    notify-send -i "$ICON_FAIL" "✖ Invalid URL" "The URL you entered is not supported."
    exit 1
fi

# Download ikon kalau belum ada
download_if_missing "$ICON_SUCCESS" "$ICON_SUCCESS_URL" &
download_if_missing "$ICON_FAIL" "$ICON_FAIL_URL" &

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
    "sizecheck")
        yt-dlp -F "$URL" | tee "$LOGSIZE" &
         tail -n +1 -f "$LOGSIZE" | yad --text-info \
             --text="Size List Closing in 120s..." \
             --timeout=120 --timeout-indicator=top \
             --title="Size List" --width=935 \
             --height=667 --button="Close Log":2 &
        ;;
    *)
        return 1
        ;;
    esac
}

notify_done() {
    local FILE="$1"
    notify-send -i "$ICON_SUCCESS" "$FILE" "✔ Download Finished"
}

download_file() {
    local type="$1"   # best, resolusi (720, 1080, dst.)
    local outdir="$2" # folder tujuan
    local name="$3"   # nama file
    local format="$4" # audio: mp3/flac, video: mp4/webm
 
    notify-send -i "$ICON_SUCCESS" "Downloading..." "$type"
    log showlog
 
    if [ "$format" = "mp3" ] || [ "$format" = "flac" ]; then
        # 🔊 Download audio
        log ytlog yt-dlp -x --audio-format "$format" --audio-quality 0 \
            -o "$outdir/$name" "$URL"
 
    elif [ "$format" = "mp4" ] || [ "$format" = "webm" ]; then
        # 📺 Download video
        if [ "$type" = "best" ] || [ "$type" = "Video" ]; then
            log ytlog yt-dlp -f "bestvideo+bestaudio/best" \
                --merge-output-format "$format" \
                -o "$outdir/$name" "$URL"
        else
            log ytlog yt-dlp -f "bv[height<=$type]+bestaudio/best" \
                --merge-output-format "$format" \
                -o "$outdir/$name" "$URL"
        fi
    else
        notify-send -i "$ICON_FAIL" "✖ Unknown format" "$format"
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
download_videos_webm() {
    while true; do
        download_videos_webm=$(yad --list --title="Video options" \
            --column="Option Download Videos webm" \
            "Download 240p.webm" "Download 360p.webm" \
            "Download 480p.webm" "Download 720p.webm" \
            "Download 1080p.webm" "Download 2K.webm" \
            "Download 4K.webm" "Best Resolution.webm" \
            "Back" \
            --width=600 --height=320 \
            --button="✔ Ok":0 --button="✖ Exit":1 \
            --print-column=1)

        download_videos_webm="${download_videos_webm%|}"
        
        if [[ -z "$download_videos_webm" || "$download_videos_webm" == "✖ Exit" ]]; then
            echo "User ✖ Canceled"
            exit 0
        fi
        
        case "$download_videos_webm" in
            "Download 240p.webm") 
                download_file 240 "$VIDEO_DIR" "$VIDEO_NAME" "webm"
                ;;
            "Download 360p.webm") 
                download_file 360 "$VIDEO_DIR" "$VIDEO_NAME" "webm"
                ;;
            "Download 480p.webm") 
                download_file 480 "$VIDEO_DIR" "$VIDEO_NAME" "webm"
                ;;
            "Download 720p.webm") 
                download_file 720 "$VIDEO_DIR" "$VIDEO_NAME" "webm"
                ;;
            "Download 1080p.webm") 
                download_file 1080 "$VIDEO_DIR" "$VIDEO_NAME" "webm"
                ;;
            "Download 2K.webm") 
                download_file 1440 "$VIDEO_DIR" "$VIDEO_NAME" "webm"
                ;;
            "Download 4K.webm") 
                download_file 2160 "$VIDEO_DIR" "$VIDEO_NAME" "webm"
                ;;
            "Best Resolution.webm") 
                download_file "best" "$VIDEO_DIR" "$VIDEO_NAME" "webm"
                ;;
            "Back") 
                return  # Kembali ke menu utama
                ;;
        esac
    done
}

download_videos_mp4() {
    while true; do
        download_videos_mp4=$(yad --list --title="Video options" \
            --column="Option Download Videos" \
            "Download 240p.mp4" "Download 360p.mp4" \
            "Download 480p.mp4" "Download 720p.mp4.mp4" \
            "Download 1080p.mp4" "Download 2K.mp4" \
            "Download 4K.mp4" "Best Resolution.mp4" \
            "Back" \
            --width=600 --height=320 \
            --button="✔ Ok":0 --button="✖ Exit":1 \
            --print-column=1)

        download_videos_mp4="${download_videos_mp4%|}"
        
        if [[ -z "$download_videos_mp4" || "$download_videos_mp4" == "✖ Exit" ]]; then
            echo "User ✖ Canceled"
            exit 0
        fi
        
        case "$download_videos_mp4" in
            "Download 240p.mp4") 
                download_file 240 "$VIDEO_DIR" "$VIDEO_NAME" "mp4"
                ;;
            "Download 360p.mp4") 
                download_file 360 "$VIDEO_DIR" "$VIDEO_NAME" "mp4"
                ;;
            "Download 480p.mp4") 
                download_file 480 "$VIDEO_DIR" "$VIDEO_NAME" "mp4"
                ;;
            "Download 720p.mp4") 
                download_file 720 "$VIDEO_DIR" "$VIDEO_NAME" "mp4"
                ;;
            "Download 1080p.mp4") 
                download_file 1080 "$VIDEO_DIR" "$VIDEO_NAME" "mp4"
                ;;
            "Download 2K.mp4") 
                download_file 1440 "$VIDEO_DIR" "$VIDEO_NAME" "mp4"
                ;;
            "Download 4K.mp4") 
                download_file 2160 "$VIDEO_DIR" "$VIDEO_NAME" "mp4"
                ;;
            "Best Resolution.mp4") 
                download_file "best" "$VIDEO_DIR" "$VIDEO_NAME" "mp4"
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
        play=$(yad --list --title="Play options" \
            --column="Option Play Music/Videos" \
            "Play Music" "Play 240p" "Play 360p" \
            "Play 480p" "Play 720p"\
            "Play 1080p" "Play 2K" \
            "Play 4K" "Best Resolution" \
            "Back" \
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
                return 
                ;;
        esac  
    done
}

# Music menu selector
music_download() {
    while true; do
        music_download=$(yad --list --title="Play options" \
            --column="Option Download Music" \
            "Download Mp3" "Download Flac" \
            "Download Playlist Mp3" \
            "Download Playlist Flac" \
            "Back" \
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
                download_file "playlistmp3" "$PLAYLIST_MUSIC_DIR" "$PLAYLIST_MUSIC_NAME" "mp3" 
                ;;
            "Download Flac")
                download_file "flac" "$MUSIC_DIR" "$MUSIC_NAME" "flac" 
                ;;
            "Download Playlist Flac") 
                download_file "playlistflac" "$PLAYLIST_MUSIC_DIR" "$PLAYLIST_MUSIC_NAME" "flac"
                ;;
            "Back") 
                return 
                ;;
        esac
    done
}

playlist_download() {
    while true; do
        playlist_download=$(yad --list --title="Video options" \
            --column="Option Download Playlist Video" \
            "Playlist 240p" "Playlist 360p" \
            "Playlist 480p" "Playlist 720p" \
            "Playlist 1080p" "Playlist 2K" \
            "Playlist 4K" "Best Resolution" \
            "Back" \
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

all_platform() {
    while true; do
        all_platform=$(yad --list --title="Options" \
            --column="Option Download" \
            "Download Videos/Reels" \
            "Download Sound" \
            "Back" \
            --width=600 --height=320 \
            --button="✔ Ok":0 --button="✖ Exit":1 \
            --print-column=1)
        
        all_platform="${all_platform%|}"
        
        if [[ -z "$all_platform" || "$all_platform" == "✖ Exit" ]]; then
            echo "User ✖ Canceled"
            exit 0
        fi   
        
        case "$all_platform" in
            "Download Videos/Reels")
                download_file "Video" "$REELS_DIR" "$REELS_NAME" "mp4"
                ;;
            "Download Sound")
                download_file "mp3" "$MUSIC_DIR" "$REELS_NAME" "mp3"
                ;;
            "Back")
                return 
                ;;
        esac
    done
    exit 1
}

size_check() {
    : > "/tmp/size.log"
   yt-dlp -F "$URL" | tee "/tmp/size.log" &
    tail -n +1 -f "/tmp/size.log" | yad --text-info --text="Size List Closing in 120s..." --timeout=120 --timeout-indicator=top --title="Size List" --width=935 --height=667 --button="Close Log":2 &
}
# Loop utama
while true; do
    # Tampilkan menu utama
    options=$(yad --list --no-multiple \
        --title="Download Options" \
        --column="Option List" \
        "Download IG/FB/X Videos/Reels" \
        "Download Videos webm" \
        "Download Videos mp4" \
        "Download Playlist Video" \
        "Download Music mp3/flac" \
        "Play Music/Videos" \
        "Check Download Size" \
        --width=600 --height=232 \
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
        "Download IG/FB/X Videos/Reels")
            all_platform
            ;;
        "Download Videos webm")
            download_videos_webm
            ;;
        "Download Videos mp4")
            download_videos_mp4
            ;;
        "Download Music mp3/flac")
            music_download
            ;;
        "Download Playlist Video")
            playlist_download
            ;;
        "Play Music/Videos")
            play
            ;;
        "Check Download Size")
            log sizecheck
            ;;
    esac
done