#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

echo -e "${BLUE}=== Setting up WSL Windsurf Launcher ===${RESET}"

# Create bin directory
mkdir -p ~/.local/bin

# Detect windsurf
WINDSURF_CMD=$(command -v windsurf 2>/dev/null)
if [ -z "$WINDSURF_CMD" ]; then
    echo "ERROR: windsurf command not found in PATH" >&2
    exit 1
fi

# Create wf launcher
cat > ~/.local/bin/wf << 'EOF'
#!/bin/bash

# Detect WSL Distro name
WSL_DISTRO=$(wsl.exe echo \$WSL_DISTRO_NAME 2>/dev/null | tr -d '\r')
if [ -z "$WSL_DISTRO" ]; then
    WSL_DISTRO=$(grep -oP '(?<=/mnt/wsl/instances/)[^/]*' /proc/self/mountinfo 2>/dev/null | head -n1)
fi

if [ -z "$WSL_DISTRO" ]; then
    echo "ERROR: Could not detect WSL distro name" >&2
    exit 1
fi

WINDSURF_CMD=$(command -v windsurf 2>/dev/null)
if [ -z "$WINDSURF_CMD" ]; then
    echo "ERROR: windsurf command not found in PATH" >&2
    exit 1
fi

if [ -z "$1" ]; then
    # No arguments - open a new window in WSL mode
    "$WINDSURF_CMD" "--new-window" "--remote" "wsl+${WSL_DISTRO}"
    exit 0
else
    TARGET_PATH=$(readlink -f "$1" 2>/dev/null || echo "$1")
    if [ ! -e "$TARGET_PATH" ]; then
        echo "ERROR: Path does not exist: $TARGET_PATH" >&2
        exit 1
    fi
    if [ -f "$TARGET_PATH" ]; then
        URI_SCHEME="file-uri"
    elif [ -d "$TARGET_PATH" ]; then
        URI_SCHEME="folder-uri"
    else
        echo "ERROR: Unsupported file type: $TARGET_PATH" >&2
        exit 1
    fi
fi

ENCODED_PATH=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$TARGET_PATH")
URI="vscode-remote://wsl+${WSL_DISTRO}$ENCODED_PATH"

"$WINDSURF_CMD" "--$URI_SCHEME" "$URI"
EOF

chmod +x ~/.local/bin/wf

# Detect current shell
CURRENT_SHELL=$(basename "$SHELL")
echo -e "${YELLOW}Detected shell: ${BLUE}${CURRENT_SHELL}${RESET}"

# Update appropriate shell config
add_path_to_config() {
    local config_file=$1
    local shell_name=$2
    if [ -f "$config_file" ]; then
        if ! grep -Fq 'export PATH="$HOME/.local/bin:$PATH"' "$config_file"; then
            echo "" >> "$config_file"
            echo "# ====== Windsurf Launcher Config ======" >> "$config_file"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$config_file"
            echo "# ====== End of Windsurf Launcher Config ======" >> "$config_file"
            echo -e "${GREEN}✓ Added Windsurf launcher to PATH in ${config_file} (${shell_name})${RESET}"
        else
            echo "${shell_name} configuration already contains PATH update"
        fi
    fi
}

case "$CURRENT_SHELL" in
    zsh)
        add_path_to_config "$HOME/.zshrc" "zsh"
        ;;
    bash)
        add_path_to_config "$HOME/.bashrc" "bash"
        ;;
    fish)
        fish_config="$HOME/.config/fish/config.fish"
        if ! grep -Fq 'set -gx PATH $HOME/.local/bin $PATH' "$fish_config"; then
            mkdir -p "$(dirname "$fish_config")"
            echo "" >> "$fish_config"
            echo "# ====== Windsurf Launcher Config ======" >> "$fish_config"
            echo "set -gx PATH \$HOME/.local/bin \$PATH" >> "$fish_config"
            echo "# ====== End of Windsurf Launcher Config ======" >> "$fish_config"
            echo -e "${GREEN}✓ Added Windsurf launcher to PATH in ${fish_config} (fish)${RESET}"
        else
            echo "fish configuration already contains PATH update"
        fi
        ;;
    *)
        echo -e "${YELLOW}Shell detection failed or unsupported. Please add ~/.local/bin to PATH manually if needed.${RESET}"
        ;;
esac

echo -e "${GREEN}✓ WSL Windsurf launcher setup complete!${RESET}"
echo -e "Use: ${BLUE}wf /path/to/file_or_folder${RESET}"
case "$CURRENT_SHELL" in
    zsh)  echo -e "Run: ${BLUE}source ~/.zshrc${RESET} or restart terminal." ;;
    bash) echo -e "Run: ${BLUE}source ~/.bashrc${RESET} or restart terminal." ;;
    fish) echo -e "Run: ${BLUE}source ~/.config/fish/config.fish${RESET} or restart terminal." ;;
    *)    echo -e "Restart your terminal to apply changes." ;;
esac

exit 0