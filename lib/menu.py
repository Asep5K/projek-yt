
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
