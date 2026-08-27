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
#                             Docker too, and interactively for the prompt's
#                             CLOUD_PROVIDER/SERVER_TYPE badges (see below)
#   ./install.sh --system     also link sshd_config + the MOTD banner (sudo,
#                             see the warning make.symlinks.sh --system prints)
#                             - combine with either profile, e.g.
#                             ./install.sh --server --system
#
# Every question this script would otherwise ask can be answered up front
# with a flag instead, for a fully non-interactive/scripted run - none of
# these need a real terminal:
#   ./install.sh --server --docker --neovim \
#                --cloud-provider=HETZNER --server-type=PROD
#   ./install.sh --server --no-docker --no-neovim \
#                --cloud-provider=homelab --cloud-provider-color=213 \
#                --server-type=staging --server-type-color=51
# --docker/--no-docker force-install/skip Docker on --server (normally a
# y/N prompt there; --local never installs it regardless).
# --neovim/--no-neovim force-install/skip neovim on EITHER profile
# (normally on for --local, off for --server - no prompt either way, just
# a default this overrides).
# --cloud-provider=/--server-type= skip that badge's prompt outright, and
# --cloud-provider-color=/--server-type-color= (256-color numbers, 0-255 -
# run `spectrum_ls` in zsh to preview the scale) skip its color prompt too
# - AWS/OVH/AZURE/GCP/HETZNER and DEV/PROD have a fixed color already, the
# -color flags only matter for anything else. A custom label with no color
# given at all, by flag or interactively left blank, gets a random one
# instead (picked once here, not by the theme on every prompt render).
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
CLOUD_PROVIDER_ARG=""
CLOUD_PROVIDER_COLOR_ARG=""
SERVER_TYPE_ARG=""
SERVER_TYPE_COLOR_ARG=""
DOCKER_ARG=""   # "" = ask (--server) / never (--local), "1"/"0" = force install/skip
NEOVIM_ARG=""   # "" = profile default (on for --local, off for --server), "1"/"0" = force
for arg in "$@"; do
    case "$arg" in
        --server) PROFILE="server" ;;
        --local)  PROFILE="local" ;;
        --system) DO_SYSTEM=1 ;;
        --docker)    DOCKER_ARG=1 ;;
        --no-docker) DOCKER_ARG=0 ;;
        --neovim)    NEOVIM_ARG=1 ;;
        --no-neovim) NEOVIM_ARG=0 ;;
        --cloud-provider=*)       CLOUD_PROVIDER_ARG="${arg#*=}" ;;
        --cloud-provider-color=*) CLOUD_PROVIDER_COLOR_ARG="${arg#*=}" ;;
        --server-type=*)          SERVER_TYPE_ARG="${arg#*=}" ;;
        --server-type-color=*)    SERVER_TYPE_COLOR_ARG="${arg#*=}" ;;
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

delta_pkg() {
    case "$PKG_MGR" in
        xbps-install) echo "delta" ;;
        *)            echo "git-delta" ;;
    esac
}

# fd installs as fd-find on Debian/Ubuntu (name clash with another package) -
# the binary itself ends up as `fdfind` there too, aliased to `fd` in .zshrc
fd_pkg() {
    case "$PKG_MGR" in
        apt-get) echo "fd-find" ;;
        *)       echo "fd" ;;
    esac
}

if [[ $PKG_MGR == apt-get ]]; then
    log "Refreshing apt package lists"
    _sudo apt-get update -qq || warn "apt-get update failed - continuing with whatever's cached"
fi

BASE_PKGS=(git zsh tmux curl openconnect wireguard-tools fzf zoxide direnv eza bat \
    "$(delta_pkg)" yazi ripgrep "$(fd_pkg)" jq yq lazygit btop k9s nvtop dust duf procs)

