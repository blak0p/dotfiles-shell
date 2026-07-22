# dotfiles-shell

Shell + terminal: `fish/`, `starship.toml`, `atuin/`, `carapace/`, `fastfetch/`, `kitty/`.

Part of the [dotfiles umbrella](https://github.com/blak0p/dotfiles).

## Standalone install

```bash
git clone https://github.com/blak0p/dotfiles-shell.git
cd dotfiles-shell
./install.sh
```

The installer symlinks each entry into `~/.config/`. Existing files are backed up with a `.bak.<timestamp>` suffix.

## `fish.custom`

On first install, the installer creates `~/.config/fish.custom` (if absent) with a comment header. This file lives **outside** the repo and is sourced conditionally at the end of `config.fish`. Use it for machine-specific aliases, env vars, or private config that should not be committed to a public repo. The installer never overwrites an existing `fish.custom`.

## What's deployed

- `fish` → `~/.config/fish` (Fish shell, including `config.fish` and the `fish.custom` source guard)
- `starship.toml` → `~/.config/starship.toml` (prompt)
- `atuin` → `~/.config/atuin` (shell history search)
- `carapace` → `~/.config/carapace` (multi-shell completions)
- `fastfetch` → `~/.config/fastfetch` (system info fetch)
- `kitty` → `~/.config/kitty` (terminal emulator)