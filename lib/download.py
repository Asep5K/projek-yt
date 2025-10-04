
global_options = {
    "warn_when_outdated": True,
    "restrictfilenames": True,
    "continuedl": True,
    "writethumbnail": True,
    "convert-thumbnails": "jpg",
    "extractor_retries": float("inf"),
    "no_warnings": True,
}

def merge_options(global_options, ydl_opts):
    opts = global_options.copy()
    opts.update(ydl_opts)
    return opts

def download(url, mode="video", quality=None, fmt=None):
    # Mode: Video (single video)
    # Lokasi simpan: ~/Videos/<extractor>/<judul>_<resolusi>.mp4
    if mode == "video":
        ydl_opts = {
            "format": f"bv[height={quality}][vcodec^=avc1][ext={fmt}]+ba/best" if quality else f"bv[vcodec^=avc1][ext={fmt}]/best",
            "outtmpl": str(VIDEO_DIR / "%(extractor)s" / "%(title)s_%(height)sp.%(ext)s"),
            "noplaylist": True,
            "merge_output_format": "mp4/webm/mkv/",
            "final_ext": "mp4",
            "postprocessors": [
                {"key": "FFmpegMetadata"},
                {"key": "EmbedThumbnail"},
            ],
        }

    # Mode: Video Playlist
    # Lokasi simpan: ~/Videos/<playlist_title>/<index>_<judul>_<resolusi>.mp4
    elif mode == "vidplaylist":
        ydl_opts = {
            "format": f"bv[height={quality}][vcodec^=avc1][ext={fmt}]+ba/best" if quality else f"bv[vcodec^=avc1][ext={fmt}]/best",
            "outtmpl": str(VIDEO_DIR / "%(playlist_title)s" / "%(playlist_index)02d_%(title)s_%(height)sp.%(ext)s"),
            "final_ext": "mp4",
            "ignoreerrors": True,
            "merge_output_format": "mp4/mkv/webm",
            "postprocessors": [
                {"key": "FFmpegMetadata"},
                {"key": "EmbedThumbnail"},
            ],
        }

    # Mode: Audio (single MP3)
    # Lokasi simpan: ~/Music/<extractor>/<artist>_<judul>.mp3
    elif mode == "audio":
        ydl_opts = {
            "format": "bestaudio/best",
            "outtmpl": str(MUSIC_DIR / "%(extractor)s" / "%(artist)s_%(title)s.%(ext)s"),
            "final_ext": "mp3",
            "noplaylist": True,
            "outtmpl_na_placeholder": "",
            "postprocessors": [
                {"key": "FFmpegExtractAudio",
                "preferredcodec": "mp3",
                "preferredquality": "0",
            },
                {"key": "EmbedThumbnail"},
                {"key": "FFmpegMetadata"},
            ],
        }

    # Mode: Audio (single FLAC)
    # Lokasi simpan: ~/Music/<extractor>/<judul>.flac
    elif mode == "audioflac":
        ydl_opts = {
            "format": "bestaudio/best",
            "outtmpl": str(MUSIC_DIR / "%(extractor)s" / "%(title)s.%(ext)s"),
            "final_ext": "flac",
            "noplaylist": True,
            "postprocessors": [
                {"key": "FFmpegExtractAudio",
                "preferredcodec": "flac",
                "preferredquality": "0",
            },
                {"key": "EmbedThumbnail"},
                {"key": "FFmpegMetadata"},
            ],
        }

    # Mode: Playlist FLAC
    # Lokasi simpan: ~/Music/<playlist_title>/<index>_<judul>.flac
    elif mode == "playlistflac":
        ydl_opts = {
            "format": "bestaudio/best",
            "outtmpl": str(MUSIC_DIR / "%(playlist_title)s" / "%(playlist_index)02d_%(title)s.%(ext)s"),
            "final_ext": "flac",
            "noplaylist": False,
            "postprocessors": [
                {"key": "FFmpegExtractAudio",
                "preferredcodec": "flac",
                "preferredquality": "0",
            },
                {"key": "EmbedThumbnail"},
                {"key": "FFmpegMetadata"},
            ],
        }

    # Mode: Playlist MP3
    # Lokasi simpan: ~/Music/<playlist_title>/<index>_<judul>.mp3
    elif mode == "playlistmp3":
        ydl_opts = {
            "format": "bestaudio/best",
            "outtmpl": str(MUSIC_DIR / "%(playlist_title)s" / "%(playlist_index)02d_%(title)s.%(ext)s"),
            "final_ext": "mp3",
            "noplaylist": False,
            "ignoreerrors": True,
            "postprocessors": [
                {"key": "FFmpegExtractAudio",
                "preferredcodec": "mp3",
                "preferredquality": "0",
            },
                {"key": "EmbedThumbnail"},
                {"key": "FFmpegMetadata"},
            ],
        }

    # Mode: Reels (Instagram/TikTok/Shorts)
    # Lokasi simpan: ~/Videos/<extractor>/<extractor>_<id>.mp4
    elif mode == "reels":
        ydl_opts = {
            "format": "best",
            "outtmpl": str(VIDEO_DIR / "%(extractor)s" / "%(extractor)s_%(id)s.%(ext)s"),
            "final_ext": "mp4",
            "noplaylist": True,
            "merge_output_format": "mp4/webm/mkv",
            "postprocessors": [
                {"key": "EmbedThumbnail"},
                {"key": "FFmpegMetadata"},
            ],
        }

    # Mode: Invalid
    else:
        print(f"{RED}Invalid mode!{RESET}")
        return

    # Gabungkan opsi global dengan opsi per-mode
    option = merge_options(global_options, ydl_opts)

    # Eksekusi download
    with YoutubeDL(option) as ydl:
        ydl.download([url])
