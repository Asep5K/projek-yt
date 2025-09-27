#!/usr/bin/env bash

clear
set -euo pipefail
URL=$1

# ==========================
# Directories & Detect platform
# ==========================
if [ -d "/sdcard" ]; then
    # Likely Termux / Android
    VIDEO_DIR="/sdcard/Videos/Downloads"
    MUSIC_DIR="/sdcard/Music/Downloads"
else
    # Likely Linux Desktop
    VIDEO_DIR="$HOME/Videos/Downloads"
    MUSIC_DIR="$HOME/Music/Downloads"
fi

# Name
MUSIC_NAME="%(artist)s - %(title)s.%(ext)s"
PLAYLIST_MUSIC_NAME="%(playlist_index)02d - %(title)s.%(ext)s"
PLAYLIST_MUSIC_DIR="$MUSIC_DIR/%(playlist_title)s"
VIDEO_NAME="%(title)s_%(height)sp.%(ext)s"
PLAYLIST_VIDEO_NAME="%(playlist_index)02d - %(title)s_%(height)s"p".%(ext)s"
PLAYLIST_VIDEO_DIR="$VIDEO_DIR/%(playlist_title)s"
REELS_DIR="$VIDEO_DIR/Reels"
REELS_NAME="%(extractor)s_%(id)s.%(ext)s"

# Banner ASCII Art
Asep5K() {
    cat <<EOF
    ___                    ________ __
   /   |  ________  ____  / ____/ //_/
  / /| | / ___/ _ \/ __ \/___ \/ ,<   
 / ___ |(__  )  __/ /_/ /___/ / /| |  
/_/  |_/____/\___/ .___/_____/_/ |_|  
                /_/                   
EOF
}

# Connection check
check_internet() {
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        echo "✖ No Internet" "Please check your connection!"
        exit 1
    fi
}

# URL validation
validate_url() {
    if [[ "$1" =~ ^https?:// ]]; then
        return 0  # valid
    else
        echo "✖ Invalid URL. Must start with http:// or https://"
        return 1  # invalid
    fi
}

# Prompt user for new URL
new_url() {
    while true; do
        read -p "Enter URL (or 'e' to Exit): " URL
        [ "$URL" = "e" ] && exit 0

        if validate_url "$URL"; then
            break
        fi
    done
}
# Package installer (cross-distro)
package_install() {
    local package="$1"
    if command -v "$package" >/dev/null 2>&1; then
        echo "✔ $package is already installed: $(command -v "$package")"
        return 0
    fi

    echo "⚠ $package not found, installing..."

    if command -v pkg >/dev/null 2>&1; then
        pkg install -y "$package" 
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm "$package"
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y "$package"
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y "$package"
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y "$package"
    else
        echo "Error: No supported package manager found."
        echo "Please install $package manually"
        return 1
    fi
}

# Wrapper functions
package_install_ffmpeg() { package_install ffmpeg; }
package_install_mpv() { package_install mpv; }

# Install yt-dlp (latest binary from GitHub)

yt-dlp_install() {
    local dir="$HOME/.local/bin"
    local name="yt-dlp"
    local url="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp"

    # Download yt-dlp
    if command -v curl >/dev/null 2>&1; then
        mkdir -p "$dir"
        curl -L "$url" -o "$dir/$name"
    elif command -v wget >/dev/null 2>&1; then
        mkdir -p "$dir"
        wget "$url" -O "$dir/$name"
    else 
        echo "Error: curl or wget not found"
        echo "Installing wget..."
        package_install "wget" || return 1
        wget "$url" -O "$dir/$name"
    fi
    
    if [ ! -f "$dir/$name" ]; then
        echo "Download failed!"
        return 1
    fi

    chmod +x "$dir/$name"
    export PATH="$dir:$PATH"

    # Ensure $dir is in PATH
    case ":$PATH:" in
        *":$dir:"*) 
            echo "$dir is already in PATH"
            ;;
        *)
            echo "Adding $dir to PATH..."

            shell_name=$(basename "$SHELL")

            case "$shell_name" in
                bash)
                    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
                    ;;
                zsh)
                    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
                    ;;
                fish)
                    echo "set -U fish_user_paths \$HOME/.local/bin \$fish_user_paths" >> "$HOME/.config/fish/config.fish"
                    ;;
                *)
                    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.profile"
                    ;;
            esac

            echo "PATH updated. Please restart your shell or run 'source' on your shell config file."
            ;;
    esac

    echo "✔ yt-dlp installed at $dir/$name"
    echo "Check version with: yt-dlp --version"
}

# Install if missing
check_or_install() {
    local cmd="$1"
    local install_func="$2"

    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "⚠ $cmd not found! Installing..."
        $install_func
    else
        echo "✔ $cmd is already installed"
    fi
}