# neovim: --local profile default, --server skips it - --neovim/--no-neovim
# overrides either way, so this decision doesn't need a --local/--server
# switch specifically either if you're scripting the whole install
install_neovim=0
[[ $PROFILE == local ]] && install_neovim=1
[[ $NEOVIM_ARG == 1 ]] && install_neovim=1
[[ $NEOVIM_ARG == 0 ]] && install_neovim=0
(( install_neovim )) && BASE_PKGS+=(neovim)

if [[ $PROFILE == local ]]; then
    BASE_PKGS+=(shellcheck shfmt)
fi
pkg_install "${BASE_PKGS[@]}"

# mise (per-project tool version manager - python/node/terraform/kubectl/...)
# isn't reliably packaged across distros, so this uses its own official
# installer instead of pkg_install/PKG_MGR - user-local (~/.local/bin), no
# sudo, safe to re-run. Installing the binary is as far as this goes: no
# .mise.toml is generated anywhere, and it's opt-in per project the same
# way direnv's .envrc already is - only the shell activation hook (.zshrc)
# is unconditional, matching the zoxide/direnv pattern.
if ! command -v mise >/dev/null 2>&1 && [[ ! -x "$HOME/.local/bin/mise" ]]; then
    log "Installing mise"
    curl -fsSL https://mise.run | sh || warn "mise install failed - see https://mise.jdx.dev/getting-started.html"
else
    log "mise already installed, skipping"
fi

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

# Upserts export VAR="value" into .zshrc.local (gitignored, host-specific) -
# creating it from the .example first if it doesn't exist yet. Used below
# for CLOUD_PROVIDER/CLOUD_PROVIDER_COLOR/SERVER_TYPE, the lambda prompt's
# line-1 badge variables (see zsh.config/lambda-00x097.zsh-theme).
set_zshrc_local_var() {
    local var="$1" value="$2"
    local zshrc_local="$DOTFILES_DIR/zsh.config/.zshrc.local"
    [[ -f $zshrc_local ]] || cp "$DOTFILES_DIR/zsh.config/.zshrc.local.example" "$zshrc_local"
    if grep -q "^export ${var}=" "$zshrc_local" 2>/dev/null; then
        sed -i "s/^export ${var}=.*/export ${var}=\"${value}\"/" "$zshrc_local"
    else
        printf '\nexport %s="%s"\n' "$var" "$value" >> "$zshrc_local"
    fi
}

# 21-230 stays inside the 6x6x6 RGB cube (16-231), skipping the 16 basic
# ANSI slots (0-15, incl. true black/white) and the 232-255 grayscale ramp
# (too close to the house gray/244, or just washed out) - a broad, mostly
# legible range for a badge that's supposed to stand out.
random_badge_color() { echo $(( (RANDOM % 210) + 21 )); }

