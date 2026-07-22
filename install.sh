#!/usr/bin/env bash
# dotfiles-shell installer — symlinks fish starship.toml atuin carapace fastfetch kitty to ~/.config/.
# Run standalone (clone this repo + ./install.sh) or via the umbrella.
set -eEuo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_ROOT
export DOTFILES_DIR="${DOTFILES_DIR:-$REPO_ROOT}"

BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"

BLUE='\033[0;34m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'
info()  { echo -e "${BLUE}ℹ${NC} $1"; }
ok()    { echo -e "${GREEN}✓${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠${NC} $1"; }
err()   { echo -e "${RED}✗${NC} $1"; }

deploy_symlink() {
    local src="$1" dst="$2"
    if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        warn "Backing up $dst → $BACKUP_DIR/"
        mkdir -p "$BACKUP_DIR/$(dirname "${dst#$HOME/}")"
        mv "$dst" "$BACKUP_DIR/$(dirname "${dst#$HOME/}")/"
    fi
    if [ -L "$dst" ]; then
        local current
        current="$(readlink "$dst")"
        if [ "$current" = "$src" ]; then
            return 0  # Already correct — idempotent
        fi
        rm -f "$dst"
    fi
    mkdir -p "$(dirname "$dst")"
    ln -sf "$src" "$dst"
    ok "Symlink: $dst → $src"
}

deploy_configs() {
    local entries=(fish starship.toml atuin carapace fastfetch kitty)
    for name in "${entries[@]}"; do
        if [ -e "$REPO_ROOT/$name" ]; then
            deploy_symlink "$REPO_ROOT/$name" "$HOME/.config/$name"
        else
            warn "Source not found, skipping: $REPO_ROOT/$name"
        fi
    done
}

main() {
    info "Deploying dotfiles-shell configs from $REPO_ROOT"
    deploy_configs
    # Create ~/.config/fish.custom if absent (never overwrite)
    FISH_CUSTOM="$HOME/.config/fish.custom"
    if [ ! -f "$FISH_CUSTOM" ]; then
        cat > "$FISH_CUSTOM" <<'FISHEOF'
# fish.custom — User-local Fish overrides
# This file lives OUTSIDE the dotfiles repo (~/.config/fish.custom).
# It is created once by the dotfiles-shell installer and NEVER overwritten.
# Use it for machine-specific aliases, env vars, or private configs
# that should not be committed to a public repo.
# Sourced conditionally at the end of config.fish.
FISHEOF
        ok "Created $FISH_CUSTOM"
    else
        info "fish.custom already exists — leaving untouched"
    fi

    # Append fish.custom source line to config.fish if not already present
    CONFIG_FISH="$HOME/.config/fish/config.fish"
    if [ -f "$CONFIG_FISH" ] && ! grep -q 'fish.custom' "$CONFIG_FISH"; then
        # Insert before the 'clear' line
        sed -i '/^clear$/i\
# User-local overrides (created by dotfiles-shell installer)\
if test -f ~/.config/fish.custom; source ~/.config/fish.custom; end\
' "$CONFIG_FISH"
        ok "Added fish.custom source line to config.fish"
    else
        info "fish.custom source line already in config.fish — skipping"
    fi
    ok "dotfiles-shell deploy complete"
}

main