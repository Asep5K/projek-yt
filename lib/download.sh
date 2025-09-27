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
