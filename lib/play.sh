
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
    package_install mpv
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
