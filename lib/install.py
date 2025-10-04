
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
