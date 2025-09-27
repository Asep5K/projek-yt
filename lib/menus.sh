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
1. Reels
2. Audio
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
2. Download Video mp4
3. Download Video Playlist
4. Download Music mp3/flac
5. Play Video & Music
6. Check Download Size
n. New url
c. Check for yt-dlp updates
u. Update yt-dlp
e. Exit
EOF

        read -n 1 -p "Enter your choice: " choice
        echo ""
        case "$choice" in
            1) all_platform ;;
            2) download_videos_mp4 ;;
            3) playlist_download ;;
            4) music_download ;;
            5) play ;;
            6) size_check ;;
            n) new_url ;;
            c) check_updates ;;
            u) yt-dlp_update ;;
            e) exit 0 ;;
        esac
    done
}
