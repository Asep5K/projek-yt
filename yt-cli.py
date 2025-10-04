#!/set/path/to/venv/bin/python3

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

def Asep5K():
    print(r"""
    ___                    ________ __
   /   |  ________  ____  / ____/ //_/
  / /| | / ___/ _ \/ __ \/___ \/ ,<   
 / ___ |(__  )  __/ /_/ /___/ / /| |  
/_/  |_/____/\___/ .___/_____/_/ |_|  
                /_/ """)

paste_url = r"""
   ___  ___   ______________  __  _____  __     __ _________  ____  __
  / _ \/ _ | / __/_  __/ __/ / / / / _ \/ /    / // / __/ _ \/ __/ / /
 / ___/ __ |_\ \  / / / _/  / /_/ / , _/ /__  / _  / _// , _/ _/  /_/ 
/_/  /_/ |_/___/ /_/ /___/  \____/_/|_/____/ /_//_/___/_/|_/___/ (_)
"""

thanks = r"""
Ｔｈａｎｋｓ  ｆｏｒ  ｕｓｉｎｇ"""

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

def ping(host="8.8.8.8"):
    # Fungsi untuk cek apakah host bisa di-ping
    # Default host: 8.8.8.8 (Google DNS)
    if os.name == "nt":  # Windows pakai opsi -n
        cmd = ["ping", "-n", "1", host]
    else:  # Linux / Mac / Termux pakai opsi -c
        cmd = ["ping", "-c", "1", host]
    try:
        subprocess.run(
            cmd,
            check=True,
            stdout=subprocess.DEVNULL,  # buang output normal (stdout)
            stderr=subprocess.DEVNULL   # buang output error (stderr)
        )
        return True   # host bisa diakses
    except subprocess.CalledProcessError:
        return False  # host tidak bisa diakses / gagal ping

def check_version():
    # Menampilkan versi yt-dlp yang terinstall
    clear_terminal() 
    print("yt-dlp version")
    subprocess.run(["yt-dlp", "--version"], check=True)

def yt_dlp_update():
    # Update yt-dlp menggunakan pip
    clear_terminal()
    print("Updating yt-dlp...")
    try:
        subprocess.run(
            [sys.executable, "-m", "pip", "install", "--upgrade", "yt-dlp"], 
            check=True
        )
        print("yt-dlp updated successfully!")  # Berhasil update
    except subprocess.CalledProcessError:
        print("Failed to update yt-dlp.")  # Gagal update
        
def check_yt_dlp_update():
    # Mengecek apakah yt-dlp versi terbaru sudah terpasang
    clear_terminal()

    try:
        # Ambil versi yt-dlp yang sedang terinstall dari pip
        installed = subprocess.check_output(
            [sys.executable, "-m", "pip", "show", "yt-dlp"],
            stderr=subprocess.DEVNULL
        ).decode()
        # Cari baris yang diawali "Version:" lalu ambil nilainya
        installed_version = next(
            (line.split(":")[1].strip() for line in installed.splitlines() if line.startswith("Version:")),
            None
        )
    except Exception:
        installed_version = None  # Kalau gagal, anggap belum ada versi

    # Ambil versi terbaru dari PyPI (via API JSON)
    with urllib.request.urlopen("https://pypi.org/pypi/yt-dlp/json") as resp:
        data = json.load(resp)
        latest_version = data["info"]["version"]

    # Bandingkan versi terinstall dengan versi terbaru
    if installed_version == latest_version:
        print(f"✅ yt-dlp is up to date ({installed_version})")
    else:
        print(f"⚠️ yt-dlp is outdated: installed {installed_version}, latest {latest_version}")
        print("Update yt-dlp? [Y/N]: ", end="", flush=True)

        # Ambil input 1 karakter (tanpa ENTER) pakai getch
        choice = getch().strip().lower()
        print(choice)  # echo pilihan user

        if choice == "y":  # Jika user pilih "y", lakukan update
            yt_dlp_update()
        else:
            return  # Kalau tidak, keluar fungsi

