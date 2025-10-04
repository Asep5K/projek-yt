### 🛠️ Installation
### 🐧 On Linux
#### 1. Risky way (system-wide install)
```bash
python3 -m pip install -r requirements.txt --break-system-packages
```
#### 2. Safe way (using virtualenv)
```bash
python3 -m venv venv
source venv/bin/activate
python3 -m pip install -r requirements.txt
```
Don’t forget to edit yt-cli.py and add a shebang pointing to the Python interpreter inside your venv.

### 💻 On Windows
1. Download & install Python from [python.org](https://www.python.org/downloads/)
2. Open PowerShell and run:
```powershell
python -m pip install -r requirements.txt
```
### 📦 Requirements

- Python 3.8+

- ffmpeg
- must be installed and available in PATH

- Packages listed in requirements.txt

### ⚡ Notes

- Using --break-system-packages on Linux may break system Python, so use virtualenv if possible.

- On Windows, make sure Python is added to your PATH during installation.

- Output format & codec can be configured in the code (yt-dlp options).