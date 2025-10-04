
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
