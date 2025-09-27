# 🎬 YouTube Downloader & Player (Bash + yad)  

[![Made with Bash](https://img.shields.io/badge/Made%20with-Bash-blue?logo=gnu-bash)](https://www.gnu.org/software/bash/)
[![yt-dlp](https://img.shields.io/badge/yt--dlp-powered-orange)](https://github.com/yt-dlp/yt-dlp)
[![Termux](https://img.shields.io/badge/Termux-supported-brightgreen)](https://termux.com/)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](./LICENSE)

> **Script created by Asep5K**


A lightweight Bash script with **yad menus** to download videos, music, or play content from YouTube. Supports playlists, multiple resolutions, and audio formats (MP3/FLAC).  

🔗 GitHub Repository: https://github.com/Asep5K/projek-yt

---

## ⚡ Features  

- Download videos in multiple resolutions: 240p → 4K, or best available.  
  > ⚠️ Note: I have not tested downloads above 1080p, so I cannot guarantee they work. Testing higher resolutions was not possible due to certain limitations.  
- Download audio only: MP3 or FLAC, single or playlist.  
- Play videos or audio directly with `mpv`.  
- Choose specific video/audio format for download.  
- yad-based interactive menu for easy navigation.  
- Desktop notifications for download/playback progress.  

---

## 🛠️ Requirements  

- `bash`  
- [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) – Download videos and audio from YouTube and other platforms.  
- [`ffmpeg`](https://github.com/FFmpeg/FFmpeg) – Handles video/audio format conversion and merging.  
- [`mpv`](https://github.com/mpv-player/mpv) – Media player for previewing or playing downloaded content.  
- [`yad`](https://github.com/v1cont/yad) – Provides graphical dialog menus for interactive script navigation.  
- [`wget`](https://github.com/wget/wget) – Downloads files.  
- [`notify-send`](https://gitlab.gnome.org/GNOME/libnotify) – Sends desktop notifications for download or playback status.
  
---

## 🚀 Installation & Usage

1. Install dependencies (choose your distro):
...

### Arch Linux  
```bash
sudo pacman -S --needed bash mpv yad wget libnotify python-pipx
pipx install yt-dlp
```
### Debian / Ubuntu
```bash
sudo apt update
sudo apt install bash mpv yad wget libnotify-bin pipx
pipx install yt-dlp
```
### Fedora
```bash
sudo dnf install bash mpv yad wget libnotify pipx
pipx install yt-dlp
```
### openSUSE
```bash
sudo zypper install bash mpv yad wget libnotify-tools pipx
pipx install yt-dlp
```
### Alternative (Manual Install from Source)
- If you don’t want to use `pipx`, you can build [`yt-dlp`](https://github.com/yt-dlp/yt-dlp) from source.

2. Clone the repository:
   ```bash
   git clone https://github.com/Asep5K/projek-yt.git
   cd projek-yt
   chmod +x yt.sh
   ./yt.sh
   ```
- Or, you can copy the script to a directory in your PATH, or bind it to a keybinding for easier access.

## 📱 Termux (CLI Version)

1. Install from Termux package manager:
```bash
  pkg update && pkg upgrade && pkg install yt-dlp ffmpeg
  git clone https://github.com/Asep5K/projek-yt.git
  cp projek-yt/yt-termux.sh $PREFIX/bin/ytd
  chmod +x $PREFIX/bin/ytd
```
- Run the script with a direct URL
```bash
  ytd https://example.com/123456
```
- Or run the interactive menu without a URL
```bash 
  ytd
```
### 🔧 Tip for Linux users running the Termux CLI version

- If you want to reuse the Termux CLI script on Linux, you can:

- Change the download directory variable inside the script (DOWNLOAD_DIR=~/Videos/Downloads), or

- Create a symlink so /sdcard points to your Linux home directory:
```bash
  ln -s ~ /sdcard
```
---

## Notes
The `yt-termux.sh` script will automatically install all required packages and works on all Linux distributions.  
Simply run:

```bash
./yt-termux.sh
```
- The Makefile and build.sh are provided only for building yt-termux.sh.
---

## 🎥 Demo & Screenshots

![Demo](./screenshot/demo.gif)  
![](./screenshot/url.png)  
![](./screenshot/option.png)  
![](./screenshot/music.png)  
![](./screenshot/download.png)  
![](./screenshot/play.png)  
![](./screenshot/log.png)
---

## 🤝 Contributing & Feedback  

This project is still a learning exercise, and I’m new to scripting/programming.  
If you find any bugs, issues, or have suggestions for improvements, please let me know!  

- ⭐ If you like this project, consider giving it a star on GitHub.  
- 🐞 Found a bug? Please open an [issue](../../issues).  
- 💡 Have ideas for new features? Feel free to suggest them.  
- 🔧 Want to help improve the code? Pull requests are always welcome.  

Every bit of feedback or contribution is greatly appreciated. 🙌  
