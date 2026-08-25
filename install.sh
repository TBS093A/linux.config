#!/usr/bin/env bash
# Bootstraps a box with everything these dotfiles assume: packages,
# oh-my-zsh + its plugins, fzf shell integration, then symlinks (see
# make.symlinks.sh). Not Void-only - the package manager is auto-detected
# (see get.package.manager.zsh) so this also works on Debian/Ubuntu,
# Arch/Manjaro, and CentOS/RHEL. Safe to re-run - every step is idempotent,
# and each package installs independently so one missing/renamed package
# on a given distro doesn't abort the whole run.
#
# Usage:
#   ./install.sh              (default) --local profile
#   ./install.sh --local      full/desktop profile: everything, incl. neovim
#   ./install.sh --server     server profile: skips neovim and other
#                             desktop-leaning bits; asks whether to install
#                             Docker too
#   ./install.sh --system     also link sshd_config + the MOTD banner (sudo,
#                             see the warning make.symlinks.sh --system prints)
#                             - combine with either profile, e.g.
#                             ./install.sh --server --system
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"

log()  { printf '\033[1;32m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$1" >&2; }

_sudo() {
    if [[ ${EUID} -eq 0 ]]; then "$@"; else sudo "$@"; fi
}

# --- flags ---
PROFILE="local"
DO_SYSTEM=0
for arg in "$@"; do
    case "$arg" in
        --server) PROFILE="server" ;;
        --local)  PROFILE="local" ;;
        --system) DO_SYSTEM=1 ;;
        *) warn "Unknown flag: $arg (ignored)" ;;
    esac
done

# --- detect the package manager, preferring get.package.manager.zsh (the
# repo's own detection table) so both stay in sync; falls back to probing
# for the manager binary directly when zsh isn't installed yet (a bare box
# won't have it until the install below runs) ---
PKG_MGR=""
if command -v zsh >/dev/null 2>&1 && [[ -r "$DOTFILES_DIR/get.package.manager.zsh" ]]; then
    PKG_MGR=$(zsh "$DOTFILES_DIR/get.package.manager.zsh" 2>/dev/null | awk -F': ' '/Package manager:/{print $2}')
fi
if [[ -z $PKG_MGR ]]; then
    if   command -v xbps-install >/dev/null 2>&1; then PKG_MGR=xbps-install
    elif command -v apt-get      >/dev/null 2>&1; then PKG_MGR=apt-get
    elif command -v pacman       >/dev/null 2>&1; then PKG_MGR=pacman
    elif command -v yum          >/dev/null 2>&1; then PKG_MGR=yum
    fi
fi
if [[ -z $PKG_MGR ]]; then
    warn "Couldn't detect a supported package manager - install these manually:"
    warn "  git zsh tmux curl openconnect wireguard-tools fzf zoxide direnv eza bat$([[ $PROFILE == local ]] && echo ' neovim')"
    PKG_MGR=none
fi
log "Profile: $PROFILE, package manager: $PKG_MGR"

# installs one package at a time so a single missing/renamed package on a
# given distro doesn't abort the whole run (set -e is deliberately not on)
pkg_install() {
    local pkg
    for pkg in "$@"; do
        log "Installing $pkg"
        case "$PKG_MGR" in
            xbps-install) _sudo xbps-install -Sy "$pkg" ;;
            apt-get)      _sudo apt-get install -y "$pkg" ;;
            pacman)       _sudo pacman -Sy --noconfirm "$pkg" ;;
            yum)          _sudo yum install -y "$pkg" ;;
            none)         warn "No package manager detected - skipping $pkg" ;;
        esac || warn "Failed to install $pkg - skipping (already installed, wrong name for this distro, or offline?)"
    done
}

# a couple of package names differ per manager
docker_pkg() {
    case "$PKG_MGR" in
        apt-get) echo "docker.io" ;;
        *)       echo "docker" ;;
    esac
}

if [[ $PKG_MGR == apt-get ]]; then
    log "Refreshing apt package lists"
    _sudo apt-get update -qq || warn "apt-get update failed - continuing with whatever's cached"
fi

