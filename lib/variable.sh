#!/usr/bin/env bash

clear
set -e
URL=$1

# ==========================
# Directories & Detect platform
# ==========================
if [ -d "/sdcard" ]; then
    # Likely Termux / Android
    MUSIC_DIR="/sdcard/Music/%(extractor)s"
    VIDEO_DIR="/sdcard/Videos/%(extractor)s"
    PLAYLIST_MUSIC_DIR="/sdcard/Music/%(playlist_title)s"
    PLAYLIST_VIDEO_DIR="/sdcard/Videos/%(playlist_title)s"
else
    # Likely Linux Desktop
    MUSIC_DIR="$HOME/Music/%(extractor)s"
    VIDEO_DIR="$HOME/Videos/%(extractor)s"
    PLAYLIST_MUSIC_DIR="$HOME/Music/%(playlist_title)s"
    PLAYLIST_VIDEO_DIR="$HOME/Videos/%(playlist_title)s"
fi

# Name
MUSIC_NAME="%(title)s.%(ext)s"
VIDEO_NAME="%(title)s_%(height)s"p".%(ext)s"
REELS_NAME="%(extractor)s_%(id)s.%(ext)s"
PLAYLIST_MUSIC_NAME="%(playlist_index)02d_%(title)s.%(ext)s"
PLAYLIST_VIDEO_NAME="%(playlist)s/%(playlist_index)02d_%(title)s_%(height)s"p".%(ext)s"
