#!/usr/bin/env bash

clear
set -euo pipefail
URL=$1

# ==========================
# Directories & Detect platform
# ==========================
if [ -d "/sdcard" ]; then
    # Likely Termux / Android
    VIDEO_DIR="/sdcard/Videos/Downloads"
    MUSIC_DIR="/sdcard/Music/Downloads"
else
    # Likely Linux Desktop
    VIDEO_DIR="$HOME/Videos/Downloads"
    MUSIC_DIR="$HOME/Music/Downloads"
fi

# Name
MUSIC_NAME="%(artist)s - %(title)s.%(ext)s"
PLAYLIST_MUSIC_NAME="%(playlist_index)02d - %(title)s.%(ext)s"
PLAYLIST_MUSIC_DIR="$MUSIC_DIR/%(playlist_title)s"
VIDEO_NAME="%(title)s_%(height)sp.%(ext)s"
PLAYLIST_VIDEO_NAME="%(playlist_index)02d - %(title)s_%(height)s"p".%(ext)s"
PLAYLIST_VIDEO_DIR="$VIDEO_DIR/%(playlist_title)s"
REELS_DIR="$VIDEO_DIR/Reels"
REELS_NAME="%(extractor)s_%(id)s.%(ext)s"
