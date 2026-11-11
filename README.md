# Nyxora

A minimal, keyboard-first desktop configuration built around **AwesomeWM for X11**. Nyxora is designed to provide a clean, modular and distraction-free environment focused on productivity and coding.

Created and maintained by **[YargamCR](https://github.com/YargamCR)**.

## Features

- Modular AwesomeWM configuration organized into `core`, `modules`, `widgets` and `themes`.
- Minimal left-side vertical bar.
- Five workspaces.
- Rofi application, run and window launcher.
- Alacritty terminal configuration.
- Picom compositor configuration.
- Dark and light themes for AwesomeWM and Rofi.
- Theme switcher and system checker.
- Backup-aware installer and uninstaller.

## Supported systems

- Arch Linux
- CachyOS
- Fedora

Nyxora targets **X11, not Wayland**.

Required applications:

- AwesomeWM
- Rofi
- Alacritty
- Picom

The dependency installer also installs JetBrainsMono Nerd Font and optional desktop utilities such as `feh` and `network-manager-applet`.

**Desktop compatibility:** Nyxora is an independent desktop configuration. It does not replace KDE Plasma, modify your display manager or change your current login session. You can keep KDE Plasma and use Nyxora as a separate X11 session.

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/YargamCR/Nyxora.git
cd Nyxora
```

### 2. Make the scripts executable

```bash
chmod +x install.sh uninstall.sh scripts/*
```

### 3. Install dependencies

For Arch Linux, CachyOS or Fedora:

```bash
./install.sh --install-deps
```

The installer automatically detects `pacman`, `dnf5` or `dnf`.

If the required applications are already installed, run:

```bash
./install.sh
```

Without `--install-deps`, the installer does not invoke a package manager.

## Themes

Switch between the available themes:

```bash
nyxora-theme dark
nyxora-theme light
```

The theme switcher updates the AwesomeWM and Rofi themes.

## Commands

Check the configuration and required applications:

```bash
nyxora-check
```

Validate the AwesomeWM configuration:

```bash
awesome -k
```

If `~/.local/bin` is not in Fish's PATH:

```fish
fish_add_path ~/.local/bin
```

## Keybindings

| Shortcut | Action |
|---|---|
| `Super + Enter` | Open Alacritty |
| `Super + D` | Application launcher |
| `Super + R` | Run command |
| `Super + S` | Show keybindings |
| `Super + 1..5` | Switch workspace |
| `Super + Shift + 1..5` | Move focused window to workspace |
| `Super + J / K` | Focus next / previous window |
| `Super + Space` | Next layout |
| `Super + Shift + Space` | Previous layout |
| `Super + Ctrl + Space` | Toggle floating window |
| `Super + N` | Minimize focused window |
| `Super + M` | Maximize focused window |
| `Super + Ctrl + N` | Focus next screen |
| `Super + H / L` | Shrink / grow master area |
| `Super + F` | Toggle fullscreen |
| `Super + Shift + C` | Close window |
| `Super + Shift + T` | Dark theme |
| `Super + Ctrl + T` | Light theme |
| `Super + Ctrl + R` | Restart AwesomeWM |
| `Super + Shift + Q` | Quit AwesomeWM |

## Backups and uninstall

Nyxora preserves the configurations that existed before its first installation.

Original configurations are stored in:

```text
~/.local/share/nyxora/installation/originals/
```

The installation manifest is stored alongside them. Reinstalling Nyxora does not overwrite these original backups.

To uninstall:

```bash
./uninstall.sh
```

The uninstaller asks for confirmation before making changes. It:

- Saves the current configurations in an uninstall snapshot.
- Restores configurations that existed before the original installation.
- Removes configurations that did not previously exist.
- Archives the installation record instead of deleting it.

Uninstall snapshots are stored in:

```text
~/.local/share/nyxora/uninstall-snapshots/
```

Installation history is stored in:

```text
~/.local/share/nyxora/installation-history/
```

## Customization

- AwesomeWM configuration: `.config/awesome/`
- Rofi configuration: `.config/rofi/`
- Alacritty configuration: `.config/alacritty/`
- Picom configuration: `.config/picom/`
- Wallpapers: `wallpapers/`

No wallpapers are bundled. Add your own images under `wallpapers/`.

## Important notes

- Nyxora requires an X11 session. It is not designed to run as an AwesomeWM desktop inside KDE Wayland.
- GTK application themes remain under the user's control.
- Picom's GLX backend may need to be changed to `xrender` on systems where GLX compositing flickers or fails.
- The installer does not enable services, change the display manager or modify the user's login session.
- Keep a working desktop session or TTY available when testing a new window manager.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

**Nyxora** — A quiet desktop for focused work.

Created by [YargamCR](https://github.com/YargamCR).
