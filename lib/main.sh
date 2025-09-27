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
