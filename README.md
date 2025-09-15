# 🎬 YouTube Downloader & Player (Bash + Rofi)  

> **Script created by Asep5K**


A lightweight Bash script with **Rofi menus** to download videos, music, or play content from YouTube. Supports playlists, multiple resolutions, and audio formats (MP3/FLAC).  

🔗 GitHub Repository: https://github.com/Asep5K/projekbashshell

---

## ⚡ Features  

- Download videos in multiple resolutions: 240p → 8K, or best available.  
  > ⚠️ Note: I have not tested downloads above 1080p, so I cannot guarantee they work. Testing higher resolutions was not possible due to certain limitations.  
- Download audio only: MP3 or FLAC, single or playlist.  
- Play videos or audio directly with `mpv`.  
- Choose specific video/audio format for download.  
- Rofi-based interactive menu for easy navigation.  
- Desktop notifications for download/playback progress.  

---

## 🛠️ Requirements  

- `bash`  
- `yt-dlp`  
- `mpv`  
- `rofi`  
- `curl` (for connectivity check)  
- `notify-send` (for desktop notifications)  

---

## 🚀 Installation & Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/Asep5K/projekbashshell.git
   cd projekbashshell
   chmod +x yt.sh
   ./yt.sh
   ```


## 📸 Screenshots

![](./screenshot/Url.png)  
![](./screenshot/Option.png)  
![](./screenshot/Music.png)  
![](./screenshot/Download.png)  
![](./screenshot/Play.png)  

---