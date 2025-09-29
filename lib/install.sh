# Package installer (cross-distro)
package_install() {
    local package="$1"
    if command -v "$package" >/dev/null 2>&1; then
        echo "✔ $package is already installed: $(command -v "$package")"
        return 0
    fi

    echo "⚠ $package not found! installing..."

    if command -v pkg >/dev/null 2>&1; then
        pkg install -y "$package" 
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm "$package"
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y "$package"
    elif command -v zypper >/dev/null 2>&1; then
        sudo zypper install -y "$package"
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y "$package"
    else
        echo "Error: No supported package manager found."
        echo "Please install $package manually"
        return 1
    fi
}

# Install yt-dlp (latest binary from GitHub)
yt-dlp_install() {
    local dir="$HOME/.local/bin"
    local name="yt-dlp"
    local url="https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp"

    # Download yt-dlp
    if command -v curl >/dev/null 2>&1; then
        mkdir -p "$dir"
        curl -L "$url" -o "$dir/$name"
    elif command -v wget >/dev/null 2>&1; then
        mkdir -p "$dir"
        wget "$url" -O "$dir/$name"
    else 
        echo "Error: curl or wget not found"
        echo "Installing wget..."
        package_install "wget" || return 1
        wget "$url" -O "$dir/$name"
    fi
    
    if [ ! -f "$dir/$name" ]; then
        echo "Download failed!"
        return 1
    fi

    chmod +x "$dir/$name"
    export PATH="$dir:$PATH"

    # Ensure $dir is in PATH
    case ":$PATH:" in
        *":$dir:"*) 
            echo "$dir is already in PATH"
            ;;
        *)
            echo "Adding $dir to PATH..."

            shell_name=$(basename "$SHELL")

            case "$shell_name" in
                bash)
                    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.bashrc"
                    ;;
                zsh)
                    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.zshrc"
                    ;;
                fish)
                    echo "set -U fish_user_paths \$HOME/.local/bin \$fish_user_paths" >> "$HOME/.config/fish/config.fish"
                    ;;
                *)
                    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$HOME/.profile"
                    ;;
            esac

            echo "PATH updated. Please restart your shell or run 'source' on your shell config file."
            ;;
    esac

    echo "✔ yt-dlp installed at $dir/$name"
    echo "Check version with: yt-dlp --version"
}

# Install if missing
check_or_install() {
    local cmd="$1"
    local install_func="$2"

    if ! command -v "$cmd" >/dev/null 2>&1; then
        echo "⚠ $cmd not found! Installing..."
        $install_func
    else
        echo "✔ $cmd is already installed: $(command -v "$cmd")"
    fi
}

# Update yt-dlp
yt-dlp_update() {
	echo "Updating, please wait..."
    if yt-dlp -U; then
        echo "✔ yt-dlp updated successfully"
    else
        echo "✖ Update failed. If you installed yt-dlp via a package manager, use that instead."
    fi
}

# check updates
check_updates() {
    clear
    echo "🔎 Checking yt-dlp updates..."
    current=$(yt-dlp --version)
    latest=$(curl -s https://api.github.com/repos/yt-dlp/yt-dlp/releases/latest \
      | grep '"tag_name":' \
      | cut -d '"' -f4 | sed 's/^v//')

    if [ "$current" != "$latest" ]; then
        echo "Your version: $current"
        echo "New update available: $latest"
    else
        echo "You have the latest version: $current"
    fi
}