def clear_terminal():
    # Membersihkan layar terminal
    # 'cls' digunakan untuk Windows
    # 'clear' digunakan untuk Linux / MacOS
    os.system('cls' if os.name == 'nt' else 'clear') 

def exit_program():
    # Fungsi untuk keluar dari program
    # Bersihkan terminal dulu, lalu tampilkan pesan terima kasih
    clear_terminal()
    print(f"{BLUE}{thanks}{RESET}")
    sys.exit(0)  # Keluar dengan kode sukses (0)

# Ambil URL dari argumen command-line (jika ada)
# sys.argv[0] adalah nama file script, jadi dicek mulai index 1
cli_url = sys.argv[1] if len(sys.argv) > 1 else None

def get_url(default_url=None):
    # Fungsi untuk mendapatkan URL dari user
    # Bisa pakai URL default (kalau valid), atau minta input manual
    if default_url:
        if re.match(r"^https?://", default_url):  # Validasi apakah dia URL http/https
            return default_url
    while True:
        # Tampilkan pesan instruksi ke user
        print(f"{GREEN}{paste_url}{RESET}")
        url = input(f"{YELLOW}Paste URL (or 'b' to back 'e' to exit): {RESET}").strip()
        clear_terminal()
        
        if url.lower() == "b":  # Kalau user ketik 'b', kembali (return None)
            clear_terminal()
            return None
        elif url.lower() == "e":  # Kalau user ketik 'e', keluar program
            exit_program()
            
        # Cek apakah input cocok dengan pola URL (http/https)
        if re.match(r"^https?://", url):
            return url
        # Kalau bukan URL valid, tampilkan pesan error
        print(f"{RED}Invalid URL, try again!{RESET}")

def check_download_size():
    # Fungsi untuk menampilkan daftar format dan ukuran video
    # Pertama, minta user input URL
    clear_terminal()
    url = get_url()
    # Jalankan yt-dlp dengan opsi '-F' untuk menampilkan semua format
    subprocess.run(["yt-dlp", "-F", url])
    
# Bagian untuk membuat fungsi getch cross-platform (Windows, Linux, macOS, Termux)
# getch = fungsi untuk ambil input satu karakter tanpa harus tekan ENTER

if os.name == "nt":  # Kalau di Windows
    import msvcrt
    def getch():
        return msvcrt.getch().decode("utf-8")  # Ambil 1 char dari keyboard
    
else:  # Kalau di Linux / macOS / Termux
    import tty, termios
    def getch():
        fd = sys.stdin.fileno()  # Dapatkan file descriptor stdin
        old = termios.tcgetattr(fd)  # Simpan pengaturan terminal lama
        try:
            tty.setraw(fd)  # Set terminal ke mode raw (baca input langsung per char)
            ch = sys.stdin.read(1)  # Baca 1 karakter
        finally:
            # Balikin pengaturan terminal ke semula biar gak rusak
            termios.tcsetattr(fd, termios.TCSADRAIN, old)
        return ch

def playing(url, mode="video", quality=None):
    """
    Fungsi untuk memutar video/audio langsung dari URL pakai mpv.
    
    Parameter:
    - url     : string, URL YouTube / link streaming
    - quality : int (opsional), resolusi maksimal video (contoh: 720, 1080)
    - mode    : string, "video" atau "audio"
    """
    if mode == "video":
        # Kalau mode video, cek apakah user tentukan kualitas tertentu
        if quality:
            # Pilih bestvideo sesuai resolusi maksimum + bestaudio
            fmt = f"bestvideo[height<={quality}]+bestaudio"
        else:
            # Kalau tidak, ambil "best" (otomatis best video + audio)
            fmt = "best"
    elif mode == "audio":
        # Mode audio → ambil bestaudio (tanpa video)
        fmt = "bestaudio"
    else:
        # Kalau parameter mode salah
        print("Invalid mode! Use 'video' or 'audio'.")
        return

    try:
        # Jalankan mpv dengan URL dan format yang sudah ditentukan
        subprocess.run(["mpv", url, f"--ytdl-format={fmt}"])
    except FileNotFoundError:
        # Kalau mpv belum terinstall, kasih pesan error
        print("mpv not found! Please install mpv.")

