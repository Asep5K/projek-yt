#!/usr/bin/env bash

set -e

URL=$1

# Downloads dir
MUSIC_DIR="/sdcard/Music/Downloads"
VIDEO_DIR="/sdcard/Videos/Downloads"

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

# Connection check
check_internet() {
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo "✖ No Internet" "Please check your connection!"
        exit 1
    fi
}

# yt-dlp check
if ! command -v yt-dlp >/dev/null 2>&1; then
    # kalo ga ada, kirim notif
    echo "⚠ Warning" "yt-dlp not found!"
    exit 1
fi

check_internet

# directory check
check_dir() {
    local dir=$1

    if [ "$dir" = "audio" ]; then
        if [ ! -d "$HOME/Music" ] || [ ! -L "$HOME/Music" ]; then
            mkdir -p "$INTERNAL_MUSIC_DIR"
            ln -sf "$INTERNAL_MUSIC_DIR" "$HOME/Music"
        fi
    else
        if [ ! -d "$HOME/Videos" ] || [ ! -L "$HOME/Videos" ]; then
            mkdir -p "$INTERNAL_VIDEOS_DIR"
            ln -sf "$INTERNAL_VIDEOS_DIR" "$HOME/Videos"
        fi
    fi
}

# validation url 
validate_url() {
    local url="$1"
    [ -z "$url" ] && return 1

    local combined_regex="($YTURL|$FBURL|$IGURL|$XURL)"
    if [[ "$url" =~ $combined_regex ]]; then
        return 0   # valid
    else
        return 1   # invalid
    fi
}

# URL
until validate_url "$URL"; do
    echo "✖ Invalid URL, try again"
    read -p "Enter URL: " URL
done

if [[ ! "$URL" ]]; then
    clear
    read -p "enter url: " URL
fi

# download function
download_file() {
    local type="$1"   # best, resolusi (720, 1080, dst.)
    local outdir="$2" # folder tujuan
    local name="$3"   # nama file
    local format="$4" # audio: mp3/flac, video: mp4/webm

    echo "Downloading..." "$type"
    echo "Downloading $format file to $outdir..."
    if [ "$format" = "mp3" ] || [ "$format" = "flac" ]; then
        # 🔊 Download audio
         yt-dlp -x --audio-format "$format" --audio-quality 0 \
            -o "$outdir/$name" "$URL" --restrict-filenames
    elif [ "$format" = "audio" ]; then
        yt-dlp -t mp3 -o "$outdir/$name" "$URL" --restrict-filenames
    elif [ "$format" = "mp4" ] || [ "$format" = "webm" ]; then
        # 📺 Download video
        if [ "$type" = "best" ] || [ "$type" = "Reels" ]; then
            yt-dlp -f "bv[vcodec^=avc1]+bestaudio / bv[vcodec^=av01]+bestaudio / best"  \
                --merge-output-format "$format" \
                -o "$outdir/$name" "$URL" --restrict-filenames
        else
            yt-dlp -f "bv[height<=$type][vcodec^=avc1]+bestaudio / bv[height<=$type][vcodec^=av01]+bestaudio" \
                --merge-output-format "$format" \
                -o "$outdir/$name" "$URL" --restrict-filenames
        fi
    else
        echo "✖ Unknown format" "$format"
    fi
 
    local status=$?   # simpan exit status yt-dlp
 
    if [ $status -eq 0 ]; then
        latest_file=$(ls -t "$outdir" | head -n 1)  # ambil file terbaru
        echo "✔ Download finished: $latest_file"
        exit 0                  # kirim notifikasi selesai
    else
        echo "✖ Download Failed" "Check the URL or network"
    fi
}

# videos webm func
download_videos_webm() {
    clear
    echo "⚠ Warning: Downloading webm may fail during merge. (Not recommended)"
    while true; do
        echo "Option Download Videos (webm)"
        cat << EOF
1. 240p
2. 360p
3. 480p
4. 720p
5. 1080p
6. 2k (1440p)
7. 4k (2160p)
8. Best Resolution
9. Back
10. Exit
EOF
        
        read -p "Enter your choice: " choice

        case "$choice" in
            1) download_file 240 "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            2) download_file 360 "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            3) download_file 480 "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            4) download_file 720 "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            5) download_file 1080 "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            6) download_file 1440 "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            7) download_file 2160 "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            8) download_file "best" "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            9) return ;;  # Back
            10)  echo "Exiting..."; exit 0 ;;
            *) echo "Invalid choice, try again!" ;;
        esac
    done
}

