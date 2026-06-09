# 🌊 wsl-editor-launcher

A one-time setup WSL helper that lets you quickly open files and folders in **WSL Remote** mode from any VSCode-based editor.

Supports **Devin Desktop**, **Cursor**, **Windsurf**, **VS Code**, **VS Code Insiders**, **VSCodium**, or any other VSCode-based editor via `--editor=<cmd>`.

---

## ✨ Features

* Open folders and files in any VSCode-based editor directly from the WSL terminal.
* Automatically detects your WSL distro.
* Supports all common shells (`zsh`, `bash`, `fish`).
* Adds a convenient launcher command to your terminal (default: `wf`, customizable).
* Supports clean uninstall — removes all installed launcher commands and shell config entries.

---

## 🛠️ Requirements

* A VSCode-based editor installed and available in WSL `$PATH` (Devin Desktop, Cursor, Windsurf, VS Code, VSCodium, etc.)
* WSL2
* Python 3 (for URL encoding)

---

## 🚀 Installation

Run this single command in your WSL terminal:

```bash
curl -sSL https://raw.githubusercontent.com/alok-debnath/wsl-editor-launcher/main/script.sh | bash
```

Or if you prefer wget:

```bash
wget -qO- https://raw.githubusercontent.com/alok-debnath/wsl-editor-launcher/main/script.sh | bash
```

You can pass flags to skip prompts:

```bash
# Force a specific editor
curl -sSL https://raw.githubusercontent.com/alok-debnath/wsl-editor-launcher/main/script.sh | bash -s -- --editor=cursor
curl -sSL https://raw.githubusercontent.com/alok-debnath/wsl-editor-launcher/main/script.sh | bash -s -- --editor=code

# With a custom command name
curl -sSL https://raw.githubusercontent.com/alok-debnath/wsl-editor-launcher/main/script.sh | bash -s -- --editor=cursor --cmd=cs
```

By default the launcher installs as `wf`, but you can choose any name. The script checks for conflicts before confirming your choice.

> After installation, restart your terminal or run:
>
> * `source ~/.zshrc` (for zsh)
> * `source ~/.bashrc` (for bash)
> * `source ~/.config/fish/config.fish` (for fish)

---

## 💻 Usage

```bash
<cmd>                # Opens a new window in your configured editor
<cmd> .              # Opens current directory
<cmd> ./file.txt     # Opens a specific file
<cmd> /path/to/dir   # Opens a specific directory
<cmd> --clean        # Manually clean up stale IPC sockets
```

The script automatically encodes the path and launches your editor with a `vscode-remote://wsl+<Distro>` URI.

The launcher also automatically cleans up stale IPC socket files before each launch (leftover from crashed or force-killed editor instances), preventing errors like `Error: connect ENOENT /run/user/1000/vscode-ipc-*.sock`.

---

## ❓ Why `wf`?

`wf` originated as a shorthand for **w**~~indsur~~**f** — this tool was originally built specifically for Windsurf, and `wf` was a natural, short command for it. As the tool expanded to support all VSCode-based editors, the default stayed `wf` since it was already familiar to existing users. You can always choose your own command name during setup.

---

## 🗑️ Uninstall

To remove all installed launcher commands and clean up shell config entries:

```bash
curl -sSL https://raw.githubusercontent.com/alok-debnath/wsl-editor-launcher/main/script.sh | bash -s -- --uninstall
```

This will:
* Detect all launcher commands installed by this tool in `~/.local/bin`
* Prompt for confirmation before removing them
* Strip the PATH block from `~/.zshrc`, `~/.bashrc`, and `~/.config/fish/config.fish`

---

## ⭐ Show Some Love

If this tool helped you, please consider giving this repo a ⭐ to support further development and improvements, and to help others who need it find this tool more easily.

---

## 📄 License

MIT License © [alok-debnath](https://github.com/alok-debnath). You can find a copy of the license text here: [`LICENSE`](LICENSE).