# download mp4 function
def download_video_mp4():
    # Fungsi untuk download video dalam format MP4 dengan berbagai resolusi
    clear_terminal()
    url = get_url(default_url=cli_url)  # ambil URL (pakai argumen CLI kalau ada)
    if url is None:
        return
    while True:
        Asep5K()  # fungsi untuk tampilan banner/branding (mungkin ASCII art)
        print("url:",url)
        print("""[Video Options (MP4)]
1. 240p
2. 360p
3. 480p
4. 720p
5. 1080p
6. 2k (1440p)
7. 4k (2160p)
8. Best Resolution
b. Back
n. New url
e. Exit
""")
        print("Choose option: ", end="", flush=True)
        choice = getch().strip().lower()  # ambil input 1 char (lowercase)
        print(choice) 

        if choice == "n":  # kalau user minta URL baru
            clear_terminal()
            url = get_url()
        
        # Mapping pilihan ke fungsi download (pakai lambda)
        options = {
            "1":lambda: download(url, mode="video", quality=240, fmt="mp4"),
            "2":lambda: download(url, mode="video", quality=360, fmt="mp4"),
            "3":lambda: download(url, mode="video", quality=480, fmt="mp4"),
            "4":lambda: download(url, mode="video", quality=720, fmt="mp4"),
            "5":lambda: download(url, mode="video", quality=1080, fmt="mp4"),
            "6":lambda: download(url, mode="video", quality=1440, fmt="mp4"),
            "7":lambda: download(url, mode="video", quality=2160, fmt="mp4"),
            "8":lambda: download(url, mode="video"),
            "b":lambda: None,   # back (tidak melakukan apa-apa)
            "e":exit_program,   # keluar program
        }

        if choice in options: 
            options[choice]()  # jalankan fungsi sesuai pilihan
            if choice in ["e", "b"]:   # kalau exit/back, keluar loop
                return
        else:
            clear_terminal()
            print("Invalid choice, try again!")
        

# download music function
def music_download():
    # Fungsi untuk download musik (mp3/flac, single atau playlist)
    clear_terminal()
    url = get_url(default_url=cli_url)
    if url is None:
        return
    while True:
        Asep5K()
        print("url:",url)
        print("""[Music Options]
1. Mp3
2. Flac
3. Playlist Mp3
4. Playlist Flac
b. Back
n. New url
e. Exit""")
        print("Choose option: ", end="", flush=True)
        choice = getch().strip().lower()
        print(choice) 

        if choice == "n":
            clear_terminal()
            url = get_url()

        options = {
            "1":lambda: download(url, mode="audio"),        # single mp3
            "2":lambda: download(url, mode="audioflac"),    # single flac
            "3":lambda: download(url, mode="playlistmp3"),  # playlist mp3
            "4":lambda: download(url, mode="playlistflac"), # playlist flac
            "b":lambda: None,
            "e":exit_program,
        }

        if choice in options: 
            options[choice]()
            if choice in ["e", "b"]:
                return
        else:
            clear_terminal()
            print("Invalid choice, try again!")

# playlist download function
def playlist_download():
    # Fungsi untuk download playlist video MP4 dengan resolusi tertentu
    clear_terminal()
    url = get_url(default_url=cli_url)
    if url is None:
        return
    while True:
        Asep5K()
        print("url:",url)
        print("""[Video Playlist Options]
1. 240p
2. 360p
3. 480p
4. 720p
5. 1080p
6. 2K (1440p)
7. 4K (2160p)
8. Best Resolution
b. Back
n. New url
e. Exit""")    
        print("Choose option: ", end="", flush=True)
        choice = getch().strip().lower()
        print(choice) 
        
        if choice == "n":
            clear_terminal()
            url = get_url()
        
        options = {
            "1":lambda: download(url, mode="vidplaylist", quality=240, fmt="mp4"),
            "2":lambda: download(url, mode="vidplaylist", quality=360, fmt="mp4"),
            "3":lambda: download(url, mode="vidplaylist", quality=480, fmt="mp4"),
            "4":lambda: download(url, mode="vidplaylist", quality=720, fmt="mp4"),
            "5":lambda: download(url, mode="vidplaylist", quality=1080, fmt="mp4"),
            "6":lambda: download(url, mode="vidplaylist", quality=1440, fmt="mp4"),
            "7":lambda: download(url, mode="vidplaylist", quality=2160, fmt="mp4"),
            "8":lambda: download(url, mode="vidplaylist"),
            "b":lambda: None,
            "e":exit_program,
        }

        if choice in options: 
            options[choice]()
            if choice in ["e", "b"]:
                return
        else:
            clear_terminal()
            print("Invalid choice, try again!")
            
