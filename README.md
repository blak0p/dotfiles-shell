# dotfiles-shell

Shell + terminal config: `fish/`, `starship.toml`, `atuin/`, `carapace/`, `fastfetch/`, `kitty/`.

Part of the [dotfiles umbrella](https://github.com/blak0p/dotfiles).

## Table of contents

- [What gets deployed](#what-gets-deployed)
- [Install](#install)
- [Update](#update)
- [Uninstall / rollback](#uninstall--rollback)
- [fish.custom — private config](#fishcustom--private-config)
- [Customize](#customize)
- [Troubleshooting](#troubleshooting)
- [Dependencies](#dependencies)

---

## What gets deployed

| Symlink | What it configures |
|---|---|
| `~/.config/fish` | Fish shell — `config.fish`, completions, functions, themes, `auto-Hypr.fish` |
| `~/.config/starship.toml` | Starship prompt |
| `~/.config/atuin` | Shell history search (with FZF) |
| `~/.config/carapace` | Multi-shell completions |
| `~/.config/fastfetch` | System info on shell start |
| `~/.config/kitty` | Kitty terminal emulator (with native cursor trail) |

Plus, the installer **creates** (not symlinks) `~/.config/fish.custom` on first run. See [fish.custom](#fishcustom--private-config).

## Install

### As part of the umbrella (recommended)

```bash
git clone --recurse-submodules https://github.com/blak0p/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --fish    # or --kitty (alias)
```

`--fish` and `--kitty` are aliases — both invoke the `dotfiles-shell/install.sh`, since fish and kitty live in the same domain.

### Standalone (without the umbrella)

```bash
git clone https://github.com/blak0p/dotfiles-shell.git
cd dotfiles-shell
./install.sh
```

### Install system dependencies first

The `install.sh` only creates symlinks — it does NOT install packages. Use the bundled `install-deps.sh`:

```bash
bash deps/install-deps.sh
```

It auto-detects your package manager (`pacman`, `dnf`, or `apt`) and installs the right list. See [Dependencies](#dependencies).

## Update

```bash
cd ~/dotfiles/dotfiles-shell
git pull
./install.sh
```

Or as part of the umbrella:

```bash
cd ~/dotfiles
git submodule update --remote --merge dotfiles-shell
```

## Uninstall / rollback

Backups of any pre-existing real configs are kept at `~/.dotfiles-backup-YYYYMMDD-HHMMSS/`.

```bash
# Remove symlinks
for s in fish starship.toml atuin carapace fastfetch kitty; do
    rm -f ~/.config/$s
done

# Restore from latest backup
BACKUP=$(ls -td ~/.dotfiles-backup-* | head -1)
[ -n "$BACKUP" ] && cp -a "$BACKUP"/.config/. ~/.config/
```

## fish.custom — private config

`fish.custom` is a user-local override file that lives **outside the repo** at `~/.config/fish.custom`. The installer:

1. **Creates it** on first install with a comment header (if absent).
2. **Never overwrites** an existing file.
3. **Appends a source line** to `config.fish` (the line `if test -f ~/.config/fish.custom; source ~/.config/fish.custom; end` before the `clear` command).

### What to put in fish.custom

Anything machine-specific, private, or that you don't want in a public repo:

- Host-specific aliases
- Environment variables (API keys stay out of this file too — use a secrets manager)
- Private PATH entries
- Custom prompts that vary by host
- The `bunker-sync.fish` if you use distrobox

### Why this design

- The repo stays clean (no `alejndro` paths, no hostnames, no tokens)
- `git status` inside `dotfiles-shell` never shows the file
- You can `rm ~/.config/fish.custom` to revert to pure-repo config
- Multiple hosts can share the repo but diverge at the `fish.custom` layer

## Customize

The most common edits:

- **Add an alias**: edit `fish/conf.d/aliases.fish`, then `source ~/.config/fish/config.fish` (or open a new shell)
- **Add a function**: drop a `.fish` file in `fish/functions/`, fish autoloads it
- **Change the prompt**: edit `fish/config.fish` (the starship init line) or `starship.toml` directly
- **Change kitty theme**: edit `kitty/kitty.conf`
- **Change keybinds**: edit `fish/conf.d/zzz-custom-binds.fish`

After editing `config.fish`:

```bash
source ~/.config/fish/config.fish
```

Or open a new fish shell — it auto-sources `config.fish` on startup.

## Troubleshooting

### `fish` not found after install

You need to install fish via the system package manager. Run `bash deps/install-deps.sh` or:

```bash
# Arch
sudo pacman -S fish
# Fedora
sudo dnf install fish
# Debian/Ubuntu
sudo apt install fish
```

Then set fish as your default shell (optional):

```bash
chsh -s $(which fish)
```

Log out and back in for the change to take effect.

### `atuin` not found

`atuin` is **not** in the Fedora or Debian official repos. Install via cargo:

```bash
sudo dnf install cargo    # or: sudo apt install cargo
cargo install atuin
```

Or grab a prebuilt binary from https://github.com/atuinsh/atuin/releases.

### `fisher` not installed

`fisher` is a fish plugin, not a system package. After fish is installed:

```bash
fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
```

### `fish.custom` source line missing

The installer should add it. If it didn't (or you removed it manually), the installer is idempotent and won't add it twice. To force-add it:

```bash
grep -q 'fish.custom' ~/.config/fish/config.fish || \
    sed -i '/^clear$/i\
# User-local overrides (created by dotfiles-shell installer)\
if test -f ~/.config/fish.custom; source ~/.config/fish.custom; end\
' ~/.config/fish/config.fish
```

### Kitty font issues

If text looks weird, install a Nerd Font (used by starship + kitty). Recommended: `JetBrainsMono Nerd Font`.

```bash
# Arch
sudo pacman -S ttf-jetbrains-mono-nerd
# Fedora
sudo dnf install jetbrains-mono-fonts
```

Then set the font in `kitty/kitty.conf`: `font_family JetBrainsMono Nerd Font`.

## Dependencies

- Arch: `deps/packages.txt`
- Fedora: `deps/packages.dnf.txt`
- Debian/Ubuntu: `deps/packages.apt.txt`

Or run `bash deps/install-deps.sh` (auto-detects).

Notable packages:
- `fish` — the shell
- `kitty` — terminal
- `starship` — prompt
- `atuin` — history search (special: see notes above for non-Arch)
- `fzf` — needed by atuin and useful on its own
- `eza`, `bat`, `zoxide` — quality-of-life CLI replacements

## Related

- Umbrella: https://github.com/blak0p/dotfiles
- Other sub-repos: `dotfiles-hyprland`, `dotfiles-editors`
- Private: `dotfiles-bunker`

## License

Personal config — use at your own risk.