# Update yt-dlp
yt-dlp_update() {
    if yt-dlp -U; then
        echo "✔ yt-dlp updated successfully"
    else
        echo "✖ Update failed. If you installed yt-dlp via a package manager, use that instead."
    fi
}
# General download function
download_file() {
    local type="$1"
    local outdir="$2"
    local name="$3"
    local format="$4"

    echo "Downloading $type... Please wait..."

    if [ "$format" = "mp3" ] || [ "$format" = "flac" ]; then
        yt-dlp -x --audio-format "$format" --audio-quality 0 \
            -o "$outdir/$name" "$URL" --restrict-filenames
    elif [ "$format" = "audio" ]; then
        yt-dlp -t mp3 -o "$outdir/$name" "$URL" --restrict-filenames
    elif [ "$format" = "mp4" ] || [ "$format" = "webm" ]; then
        if [ "$type" = "best" ] || [ "$type" = "Reels" ]; then
            yt-dlp -f "bv[vcodec^=avc1]+bestaudio / bv[vcodec^=av01]+bestaudio / best" \
                --merge-output-format "$format" \
                -o "$outdir/$name" "$URL" --restrict-filenames
        else
            yt-dlp -f "bv[height<=$type][vcodec^=avc1]+bestaudio / bv[height<=$type][vcodec^=av01]+bestaudio" \
                --merge-output-format "$format" \
                -o "$outdir/$name" "$URL" --restrict-filenames
        fi
    else
        echo "✖ Unknown format $format"
    fi

    if [ $? -eq 0 ]; then
        latest_file=$(ls -t "$outdir" | head -n 1)
        echo "✔ Download finished: $latest_file"
    else
        echo "✖ Download Failed. Check the URL or network."
    fi
}

# Show available formats/size
size_check() {
    clear
    yt-dlp -F "$URL"
}
# Play video/music with mpv
play_select() {
    if [ "$1" = "best" ]; then
        mpv --ytdl-format="bv[vcodec^=avc1]+bestaudio / best" "$URL" & 
    elif [ "$1" == "music" ]; then
        mpv --no-video "$URL" &
    else    
        mpv --ytdl-format="bv[height<=$1][vcodec^=avc1]+bestaudio / bv[height<=$1][vcodec^=av01]+bestaudio" "$URL" &
    fi
}

play() {
    clear
    Asep5K
    check_or_install mpv package_install_mpv
    while true; do
        echo "[Play Options]"
        cat << EOF
1. Music
2. 240p
3. 360p
4. 480p
5. 720p
6. 1080p
7. 2K (1440p)
8. 4K (2160p)
9. Best Resolution
b. Back
n. New url
e. Exit
EOF

        read -n 1 -p "Enter your choice: " choice
        echo ""
        case "$choice" in
            1) play_select "music" >/dev/null ;;
            2) play_select 240 >/dev/null ;;
            3) play_select 360 >/dev/null ;;
            4) play_select 480 >/dev/null ;;
            5) play_select 720 >/dev/null ;;
            6) play_select 1080 >/dev/null ;; 
            7) play_select 1440 >/dev/null ;;
            8) play_select 2160 >/dev/null ;;
            9) play_select "best" >/dev/null ;;
            b) return ;;
            n) new_url ;;
            e) exit 0 ;;
        esac  
    done
}
# Semua menu dipindah ke sini biar rapi
download_videos_webm() {
    clear
    Asep5K
    echo "⚠ Warning: Downloading webm may fail during merge. (Not recommended)"
    while true; do
        echo "[Video Options (WEBM)]"
        cat << EOF
1. 240p
2. 360p
3. 480p
4. 720p
5. 1080p
6. 2k (1440p)
7. 4k (2160p)
8. Best Resolution
b. Back
n. New url
e. Exit
EOF
        
        read -n 1 -p "Enter your choice: " choice
	echo ""
	
        case "$choice" in
            1) download_file 240 "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            2) download_file 360 "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            3) download_file 480 "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            4) download_file 720 "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            5) download_file 1080 "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            6) download_file 1440 "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            7) download_file 2160 "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            8) download_file "best" "$VIDEO_DIR" "$VIDEO_NAME" "webm" ;;
            b) clear; return ;;  # Back
            n) new_url ;;
            e) exit 0 ;;
            *) echo "Invalid choice, try again!" ;;
        esac
    done
}

