
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
# URL Input
# ==========================
if [ -z "$URL" ]; then
    new_url
else
    case $URL in
      -c) check_updates && exit 0 ;;
      -u) yt-dlp_update && exit 0 ;;
      -h|--help) show_help && exit 0 ;;
      *)
        if validate_url "$URL"; then
            echo "✔ Valid URL: $URL"
        else
            new_url
        fi
        ;;
    esac
fi

# ==========================
# Main Menu
# ==========================
main_menu