if [[ $PROFILE == server ]]; then
    install_docker=0
    if [[ -n $DOCKER_ARG ]]; then
        install_docker=$DOCKER_ARG
    elif [[ -t 0 ]]; then
        read -r -p "Install Docker too? [y/N] " reply
        [[ $reply =~ ^[Yy]([Ee][Ss])?$ ]] && install_docker=1
    else
        warn "Non-interactive shell - skipping the Docker prompt (pass --docker or --no-docker up front, or sudo <pkgmgr> install $(docker_pkg) yourself later)"
    fi
    (( install_docker )) && pkg_install "$(docker_pkg)"

    # CLOUD_PROVIDER drives the [AWS]/[OVH]/[AZURE]/[GCP]/[HETZNER]/custom
    # badge the lambda prompt shows first on line 1, before SERVER_TYPE's
    # badge - see zsh.config/lambda-00x097.zsh-theme. The 5 known providers
    # get a fixed color baked into the theme; CUSTOM asks for both a label
    # and its own 256-color number (CLOUD_PROVIDER_COLOR), falling back to
    # plain gray if left blank. Only asked for a server profile, same
    # reasoning as SERVER_TYPE below - a personal/local box doesn't need it.
    CLOUD_PROVIDER=""
    CLOUD_PROVIDER_COLOR=""
    if [[ -n $CLOUD_PROVIDER_ARG ]]; then
        CLOUD_PROVIDER=$CLOUD_PROVIDER_ARG
        if [[ -n $CLOUD_PROVIDER_COLOR_ARG ]]; then
            if [[ $CLOUD_PROVIDER_COLOR_ARG =~ ^[0-9]+$ && $CLOUD_PROVIDER_COLOR_ARG -le 255 ]]; then
                CLOUD_PROVIDER_COLOR=$CLOUD_PROVIDER_COLOR_ARG
            else
                warn "--cloud-provider-color must be 0-255 (run 'spectrum_ls' in zsh to preview) - ignoring '$CLOUD_PROVIDER_COLOR_ARG', picking one at random instead"
            fi
        fi
    elif [[ -t 0 ]]; then
        echo "Cloud/host provider for the prompt badge?"
        select cp in AWS OVH AZURE GCP HETZNER CUSTOM; do
            case "$cp" in
                AWS|OVH|AZURE|GCP|HETZNER) CLOUD_PROVIDER=$cp; break ;;
                CUSTOM)
                    read -r -p "Custom label: " CLOUD_PROVIDER
                    while true; do
                        read -r -p "Color (256-color number 0-255, blank to pick one at random - 'spectrum_ls' in zsh previews the scale): " CLOUD_PROVIDER_COLOR
                        [[ -z $CLOUD_PROVIDER_COLOR ]] && break
                        [[ $CLOUD_PROVIDER_COLOR =~ ^[0-9]+$ && $CLOUD_PROVIDER_COLOR -le 255 ]] && break
                        echo "Enter a number 0-255, or leave blank"
                    done
                    break
                    ;;
                *) echo "Pick 1-6" ;;
            esac
        done
    else
        warn "Non-interactive shell - skipping the cloud-provider prompt (pass --cloud-provider=NAME up front - see this script's usage header - or set CLOUD_PROVIDER yourself in zsh.config/.zshrc.local later)"
    fi
    if [[ -n $CLOUD_PROVIDER ]]; then
        # a custom (non-AWS/OVH/AZURE/GCP/HETZNER) label with no color given
        # either way (flag or prompt) gets a random one, picked once here
        # and persisted - not left to the theme to fall back on every
        # prompt render, which would make the badge flicker between colors
        case "${CLOUD_PROVIDER^^}" in
            AWS|OVH|AZURE|GCP|HETZNER) ;;   # fixed color already baked into the theme
            *) if [[ -z $CLOUD_PROVIDER_COLOR ]]; then
                   CLOUD_PROVIDER_COLOR=$(random_badge_color)
                   log "No color given for custom CLOUD_PROVIDER=$CLOUD_PROVIDER - picked one at random: $CLOUD_PROVIDER_COLOR"
               fi ;;
        esac
        set_zshrc_local_var CLOUD_PROVIDER "$CLOUD_PROVIDER"
        [[ -n $CLOUD_PROVIDER_COLOR ]] && set_zshrc_local_var CLOUD_PROVIDER_COLOR "$CLOUD_PROVIDER_COLOR"
        log "Prompt badge set: CLOUD_PROVIDER=$CLOUD_PROVIDER${CLOUD_PROVIDER_COLOR:+ (color $CLOUD_PROVIDER_COLOR)} (zsh.config/.zshrc.local)"
    fi

    # SERVER_TYPE drives the [DEV]/[PROD]/custom badge right after it - a
    # custom label can get its own color too (SERVER_TYPE_COLOR), same
    # idea as CLOUD_PROVIDER_COLOR above.
    SERVER_TYPE=""
    SERVER_TYPE_COLOR=""
    if [[ -n $SERVER_TYPE_ARG ]]; then
        SERVER_TYPE=$SERVER_TYPE_ARG
        if [[ -n $SERVER_TYPE_COLOR_ARG ]]; then
            if [[ $SERVER_TYPE_COLOR_ARG =~ ^[0-9]+$ && $SERVER_TYPE_COLOR_ARG -le 255 ]]; then
                SERVER_TYPE_COLOR=$SERVER_TYPE_COLOR_ARG
            else
                warn "--server-type-color must be 0-255 (run 'spectrum_ls' in zsh to preview) - ignoring '$SERVER_TYPE_COLOR_ARG', picking one at random instead"
            fi
        fi
    elif [[ -t 0 ]]; then
        echo "Server type for the prompt badge?"
        select st in DEV PROD CUSTOM; do
            case "$st" in
                DEV|PROD) SERVER_TYPE=$st; break ;;
                CUSTOM)
                    read -r -p "Custom label: " SERVER_TYPE
                    while true; do
                        read -r -p "Color (256-color number 0-255, blank to pick one at random - 'spectrum_ls' in zsh previews the scale): " SERVER_TYPE_COLOR
                        [[ -z $SERVER_TYPE_COLOR ]] && break
                        [[ $SERVER_TYPE_COLOR =~ ^[0-9]+$ && $SERVER_TYPE_COLOR -le 255 ]] && break
                        echo "Enter a number 0-255, or leave blank"
                    done
                    break
                    ;;
                *) echo "Pick 1-3" ;;
            esac
        done
    else
        warn "Non-interactive shell - skipping the server-type prompt (pass --server-type=NAME up front - see this script's usage header - or set SERVER_TYPE yourself in zsh.config/.zshrc.local later)"
    fi
    if [[ -n $SERVER_TYPE ]]; then
        # same random-color-if-none-given deal as CLOUD_PROVIDER above
        case "${SERVER_TYPE^^}" in
            DEV|PROD) ;;   # fixed color already baked into the theme
            *) if [[ -z $SERVER_TYPE_COLOR ]]; then
                   SERVER_TYPE_COLOR=$(random_badge_color)
                   log "No color given for custom SERVER_TYPE=$SERVER_TYPE - picked one at random: $SERVER_TYPE_COLOR"
               fi ;;
        esac
        set_zshrc_local_var SERVER_TYPE "$SERVER_TYPE"
        [[ -n $SERVER_TYPE_COLOR ]] && set_zshrc_local_var SERVER_TYPE_COLOR "$SERVER_TYPE_COLOR"
        log "Prompt badge set: SERVER_TYPE=$SERVER_TYPE${SERVER_TYPE_COLOR:+ (color $SERVER_TYPE_COLOR)} (zsh.config/.zshrc.local)"
    fi
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

