
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
