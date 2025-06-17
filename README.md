# 🌊 wsl-windsurf-launcher

A WSL helper that lets you quickly open files and folders in **WSL Remote** mode using [Windsurf](https://windsurf.com) with a single command: `wf`.

---

## ✨ Features

* Open folders and files in **Windsurf** directly from the WSL terminal.
* Automatically detects your WSL distro.
* Supports all common shells (`zsh`, `bash`, `fish`).
* Adds a convenient `wf` command to your terminal.

---

## 🚀 Quick Start

1. **Open any folder inside your WSL terminal**

2. **Shallow clone this repository**

   ```bash
   git clone --depth 1 https://github.com/alok-debnath/wsl-windsurf-launcher.git
   ```

3. **Change into the cloned folder**

   ```bash
   cd wsl-windsurf-launcher
   ```

4. **Make the script executable**

   ```bash
   chmod +x script.sh
   ```

5. **Run the installer**

   ```bash
   ./script.sh
   ```

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

If this tool helped you, please consider giving this repo a ⭐
Your support encourages further development and improvements!

---

## 📄 License

MIT License © [alok-debnath](https://github.com/alok-debnath). You can find a copy of the license text here: [`LICENSE`](LICENSE).