# video mp4 func
download_videos_mp4() {
    clear
    Asep5K
    while true; do
        echo "[Video Options (MP4)]"
        cat << EOF
1. 240p
2. 360p
3. 480p
4. 720p
5. 1080p
6. 2k (1440p)
7. 4k (2160p)
8. Best Resolution
b. Back
n. New url
e. Exit            
EOF
        
        read -n 1 -p "Enter your choice: " choice
	echo ""

        case "$choice" in
            1) download_file 240 "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            2) download_file 360 "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            3) download_file 480 "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            4) download_file 720 "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            5) download_file 1080 "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            6) download_file 1440 "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            7) download_file 2160 "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            8) download_file "best" "$VIDEO_DIR" "$VIDEO_NAME" "mp4" ;;
            b) clear; return ;;  # Back
            n) new_url ;;
            e) exit 0 ;;
            *) echo "Invalid choice, try again!" ;;
        esac
    done
}

# music download func
music_download() {
    clear
    while true; do
        echo "[Download Music Options]"
        cat << EOF
1. Mp3
2. Flac
3. Playlist Mp3
4. Playlist Flac
b. Back
n. New url
e. Exit
EOF

        read -n 1 -p "Enter your choice: " choice
	echo ""

        case "$choice" in
            1) download_file "mp3" "$MUSIC_DIR" "$MUSIC_NAME" "mp3" ;;
            2) download_file "flac" "$MUSIC_DIR" "$MUSIC_NAME" "flac" ;;
            3) download_file "playlistmp3" "$PLAYLIST_MUSIC_DIR" "$PLAYLIST_MUSIC_NAME" "mp3" ;;
            4) download_file "playlistflac" "$PLAYLIST_MUSIC_DIR" "$PLAYLIST_MUSIC_NAME" "flac" ;;
            b) clear; return ;;  # Back
            n) new_url ;;
            e) exit 0 ;;
            *) echo "Invalid choice, try again!" ;;
        esac
    done
}

# playlist download func
playlist_download() {
    clear
    Asep5K
    while true; do
        echo "[Video Playlist Options]"
        cat << EOF
1. 240p
2. 360p
3. 480p
4. 720p
5. 1080p
6. 2K (1440p)
7. 4K (2160p)
8. Best Resolution
b. Back
n. New url
e. Exit
EOF

        read -n 1 -p "Enter your choice: " choice
	echo ""

        case "$choice" in
            1) download_file 240 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            2) download_file 360 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            3) download_file 480 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            4) download_file 720 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            5) download_file 1080 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            6) download_file 1440 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            7) download_file 2160 "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            8) download_file "best" "$PLAYLIST_VIDEO_DIR" "$PLAYLIST_VIDEO_NAME" ;;
            b) clear; return ;;  # Back
            n) new_url ;;
            e) exit 0 ;;
            *) echo "Invalid choice, try again!" ;;
        esac
    done
}

# reels download  func
all_platform() {
    clear
    Asep5K
    while true; do
        echo "[Download Options]"
        cat << EOF
1. Download Reels
2. Download Audio
b. Back
n. New url
e. Exit
EOF

        read -n 1 -p "Enter your choice: " choice
	echo ""

        case "$choice" in
            1) download_file "Reels" "$REELS_DIR" "$REELS_NAME" "mp4" ;;
            2) download_file "audio" "$MUSIC_DIR" "$REELS_NAME" "audio" ;;
            b) clear; return ;;  # Back
            n) new_url ;;
            e) exit 0 ;;
            *) echo "Invalid choice, try again!" ;;
        esac
    done
}

# Main menu
main_menu() {
    while true; do
        echo "[Download Options]"
        cat << EOF
1. Reels / Shorts / Clips (Video & Audio)
2. Download Video webm (⚠ Not recommended)
3. Download Video mp4
4. Download Video Playlist
5. Download Music mp3/flac
6. Play Video & Music
7. Check Download Size
n. New url
u. Update yt-dlp
e. Exit
EOF

        read -n 1 -p "Enter your choice: " choice
        echo ""
        case "$choice" in
            1) all_platform ;;
            2) download_videos_webm ;;
            3) download_videos_mp4 ;;
            4) playlist_download ;;
            5) music_download ;;
            6) play ;;
            7) size_check ;;
            n) new_url ;;
            u) yt-dlp_update ;;
            e) exit 0 ;;
        esac
    done
}
# ==========================
# Banner
# ==========================
Asep5K

# ==========================
# Exit trap
# ==========================
trap 'cat << "EOF"
Ｔｈａｎｋｓ  ｆｏｒ  ｕｓｉｎｇ
EOF
exit 0' EXIT

# ==========================
# Init checks
# ==========================
check_internet
check_or_install ffmpeg package_install_ffmpeg 
check_or_install yt-dlp yt-dlp_install 

# ==========================
# URL Input
# ==========================
if [ -z "$URL" ]; then
    new_url
fi

# ==========================
# Main Menu
# ==========================
main_menu
