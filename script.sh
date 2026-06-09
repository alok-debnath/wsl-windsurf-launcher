#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[1;34m'
YELLOW='\033[1;33m'
RESET='\033[0m'

# Known VSCode-based editors: "cmd:Display Name"
KNOWN_EDITORS=(
    "devin-desktop:Devin Desktop"
    "cursor:Cursor"
    "windsurf:Windsurf"
    "vscodium:VSCodium"
)

# --- Editor selection ---
EDITOR_NAME=""
EDITOR_CMD=""
LAUNCHER_CMD=""

for arg in "$@"; do
    case "$arg" in
        --editor=*)  EDITOR_CMD="${arg#--editor=}" ;;
        --cmd=*)     LAUNCHER_CMD="${arg#--cmd=}" ;;
    esac
done

# Resolve display name for --editor= if not already set
if [ -n "$EDITOR_CMD" ] && [ -z "$EDITOR_NAME" ]; then
    for entry in "${KNOWN_EDITORS[@]}"; do
        if [ "${entry%%:*}" = "$EDITOR_CMD" ]; then
            EDITOR_NAME="${entry##*:}"
            break
        fi
    done
    [ -z "$EDITOR_NAME" ] && EDITOR_NAME="$EDITOR_CMD"
fi

if [ -z "$EDITOR_CMD" ]; then
    FOUND_EDITORS=()
    for entry in "${KNOWN_EDITORS[@]}"; do
        if command -v "${entry%%:*}" >/dev/null 2>&1; then
            FOUND_EDITORS+=("$entry")
        fi
    done

    if [ ${#FOUND_EDITORS[@]} -eq 0 ]; then
        echo "ERROR: No supported editor found in PATH. Install one or use --editor=<cmd>." >&2
        exit 1
    elif [ ${#FOUND_EDITORS[@]} -eq 1 ]; then
        EDITOR_CMD="${FOUND_EDITORS[0]%%:*}"
        EDITOR_NAME="${FOUND_EDITORS[0]##*:}"
        echo -e "${GREEN}Auto-detected: ${BLUE}${EDITOR_NAME}${RESET}"
    else
        echo -e "${BLUE}Multiple editors found. Which would you like to set up?${RESET}"
        for i in "${!FOUND_EDITORS[@]}"; do
            echo "  $((i+1))) ${FOUND_EDITORS[$i]##*:}"
        done
        read -rp "Enter choice [1-${#FOUND_EDITORS[@]}]: " choice </dev/tty
        if ! [[ "$choice" =~ ^[0-9]+$ ]] || [ "$choice" -lt 1 ] || [ "$choice" -gt "${#FOUND_EDITORS[@]}" ]; then
            echo "Invalid choice. Exiting." >&2
            exit 1
        fi
        EDITOR_CMD="${FOUND_EDITORS[$((choice-1))]%%:*}"
        EDITOR_NAME="${FOUND_EDITORS[$((choice-1))]##*:}"
    fi
fi

# Validate the chosen editor is installed
if ! command -v "$EDITOR_CMD" >/dev/null 2>&1; then
    echo "ERROR: ${EDITOR_CMD} command not found in PATH" >&2
    exit 1
fi

# --- Command name selection ---
if [ -z "$LAUNCHER_CMD" ]; then
    read -rp "Enter command name to install [default: wf]: " input_cmd </dev/tty
    LAUNCHER_CMD="${input_cmd:-wf}"
fi

if ! [[ "$LAUNCHER_CMD" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "ERROR: Invalid command name '${LAUNCHER_CMD}'. Use only letters, numbers, dashes, and underscores." >&2
    exit 1
fi

while true; do
    if ! [[ "$LAUNCHER_CMD" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "Invalid name. Use only letters, numbers, dashes, and underscores."
        read -rp "Enter command name: " LAUNCHER_CMD </dev/tty
        LAUNCHER_CMD="${LAUNCHER_CMD:-wf}"
        continue
    fi
    existing=$(command -v "$LAUNCHER_CMD" 2>/dev/null)
    if [ -z "$existing" ] || [ "$existing" = "$HOME/.local/bin/$LAUNCHER_CMD" ]; then
        break
    fi
    echo -e "${YELLOW}Warning: '${LAUNCHER_CMD}' already exists at ${existing} and will be overwritten.${RESET}"
    echo "  1) Enter a different name"
    echo "  2) Overwrite '${LAUNCHER_CMD}'"
    echo "  3) Abort"
    read -rp "Choose [1/2/3]: " conflict_choice </dev/tty
    case "$conflict_choice" in
        1)
            read -rp "Enter new command name: " LAUNCHER_CMD </dev/tty
            LAUNCHER_CMD="${LAUNCHER_CMD:-wf}"
            ;;
        2) break ;;
        *) echo "Aborted." >&2; exit 1 ;;
    esac
done

echo -e "${BLUE}=== Setting up WSL ${EDITOR_NAME} Launcher ===${RESET}"

# Create bin directory
mkdir -p ~/.local/bin

# Create launcher
cat > ~/.local/bin/${LAUNCHER_CMD} << EOF
#!/bin/bash

EDITOR_CMD="$EDITOR_CMD"

# Function to check if a socket is stale
is_socket_stale() {
    local socket_path="\$1"

    [ ! -S "\$socket_path" ] && return 1

    if command -v fuser >/dev/null 2>&1; then
        if ! fuser "\$socket_path" >/dev/null 2>&1; then
            return 0
        fi
        return 1
    fi

    if command -v lsof >/dev/null 2>&1; then
        if ! lsof "\$socket_path" >/dev/null 2>&1; then
            return 0
        fi
        return 1
    fi

    if command -v socat >/dev/null 2>&1; then
        if ! timeout 0.1 socat - UNIX-CONNECT:"\$socket_path" </dev/null >/dev/null 2>&1; then
            return 0
        fi
        return 1
    fi

    return 1
}

# Function to clean up stale IPC sockets
cleanup_stale_sockets() {
    local verbose="\${1:-false}"
    local runtime_dir="\${XDG_RUNTIME_DIR:-/run/user/\$(id -u)}"
    local cleaned=0

    if [ ! -d "\$runtime_dir" ]; then
        [ "\$verbose" = "true" ] && echo "Runtime directory not found: \$runtime_dir"
        return 0
    fi

    while IFS= read -r -d '' socket_file; do
        if is_socket_stale "\$socket_file"; then
            rm -f "\$socket_file" 2>/dev/null && cleaned=\$((cleaned + 1))
            [ "\$verbose" = "true" ] && echo "Removed stale socket: \$(basename "\$socket_file")"
        fi
    done < <(find "\$runtime_dir" -maxdepth 1 -name "vscode-ipc-*.sock" -type s -print0 2>/dev/null)

    [ \$cleaned -gt 0 ] && echo "Cleaned up \$cleaned stale IPC socket(s)"
    [ \$cleaned -eq 0 ] && [ "\$verbose" = "true" ] && echo "No stale sockets found"
    return 0
}

if [ "\$1" = "--clean" ] || [ "\$1" = "-c" ]; then
    echo "Cleaning up stale IPC sockets..."
    cleanup_stale_sockets true
    exit 0
fi

WSL_DISTRO=\$(wsl.exe echo \\\$WSL_DISTRO_NAME 2>/dev/null | tr -d '\r')
if [ -z "\$WSL_DISTRO" ]; then
    WSL_DISTRO=\$(grep -oP '(?<=/mnt/wsl/instances/)[^/]*' /proc/self/mountinfo 2>/dev/null | head -n1)
fi

if [ -z "\$WSL_DISTRO" ]; then
    echo "ERROR: Could not detect WSL distro name" >&2
    exit 1
fi

if ! command -v "\$EDITOR_CMD" >/dev/null 2>&1; then
    echo "ERROR: \$EDITOR_CMD command not found in PATH" >&2
    exit 1
fi

cleanup_stale_sockets false

if [ -z "\$1" ]; then
    "\$EDITOR_CMD" "--new-window" "--remote" "wsl+\${WSL_DISTRO}"
    exit 0
else
    TARGET_PATH=\$(readlink -f "\$1" 2>/dev/null || echo "\$1")
    if [ ! -e "\$TARGET_PATH" ]; then
        echo "ERROR: Path does not exist: \$TARGET_PATH" >&2
        exit 1
    fi
    if [ -f "\$TARGET_PATH" ]; then
        URI_SCHEME="file-uri"
    elif [ -d "\$TARGET_PATH" ]; then
        URI_SCHEME="folder-uri"
    else
        echo "ERROR: Unsupported file type: \$TARGET_PATH" >&2
        exit 1
    fi
fi

ENCODED_PATH=\$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "\$TARGET_PATH")
URI="vscode-remote://wsl+\${WSL_DISTRO}\$ENCODED_PATH"

"\$EDITOR_CMD" "--\$URI_SCHEME" "\$URI"
EOF

chmod +x ~/.local/bin/${LAUNCHER_CMD}

# Detect current shell
CURRENT_SHELL=$(basename "$SHELL")
echo -e "${YELLOW}Detected shell: ${BLUE}${CURRENT_SHELL}${RESET}"

MARKER_START="# ====== wsl-launcher ======"
MARKER_END="# ====== end wsl-launcher ======"

# Remove any existing launcher block (any editor name variant, old or new)
remove_launcher_block() {
    local config_file=$1
    sed -i '/# ====== .* Launcher Config ======/,/# ====== End of .* Launcher Config ======/d' "$config_file"
    sed -i "/# ====== wsl-launcher ======/,/# ====== end wsl-launcher ======/d" "$config_file"
}

add_path_to_config() {
    local config_file=$1
    local shell_name=$2
    if [ -f "$config_file" ]; then
        remove_launcher_block "$config_file"
        echo "" >> "$config_file"
        echo "$MARKER_START" >> "$config_file"
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$config_file"
        echo "$MARKER_END" >> "$config_file"
        echo -e "${GREEN}✓ Added ${EDITOR_NAME} launcher to PATH in ${config_file} (${shell_name})${RESET}"
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
        mkdir -p "$(dirname "$fish_config")"
        touch "$fish_config"
        remove_launcher_block "$fish_config"
        echo "" >> "$fish_config"
        echo "$MARKER_START" >> "$fish_config"
        echo "set -gx PATH \$HOME/.local/bin \$PATH" >> "$fish_config"
        echo "$MARKER_END" >> "$fish_config"
        echo -e "${GREEN}✓ Added ${EDITOR_NAME} launcher to PATH in ${fish_config} (fish)${RESET}"
        ;;
    *)
        echo -e "${YELLOW}Shell detection failed or unsupported. Please add ~/.local/bin to PATH manually if needed.${RESET}"
        ;;
esac

echo -e "${GREEN}✓ WSL ${EDITOR_NAME} launcher setup complete!${RESET}"
echo -e "Use: ${BLUE}${LAUNCHER_CMD} /path/to/file_or_folder${RESET}"
case "$CURRENT_SHELL" in
    zsh)  echo -e "Run: ${BLUE}source ~/.zshrc${RESET} or restart terminal." ;;
    bash) echo -e "Run: ${BLUE}source ~/.bashrc${RESET} or restart terminal." ;;
    fish) echo -e "Run: ${BLUE}source ~/.config/fish/config.fish${RESET} or restart terminal." ;;
    *)    echo -e "Restart your terminal to apply changes." ;;
esac

exit 0
