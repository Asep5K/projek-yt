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
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:$PATH"
vid_dir="$HOME/Videos/Downloads"

if pidof rofi > /dev/null; then
    pkill rofi
fi


# 📥 Input URL
url=$(rofi -dmenu -p "Enter YouTube URL:" -theme "$theme1")

if ! curl -Is https://youtube.com >/dev/null 2>&1; then
    notify-send -i "$f" "❌ Error" "No Internet connection!"
    exit 1
fi

# 🔎 Cek dan validasi URL
if [ -z "$url" ]; then
    exit 0
elif [[ ! "$url" =~ ^https?://(www\.)?(youtube\.com|youtu\.be)/ ]]; then
    notify-send -i "$f" "Invalid URL" "Only YouTube links are allowed!"
    exit 1
fi

# 📌 Menu options
options="Download Videos\nDownload Music\nPlay Music/Videos"
choice=$(echo -e "$options" | rofi -dmenu -p "Select option:" -theme "$theme1")
[ -z "$choice" ] && exit 0

download() {
    download_options="Download 240p\nDownload 360p\nDownload 480p\nDownload 720p\nDownload 1080p\nDownload 2K\nDownload 4K\nDownload 8K\nBest Quality Video\nChoose Resolution\nPlay Music/Videos\nExit"
    download_choice=$(echo -e "$download_options" | rofi -dmenu -p "Select option:" -theme "$theme1")
    [ -z "$download_choice" ] && exit 0
}

play() {
    play_options="Play Music\nPlay 240p\nPlay 360p\nPlay 480p\nPlay 720p\nPlay 1080p\nPlay 2K\nPlay 4K\nPlay 8K\nPlay Best Video\nChoose your options\nDownload Music/Videos\nExit"
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
        notify-send -i "$f" "Downloading..." "Audio MP3"
        yt-dlp -x --audio-format mp3 \
        -o "$outdir/$filename" \
        "$url" && \
        latest_music=$(ls -t "$outdir" | head -n 1) && \
        notify-send -i "$f" "$latest_music" "Download complete"
    elif [ "$1" = "Flac" ]; then
        notify-send -i "$f" "Downloading..." "Audio Flac"
        yt-dlp -x --audio-format flac \
        -o "$outdir/$filename" \
        "$url" && \
        latest_music=$(ls -t "$outdir" | head -n 1) && \
        notify-send -i "$f" "$latest_music" "Download complete"
    elif [ "$1" = "Playlistmp3" ]; then
         notify-send -i "$f" "Downloading Playlist Mp3"
        yt-dlp --continue \
        -f bestaudio -x --audio-format mp3 \
        -o "$outdir/$playlistname" \
        "$url" && \
        latest_music=$(ls -t "$outdir" | head -n 1) && \
        notify-send -i "$f" "$latest_music" "✔ Download Finished"
    else
        notify-send -i "$f" "Downloading Playlist Flac"
        yt-dlp --continue \
        -f bestaudio -x --audio-format flac \
        -o "$outdir/$playlistname" \
        "$url" && \
        latest_music=$(ls -t "$outdir" | head -n 1) && \
        notify-send -i "$f" "$latest_music" "✔ Download Finished"
    fi
}

down() {
    res="$1"
    filename="%(title)s_%(height)sp.%(ext)s"
    mkdir -p "$vid_dir"

    if [ "$res" = "best" ]; then
        notify-send -i "$f" "Downloading..." "Best quality videos"
        yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 \
        -o "$vid_dir/$filename" "$url" && \
        latest_video=$(ls -t "$vid_dir" | head -n 1) && \
        notify-send -i "$f" "✔ Download Finished" "$latest_video saved in $vid_dir"
    else
        notify-send -i "$f" " Downloading..." "${res} auto fallback"
        yt-dlp -f "bv[height<=$res]+bestaudio/best" \
        -o "$vid_dir/$filename" "$url" && \
        latest_video=$(ls -t "$vid_dir" | head -n 1) && \
        notify-send -i "$f" "✔ Download Finished" "$latest_video saved in $vid_dir" 
    fi
}

play_select() {
    res="$1"
    
      if [ "$res" = "best" ]; then
            mpv "$url" & 
            notify-send -i "$f" "Playing best video"
        elif [ "$res" == "Music" ]; then
            mpv --no-video "$url" &
            notify-send -i "$f" "Playing audio"
        else    
            mpv --ytdl-format="bestvideo[height=$res]+bestaudio/best" "$url" &
            notify-send -i "$f" "Playing ${res}p"
      fi
}

choose_mode() {
    mode="$1" # download / play
    notify-send -i "$f" "Fetching..." "Available formats"
    format=$(yt-dlp -F "$url" | awk '/^-/{flag=1; next} flag' | rofi -dmenu -p "Choose format:" -theme "$theme2")
    [ -z "$format" ] && return 0

    format_id=$(awk '{print $1}' <<< "$format")

    if [ "$mode" = "download" ]; then
        mkdir -p "$vid_dir"
        filename="%(title)s_%(height)sp.%(ext)s"
        notify-send -i "$f" "Downloading..." "Format $format_id"
        yt-dlp -f "$format_id+bestaudio/best" \
        -o "$vid_dir/$filename" \
        "$url" && \
        latest_video=$(ls -t "$vid_dir" | head -n 1) && \
        notify-send -i "$f" "✔ Download Finished" "$latest_video saved in $vid_dir" 

    elif [ "$mode" = "play" ]; then
        notify-send -i "$f" "Playing format $format_id"
        mpv --ytdl-format="$format_id+bestaudio/best" "$url" 
    fi
}

if [ -n "$choice" ]; then
    if [ "$choice" = "Download Videos" ]; then
        download
        case "$download_choice" in
            "Download MP3") music "mp3" ;;
            "Download Flac") music "flac" ;;
            "Download 240p") down 240 ;;
            "Download 360p") down 360 ;;
            "Download 480p") down 480 ;;
            "Download 720p") down 720 ;;
            "Download 1080p") down 1080 ;;
            "Download 2K") down 1440 ;;
            "Download 4K") down 2160 ;;
            "Download 8K") down 4320 ;;
            "Best Quality Video") down "best" ;;
            "Choose Resolution") choose_mode "download" ;;
            "Play Music/Videos") play ;;
            "Exit") exit 0 ;;
         esac
    elif [ "$choice" = "Play Music/Videos" ]; then
            play
        case "$play_choice" in
            "Play Music") play_select "Music" ;;
            "Play 240p") play_select 240 ;;
            "Play 360p") play_select 360 ;;
            "Play 480p") play_select 480 ;;
            "Play 720p") play_select 720 ;;
            "Play 1080p") play_select 1080 ;; 
            "Play 2K") play_select 1440 ;;
            "Play 4K") play_select 2160 ;;
            "Play 8K") play_select 4320 ;;
            "Play Best Video") play_select "best" ;;
            "Choose your options") choose_mode "play" ;;
            "Download Music/Videos") download ;;
            "Exit") exit 0 ;;
        esac  
    elif [ "$choice" = "Download Music" ]; then
            music_download
        case "$music_choice" in
            "Download Mp3") music "mp3" ;;
            "Download Playlist Mp3") music "Playlistmp3" ;;
            "Download Flac") music "Flac" ;;
            "Download Playlist Flac") music "Playlistflac";;
            "Exit") exit 0 ;;
        esac

    fi
fi