# 🌊 wsl-windsurf-launcher

A one-time setup WSL helper that lets you quickly open files and folders in **WSL Remote** mode from any VSCode-based editor.

Supports **Devin Desktop**, **Cursor**, **Windsurf**, **VS Code**, **VS Code Insiders**, **VSCodium**, or any other VSCode-based editor via `--editor=<cmd>`.

> **Note:** This tool was originally built for Windsurf only, then expanded to support Devin Desktop (after the [June 2026 rebrand](https://devin.ai/blog/windsurf-is-now-devin-desktop/)), and eventually generalized to work with any VSCode-based editor.

---

## ✨ Features

* Open folders and files in any VSCode-based editor directly from the WSL terminal.
* Automatically detects your WSL distro.
* Supports all common shells (`zsh`, `bash`, `fish`).
* Adds a convenient launcher command to your terminal (default: `wf`, customizable).

---

## 🚀 Installation

Run this single command in your WSL terminal:

```bash
curl -sSL https://raw.githubusercontent.com/alok-debnath/wsl-windsurf-launcher/main/script.sh | bash
```

Or if you prefer wget:

```bash
wget -qO- https://raw.githubusercontent.com/alok-debnath/wsl-windsurf-launcher/main/script.sh | bash
```

You can pass flags to skip prompts:

```bash
# Force a specific editor
curl -sSL https://raw.githubusercontent.com/alok-debnath/wsl-windsurf-launcher/main/script.sh | bash -s -- --editor=cursor
curl -sSL https://raw.githubusercontent.com/alok-debnath/wsl-windsurf-launcher/main/script.sh | bash -s -- --editor=code

# With a custom command name
curl -sSL https://raw.githubusercontent.com/alok-debnath/wsl-windsurf-launcher/main/script.sh | bash -s -- --editor=cursor --cmd=cs
```

By default the launcher installs as `wf`, but you can choose any name. The script checks for conflicts before confirming your choice.

> After installation, restart your terminal or run:
>
> * `source ~/.zshrc` (for zsh)
> * `source ~/.bashrc` (for bash)
> * `source ~/.config/fish/config.fish` (for fish)

---

## 🧪 Usage

```bash
<cmd>                # Opens a new window in your configured editor
<cmd> .              # Opens current directory
<cmd> ./file.txt     # Opens a specific file
<cmd> /path/to/dir   # Opens a specific directory
<cmd> --clean        # Manually clean up stale IPC sockets
<cmd> -c             # Short form of --clean
```

The script automatically encodes the path and launches your editor with a `vscode-remote://wsl+<Distro>` URI.

### Automatic Socket Cleanup

The launcher automatically detects and cleans up stale IPC socket files (leftover from crashed or force-killed editor instances) before launching. This prevents connection errors like "Error: connect ENOENT /run/user/1000/vscode-ipc-*.sock".

You can also manually trigger cleanup using `<cmd> --clean` or `<cmd> -c`.

---

## 🛠️ Requirements

* A VSCode-based editor installed and available in WSL `$PATH` (Devin Desktop, Cursor, Windsurf, VS Code, VSCodium, etc.)
* WSL2
* Python 3 (for URL encoding)

---

## ❓ Why `wf`?

`wf` originated as a shorthand for **w**~~indsur~~**f** — the former name of the editor. It's short, simple, and memorable. The name stuck even after the rebrand to Devin Desktop.

---

## ⭐ Show Some Love

If this tool helped you, please consider giving this repo a ⭐ to support further development and improvements, and to help others who need it find this tool more easily.

---

## 📄 License

MIT License © [alok-debnath](https://github.com/alok-debnath). You can find a copy of the license text here: [`LICENSE`](LICENSE).
