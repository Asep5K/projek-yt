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