# play music /video function
def play():
    # Fungsi untuk langsung play audio/video dari URL (tanpa download)
    clear_terminal()
    url = get_url(default_url=cli_url)
    if url is None:
        return
    while True:
        Asep5K()
        print("url:",url)
        print("""[Play Options]
1. Audio
2. 240p
3. 360p
4. 480p
5. 720p
6. 1080p
7. 2K (1440p)
8. 4K (2160p)
9. Best Resolution
n. New url
b. Back
e. Exit""")    
        print("Choose option: ", end="", flush=True)
        choice = getch().strip().lower()
        print(choice) 
        
        if choice == "n":
            clear_terminal()
            url = get_url()
        
        options = {
            "1":lambda: playing(url, mode="audio"),
            "2":lambda: playing(url, mode="video", quality=240),
            "3":lambda: playing(url, mode="video", quality=360),
            "4":lambda: playing(url, mode="video", quality=480),
            "5":lambda: playing(url, mode="video", quality=720),
            "6":lambda: playing(url, mode="video", quality=1080),
            "7":lambda: playing(url, mode="video", quality=1440),
            "8":lambda: playing(url, mode="video", quality=2160),
            "9":lambda: playing(url, mode="video"),
            "b":lambda: None,
            "n":lambda: None,
            "e":exit_program,
        }

        if choice in options: 
            options[choice]()
            if choice in ["e", "b"]:
                return
        else:
            clear_terminal()
            print("Invalid choice, try again!")

# reels download function            
def reels_download():
    # Fungsi untuk download reels/shorts/clips
    clear_terminal()
    url = get_url(default_url=cli_url)
    if url is None:
        return
    while True:
        Asep5K()
        print("url:",url)
        print("""[Download Options]
1. Reels
2. Audio
b. Back
n. New url
e. Exit""")
        print("Choose option: ", end="", flush=True)
        choice = getch().strip().lower()
        print(choice) 
        
        if choice == "n":
            clear_terminal()
            url = get_url()
        
        options = {
            "1": lambda: download(url, mode="reels"),
            "2": lambda: download(url, mode="audio"),
            "n": lambda: None,
            "e": exit_program,
            "b": lambda: None,
        }

        if choice in options:
            options[choice]()
            if choice in ["e", "b"]:
                return
        else:
            clear_terminal()
            print("Invalid choice, try again!")
        
# main menu function
def main_menu():
    # Fungsi utama (menu utama aplikasi)
    clear_terminal()
    while True:
        Asep5K()
        if cli_url is None:
            print(f"url: none")
        else:
            print(f"url: {cli_url}")
        print("""[Available Options]
1. Reels / Shorts / Clips (Video & Audio)
2. Download Video mp4
3. Download Video Playlist
4. Download Music mp3/flac
5. Play Video & Music
6. Check Download Size
c. Check for yt-dlp updates
u. Update yt-dlp
e. Exit""") 
        print("Choose option: ", end="", flush=True)
        choice = getch().strip().lower()
        print(choice) 

        options = {
            "1": reels_download,
            "2": download_video_mp4,
            "3": playlist_download,
            "4": music_download,
            "5": play,
            "6": check_download_size,
            "c": check_yt_dlp_update,
            "u": yt_dlp_update,
            "e": exit_program,
        }

        if choice in options:
            options[choice]()  # panggil fungsi sesuai input
            if choice == "e":  # kalau exit, break loop utama
                break
        else:
            print("Invalid choice, try again!")

if ping():
    main_menu()
else:
    print("Enough internet for today. Touch some grass 🌱")
    sys.exit(1)
            