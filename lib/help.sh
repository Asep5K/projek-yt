
show_help() {
  Asep5K
    cat <<EOF
  ${0##*/} - Simple CLI wrapper for yt-dlp with extras
Usage:
  ${0##*/} [OPTIONS]/[URL]

Example:
  ${0##*/} https://youtu.be/7kHxblDGbGw   # Download video/music
  ${0##*/} -c                             # Check yt-dlp updates
  ${0##*/} -u                             # Update yt-dlp

Options:
  -c            Check for yt-dlp updates
  -u            Update yt-dlp
  -h, --help    Show this help message

Note:
  If a URL is provided, it must start with http:// or https://
EOF
}