# video mp4 func
download_videos_mp4() {
    clear
    while true; do
        echo "Option Download Videos (mp4)"
        cat << EOF
1. 240p
2. 360p
3. 480p
4. 720p
5. 1080
6. 2k (1440p)
7. 4k (2160p)
8. Best Resolution
9. Back
10. Exit            
EOF
        
        read -p "Enter your choice: " choice

        case "$choice" in
            1) download_file 240 "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            2) download_file 360 "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            3) download_file 480 "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            4) download_file 720 "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            5) download_file 1080 "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            6) download_file 1440 "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            7) download_file 2160 "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            8) download_file "best" "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            9) return ;;  # Back
            10) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid choice, try again!" ;;
        esac
    done
}

# music download func
music_download() {
    clear
    while true; do
        echo "Option Download Music"
        cat << EOF
1. Download Mp3
2. Download Flac
3. Download Playlist Mp3
4. Download Playlist Flac
5. Back
6. Exit
EOF

        read -p "Enter your choice: " choice

        case "$choice" in
            1) download_file "mp3" "$MUSIC_DIR" "$MUSIC_NAME" "mp3" ;;
            2) download_file "flac" "$MUSIC_DIR" "$MUSIC_NAME" "flac" ;;
            3) download_file "playlistmp3" "$PLAYLIST_MUSIC_DIR" "$PLAYLIST_MUSIC_NAME" "mp3" ;;
            4) download_file "playlistflac" "$PLAYLIST_MUSIC_DIR" "$PLAYLIST_MUSIC_NAME" "flac" ;;
            5) return ;;  # Back
            6) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid choice, try again!" ;;
        esac
    done
}

# playlist download func
playlist_download() {
    clear
    while true; do
        echo "Option Download Playlist Video"
        cat << EOF
1. 240p
2. 360p
3. 480p
4. 720p
5. 1080p
6. 2K (1440p)
7. 4K (2160p)
8. Best Resolution
9. Back
10. Exit
EOF

        read -p "Enter your choice: " choice

        case "$choice" in
            1) download_file 240 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            2) download_file 360 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            3) download_file 480 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            4) download_file 720 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            5) download_file 1080 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            6) download_file 1440 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            7) download_file 2160 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            8) download_file "best" "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            9) return ;;  # Back
            10) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid choice, try again!" ;;
        esac
    done
}

# reels download  func
all_platform() {
    clear
    while true; do
        echo "Options Download"
        cat << EOF
1. Download Reels
2. Download Audio
3. Back
4. Exit
EOF

        read -p "Enter your choice: " choice

        case "$choice" in
            1) download_file "Reels" "$REELS_DIR" "$REELS_NAME" "mp4" ;;
            2) download_file "audio" "$MUSIC_DIR" "$REELS_NAME" "audio" ;;
            3) return ;;  # Back
            4) echo "Exiting ..."; exit 0 ;;
            *) echo "Invalid choice, try again!" ;;
        esac
    done
}

# check size func
size_check() {
   yt-dlp -F "$URL" 
}

# menu func
while true; do
    # clear
    echo "Download Options"
    cat << EOF
1. Download IG/FB/X Video Reels
2. Download Videos webm (⚠ Not recommended)
4. Download Playlist Videos
5. Download Music mp3/flac
6. Check Download Size
7. Exit
EOF

    read -p "Enter your choice: " choice
        case "$choice" in
            1) all_platform ;;
            2) download_videos_webm ;;
            3) download_videos_mp4 ;;
            4) playlist_download ;;
            5) music_download ;;
            6) size_check ;;
            7) echo "Exiting..."; exit 0 ;;
            *) echo "Invalid choice, try again!" ;;
        esac
done
