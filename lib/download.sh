# General download function
download_file() {
    local type="$1"
    local outdir="$2"
    local name="$3"
    local format="$4"
    local extra_opts="--restrict-filenames --embed-metadata --embed-thumbnail"

    echo "Downloading $type... Please wait..."

    if [ "$format" = "flac" ]; then
        yt-dlp -x --audio-format flac --audio-quality 0 \
        --restrict-filenames --embed-thumbnail -o "$outdir/$name" "$URL"

    elif [ "$format" = "mp3" ] || [ "$format" = "audio" ]; then
        yt-dlp -t mp3 --audio-quality 0 \
        $extra_opts -o "$outdir/$name" "$URL" 

    elif [ "$format" = "mp4" ]; then
        if [ "$type" = "best" ] || [ "$type" = "Reels" ]; then
            yt-dlp -f "bv[vcodec^=avc1]+bestaudio / bv[vcodec^=av01]+bestaudio / best" \
            -t "$format" $extra_opts -o "$outdir/$name" "$URL"
        
        else
            yt-dlp -f "bv[height<=$type][vcodec^=avc1]+bestaudio / bv[height<=$type][vcodec^=av01]+bestaudio" \
                -t "$format" $extra_opts -o "$outdir/$name" "$URL"
        fi
    else
        echo "✖ Unknown format $format"
    fi

    if [ $? -eq 0 ]; then
        echo "✔ Download finished."
    else
        echo "✖ Download Failed. Check the URL or network."
    fi
}

# Show available formats/size
size_check() {
    clear
    Asep5K
    yt-dlp -F "$URL"
}
