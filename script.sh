#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

echo -e "${BLUE}=== Setting up WSL Devin Desktop Launcher ===${RESET}"

# Create bin directory
mkdir -p ~/.local/bin

# Detect devin-desktop
DEVIN_DESKTOP_CMD=$(command -v devin-desktop 2>/dev/null)
if [ -z "$DEVIN_DESKTOP_CMD" ]; then
    echo "ERROR: devin-desktop command not found in PATH" >&2
    exit 1
fi

# Create wf launcher
cat > ~/.local/bin/wf << 'EOF'
#!/bin/bash

# Function to check if a socket is stale
is_socket_stale() {
    local socket_path="$1"
    
    # If socket file doesn't exist, it's not stale (already cleaned)
    [ ! -S "$socket_path" ] && return 1
    
    # Try to use fuser to check if socket is in use
    if command -v fuser >/dev/null 2>&1; then
        # fuser returns 0 if processes are using the socket, 1 if not
        if ! fuser "$socket_path" >/dev/null 2>&1; then
            return 0  # Socket is stale
        fi
        return 1  # Socket is active
    fi
    
    # Try to use lsof as fallback
    if command -v lsof >/dev/null 2>&1; then
        # lsof returns 0 if socket is in use
        if ! lsof "$socket_path" >/dev/null 2>&1; then
            return 0  # Socket is stale
        fi
        return 1  # Socket is active
    fi
    
    # Last resort: try to connect to the socket using socat if available
    if command -v socat >/dev/null 2>&1; then
        # Connection failure indicates socket is stale
        if ! timeout 0.1 socat - UNIX-CONNECT:"$socket_path" </dev/null >/dev/null 2>&1; then
            return 0  # Connection failed, socket is stale
        fi
        return 1  # Connection succeeded, socket is active
    fi
    
    # If no tools available, assume socket might be active (conservative approach)
    return 1
}

# Function to clean up stale IPC sockets
cleanup_stale_sockets() {
    local verbose="${1:-false}"
    local runtime_dir="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
    local cleaned=0
    
    if [ ! -d "$runtime_dir" ]; then
        [ "$verbose" = "true" ] && echo "Runtime directory not found: $runtime_dir"
        return 0
    fi
    
    # Find all vscode-ipc-*.sock files
    while IFS= read -r -d '' socket_file; do
        if is_socket_stale "$socket_file"; then
            rm -f "$socket_file" 2>/dev/null
            if [ $? -eq 0 ]; then
                cleaned=$((cleaned + 1))
                [ "$verbose" = "true" ] && echo "Removed stale socket: $(basename "$socket_file")"
            fi
        fi
    done < <(find "$runtime_dir" -maxdepth 1 -name "vscode-ipc-*.sock" -type s -print0 2>/dev/null)
    
    if [ $cleaned -gt 0 ]; then
        echo "Cleaned up $cleaned stale IPC socket(s)"
    elif [ "$verbose" = "true" ]; then
        echo "No stale sockets found"
    fi
    
    return 0
}

# Handle --clean or -c flag
if [ "$1" = "--clean" ] || [ "$1" = "-c" ]; then
    echo "Cleaning up stale IPC sockets..."
    cleanup_stale_sockets true
    exit 0
fi

# Detect WSL Distro name
WSL_DISTRO=$(wsl.exe echo \$WSL_DISTRO_NAME 2>/dev/null | tr -d '\r')
if [ -z "$WSL_DISTRO" ]; then
    WSL_DISTRO=$(grep -oP '(?<=/mnt/wsl/instances/)[^/]*' /proc/self/mountinfo 2>/dev/null | head -n1)
fi

if [ -z "$WSL_DISTRO" ]; then
    echo "ERROR: Could not detect WSL distro name" >&2
    exit 1
fi

DEVIN_DESKTOP_CMD=$(command -v devin-desktop 2>/dev/null)
if [ -z "$DEVIN_DESKTOP_CMD" ]; then
    echo "ERROR: devin-desktop command not found in PATH" >&2
    exit 1
fi

# Automatically clean up stale sockets before launching
cleanup_stale_sockets false

if [ -z "$1" ]; then
    # No arguments - open a new window in WSL mode
    "$DEVIN_DESKTOP_CMD" "--new-window" "--remote" "wsl+${WSL_DISTRO}"
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

"$DEVIN_DESKTOP_CMD" "--$URI_SCHEME" "$URI"
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
            echo "# ====== Devin Desktop Launcher Config ======" >> "$config_file"
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$config_file"
            echo "# ====== End of Devin Desktop Launcher Config ======" >> "$config_file"
            echo -e "${GREEN}✓ Added Devin Desktop launcher to PATH in ${config_file} (${shell_name})${RESET}"
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
        if ! grep -Fq '# ====== Devin Desktop Launcher Config ======' "$fish_config" 2>/dev/null; then
            mkdir -p "$(dirname "$fish_config")"
            echo "" >> "$fish_config"
            echo "# ====== Devin Desktop Launcher Config ======" >> "$fish_config"
            echo "set -gx PATH \$HOME/.local/bin \$PATH" >> "$fish_config"
            echo "# ====== End of Devin Desktop Launcher Config ======" >> "$fish_config"
            echo -e "${GREEN}✓ Added Devin Desktop launcher to PATH in ${fish_config} (fish)${RESET}"
        else
            echo "fish configuration already contains PATH update"
        fi
        ;;
    *)
        echo -e "${YELLOW}Shell detection failed or unsupported. Please add ~/.local/bin to PATH manually if needed.${RESET}"
        ;;
esac

echo -e "${GREEN}✓ WSL Devin Desktop launcher setup complete!${RESET}"
echo -e "Use: ${BLUE}wf /path/to/file_or_folder${RESET}"
case "$CURRENT_SHELL" in
    zsh)  echo -e "Run: ${BLUE}source ~/.zshrc${RESET} or restart terminal." ;;
    bash) echo -e "Run: ${BLUE}source ~/.bashrc${RESET} or restart terminal." ;;
    fish) echo -e "Run: ${BLUE}source ~/.config/fish/config.fish${RESET} or restart terminal." ;;
    *)    echo -e "Restart your terminal to apply changes." ;;
esac

exit 0