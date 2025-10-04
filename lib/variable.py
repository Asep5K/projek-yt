#!/home/iuno/projct-python/yt-py/.venv/bin/python3

import re
import os
import sys
import json
import signal
import platform
import subprocess
import urllib.request
from pathlib import Path
from yt_dlp import YoutubeDL

# ANSI color codes
BLUE = "\033[34m"
GREEN = "\033[32m"
YELLOW = "\033[33m"
RED = "\033[31m"
RESET = "\033[0m"

system = platform.system()
if system == "Linux":
    # Termux pakai /sdcard, desktop pakai home folder
    if Path("/sdcard").exists():  # asumsi Termux
        MUSIC_DIR = Path("/sdcard/Music")
        VIDEO_DIR = Path("/sdcard/Videos")
    else:  # Linux desktop
        MUSIC_DIR = Path.home() / "Music"
        VIDEO_DIR = Path.home() / "Videos"
elif system == "Windows":
    MUSIC_DIR = Path.home() / "Music"
    VIDEO_DIR = Path.home() / "Videos"
else:  # macOS & lain-lain
    MUSIC_DIR = Path.home() / "Music"
    VIDEO_DIR = Path.home() / "Videos"

# Buat folder kalau belum ada
for folder in (MUSIC_DIR, VIDEO_DIR):
    folder.mkdir(parents=True, exist_ok=True)

    

def handle_sigint(sig, frame):
    print("\n[!] Program interrupted by user.")
    print(f"{GREEN}{thanks}{RESET}")
    sys.exit(0)

signal.signal(signal.SIGINT, handle_sigint)
