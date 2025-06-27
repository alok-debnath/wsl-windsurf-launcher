# 🌊 wsl-windsurf-launcher

A one-time setup WSL helper that lets you quickly open files and folders in **WSL Remote** mode using [Windsurf](https://windsurf.com) — all with a single command: wf.

---

## ✨ Features

* Open folders and files in **Windsurf** directly from the WSL terminal.
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
wf                # Opens a new window in Windsurf
wf .              # Opens current directory
wf ./file.txt     # Opens a specific file
wf /path/to/dir   # Opens a specific directory
```

The script automatically encodes the path and launches Windsurf with a `vscode-remote://wsl+<Distro>` URI.

---

## 🛠️ Requirements

* [Windsurf](https://windsurf.com) installed and available in WSL `$PATH`
* WSL2
* Python 3 (for URL encoding)

---

## ❓ Why `wf`?

`wf` = **w**~~indsur~~**f** — it's short, simple, and memorable. A clean CLI alias that fits into your dev workflow.

---

## ⭐ Show Some Love

If this tool helped you, please consider giving this repo a ⭐ to support further development and improvements, and to help others who need it find this tool more easily.

---

## 📄 License

MIT License © [alok-debnath](https://github.com/alok-debnath). You can find a copy of the license text here: [`LICENSE`](LICENSE).
