# 🌊 wsl-windsurf-launcher

A one-time setup WSL helper that lets you quickly open files and folders in **WSL Remote** mode using [Devin Desktop](https://devin.ai/download) — all with a single command: `wf`.

> **Note:** Windsurf was rebranded to **Devin Desktop** in June 2026. See the [announcement](https://devin.ai/blog/windsurf-is-now-devin-desktop/) for details. This script has been updated accordingly and now targets the `devin-desktop` binary.

---

## ✨ Features

* Open folders and files in **Devin Desktop** directly from the WSL terminal.
* Automatically detects your WSL distro.
* Supports all common shells (`zsh`, `bash`, `fish`).
* Adds a convenient `wf` command to your terminal.

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

That's it! The script will handle everything automatically.

> After installation, restart your terminal or run:
>
> * `source ~/.zshrc` (for zsh)
> * `source ~/.bashrc` (for bash)
> * `source ~/.config/fish/config.fish` (for fish)

---

## 🧪 Usage

```bash
wf                # Opens a new window in Devin Desktop
wf .              # Opens current directory
wf ./file.txt     # Opens a specific file
wf /path/to/dir   # Opens a specific directory
wf --clean        # Manually clean up stale IPC sockets
wf -c             # Short form of --clean
```

The script automatically encodes the path and launches Devin Desktop with a `vscode-remote://wsl+<Distro>` URI.

### Automatic Socket Cleanup

The launcher automatically detects and cleans up stale IPC socket files (leftover from crashed or force-killed Devin Desktop instances) before launching. This prevents connection errors like "Error: connect ENOENT /run/user/1000/vscode-ipc-*.sock".

You can also manually trigger cleanup using `wf --clean` or `wf -c`.

---

## 🛠️ Requirements

* [Devin Desktop](https://devin.ai/download) installed and available in WSL `$PATH`
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
