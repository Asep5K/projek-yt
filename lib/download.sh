
# General download function
download_file() {
    clear
    Asep5K
    local type="$1"
    local outdir="$2"
    local name="$3"
    local format="$4"
    local extra_opts='-c --no-warnings --convert-thumbnails none --extractor-retries infinite --restrict-filenames --embed-metadata --embed-thumbnail --exec'
    local cmd='f="{}"; g="${f//_-_/_}"; [ "$f" = "$g" ] || mv "$f" "$g"'
    local architecture=$(uname -m)

    echo "Downloading $type... Please wait..."

    if [ "$format" = "flac" ]; then
        yt-dlp -x --audio-format flac --audio-quality 0 \
          --restrict-filenames --exec 'f="{}"; g="${f//_-_/_}"; [ "$f" = "$g" ] || mv "$f" "$g"' \
          -o "$outdir/$name" "$URL"

    elif [ "$format" = "mp3" ]; then
        yt-dlp -t mp3 $extra_opts 'f="{}"; g="${f//_-_/_}"; [ "$f" = "$g" ] || mv "$f" "$g"' \
        --audio-quality 0 -o "$outdir/$name" "$URL"

    elif [ "$format" = "mp4" ]; then
        if [ "$type" = "best" ] || [ "$type" = "Reels" ]; then
            yt-dlp -f "bv[vcodec^=avc1]+bestaudio / bv[vcodec^=av01]+bestaudio / best" \
            -t "$format" $extra_opts eval $cmd \
            -o "$outdir/$name" "$URL"

        else
            yt-dlp -f "bv[height<=$type][vcodec^=avc1]+bestaudio / bv[height<=$type][vcodec^=av01]+bestaudio" \
            -t "$format" $extra_opts 'f="{}"; g="${f//_-_/_}"; [ "$f" = "$g" ] || mv "$f" "$g"' \
            -o "$outdir/$name" "$URL"
        fi
    else
        echo "✖ Unknown format $format"
    fi

    if [ $? -eq 0 ]; then
        # clear
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