BASE_PKGS=(git zsh tmux curl openconnect wireguard-tools fzf zoxide direnv eza bat)
if [[ $PROFILE == local ]]; then
    BASE_PKGS+=(neovim)
fi
pkg_install "${BASE_PKGS[@]}"

# Nerd Font symbols (icons eza/fzf/etc. can render) - Void-only: it's the
# one place this repo knows the exact right package. The full nerd-fonts-ttf
# bundle is 7+ GB (every patched font family); this is the ~5MB symbols-only
# variant instead, layered by fontconfig as a fallback over whatever font
# you already use, so nothing to configure in the terminal. This only does
# anything for a terminal running ON this box (a local X/Wayland session) -
# an SSH client (e.g. Windows Terminal, PuTTY) renders with its own local
# fonts and needs a Nerd Font installed there instead; see the README.
if [[ $PKG_MGR == xbps-install ]]; then
    pkg_install nerd-fonts-symbols-ttf
    command -v fc-cache >/dev/null 2>&1 && fc-cache -f >/dev/null 2>&1
fi

if [[ $PROFILE == server ]]; then
    install_docker=0
    if [[ -t 0 ]]; then
        read -r -p "Install Docker too? [y/N] " reply
        [[ $reply =~ ^[Yy]([Ee][Ss])?$ ]] && install_docker=1
    else
        warn "Non-interactive shell - skipping the Docker prompt (pass it up front if you want it: sudo <pkgmgr> install $(docker_pkg))"
    fi
    (( install_docker )) && pkg_install "$(docker_pkg)"
fi

if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    log "Installing oh-my-zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes bash "$DOTFILES_DIR/zsh.config/install.zsh.sh"
else
    log "oh-my-zsh already installed, skipping"
fi

log "Installing zsh plugins (zsh-autosuggestions, zsh-syntax-highlighting)"
bash "$DOTFILES_DIR/zsh.config/install.zsh.plugins.sh"

if command -v fzf >/dev/null 2>&1 && [[ -d /usr/share/fzf ]]; then
    log "Wiring up fzf shell integration (~/.fzf.bash, ~/.fzf.zsh)"
    # Void's fzf package ships integration under /usr/share/fzf, not at
    # ~/.fzf.bash / ~/.fzf.zsh like fzf's own upstream installer does -
    # .bashrc/.zshrc already source the latter, so just bridge the two.
    printf 'source /usr/share/fzf/key-bindings.bash\nsource /usr/share/fzf/completion.bash\n' > "$HOME/.fzf.bash"
    printf 'source /usr/share/fzf/key-bindings.zsh\nsource /usr/share/fzf/completion.zsh\n' > "$HOME/.fzf.zsh"
fi

log "Symlinking dotfiles (user-level)"
"$DOTFILES_DIR/make.symlinks.sh"

if [[ $PROFILE == local ]] && command -v nvim >/dev/null 2>&1; then
    mkdir -p "$HOME/.cache/nvim"   # barbar.nvim writes its pin state here
    log "Bootstrapping nvim: fetching vim-plug"
    # init.vim downloads vim-plug itself on first launch if it's missing, but
    # calls plug#begin() in that same launch - too soon for the freshly
    # curl'd autoload/plug.vim to reliably be usable yet, so plug#begin
    # errors out here (expected, not a failure) and no plugins get queued.
    # A second, separate launch - vim-plug now actually on disk beforehand -
    # is what makes PlugInstall itself reliable, hence two passes.
    timeout 30 nvim --headless "+qa" >/dev/null 2>&1 || true
    log "Bootstrapping nvim: installing plugins (PlugInstall)"
    timeout 120 nvim --headless -c 'PlugInstall --sync' -c 'qa' 2>/dev/null || log "nvim plugin bootstrap timed out/failed - run nvim once manually to retry"
fi

if (( DO_SYSTEM )); then
    log "Linking system-wide configs (sshd_config, MOTD) - see the warning in sshd_config before this takes effect on a live server"
    _sudo "$DOTFILES_DIR/make.symlinks.sh" --system
else
    log "Skipped system-wide configs (sshd, motd) - re-run with --system for those (needs sudo)"
fi

log "Done. Log out and back in (or run 'chsh -s \$(command -v zsh)' first if zsh isn't your login shell yet)."