if command -v tmux >/dev/null 2>&1; then
    TMUX_PLUGINS_DIR="$HOME/.tmux/plugins"
    if [[ ! -d "$TMUX_PLUGINS_DIR/tpm" ]]; then
        log "Installing tmux plugin manager (TPM)"
        mkdir -p "$TMUX_PLUGINS_DIR"
        git clone --depth 1 https://github.com/tmux-plugins/tpm "$TMUX_PLUGINS_DIR/tpm" \
            || warn "TPM clone failed - install manually: https://github.com/tmux-plugins/tpm"
    else
        log "TPM already installed, skipping"
    fi
    # headless install pass (needs ~/.tmux.conf in place already, hence
    # after make.symlinks.sh above) so tmux-yank is ready without opening
    # tmux and pressing prefix + I yourself - session/pane restore is
    # tmux.session.sh's own job, not a TPM plugin's (see tmux.conf)
    if [[ -x "$TMUX_PLUGINS_DIR/tpm/bin/install_plugins" ]]; then
        log "Installing tmux plugins (yank)"
        "$TMUX_PLUGINS_DIR/tpm/bin/install_plugins" >/dev/null 2>&1 \
            || warn "tmux plugin install failed - run inside tmux: prefix + I"
    fi
fi

if command -v nvim >/dev/null 2>&1; then
    # gated on nvim actually being present, not the profile/flag that got
    # it there - --neovim installs it under --server too now, and this
    # keeps its plugins bootstrapped either way
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
