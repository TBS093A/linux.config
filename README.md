# linux.config

Personal dotfiles for [Void Linux](https://voidlinux.org/) (`void.node.00`) -
shell configs, a custom login banner, VPN/tmux helpers, and a couple of
Void-specific setup notes.

## Layout

```
bash.config/    .bashrc, .bash_profile
zsh.config/     .zshrc, oh-my-zsh install/plugin scripts, the lambda-00x097 theme
git.config/     .gitconfig (aliases, commitizen, per-host TLS override for git.00x097.com)
vim.config/     init.vim (plugins, keybindings, formatting)
tmux.config/    tmux.session.sh - save/restore tmux sessions
vpn.config/     connect.sh / disconnect.sh wrapping openconnect, + a VPN host list
sshd.ssh.config/ sshd_config + welcome.sh (the login banner, see below)
distro.guide/   void.linux/README.md - Void install/xbps/runit cheat sheet
get.package.manager.zsh  detects the box's package manager (apt/pacman/xbps/...)
make.symlinks.sh         installs everything below (see Install)
```

## Install

```bash
git clone <this repo> ~/linux.config   # any path works, nothing is hardcoded
cd ~/linux.config
./make.symlinks.sh            # user-level dotfiles only (~/.gitconfig, ~/.zshrc, nvim config)
sudo ./make.symlinks.sh --system   # also links sshd_config + the MOTD banner (needs root)
```

`--system` is opt-in on purpose: it replaces `/etc/ssh/sshd_config` and the
`/etc/updated-motd.d` / `/etc/profile.d` welcome script system-wide, so it's
not something you want to run by accident. Re-running either form is safe
(`ln -sf`, idempotent) - it just re-points the symlinks.

Every script resolves its own location at runtime (`readlink -f` back
through the relevant symlink), so it doesn't matter where you clone the
repo or which user runs it - there's no hardcoded `/root/linux.config`
anywhere.

## Keeping secrets out of a public repo

This repo is public. Anything host-specific or private (employer VPN
hosts, internal IPs, k8s aliases, ...) goes in a gitignored `.local` file
instead of the tracked one:

- `zsh.config/.zshrc.local` (see `.zshrc.local.example`) - sourced
  automatically by `.zshrc` if present.
- `vpn.config/vpns.local` (see `vpns.local.example`) - appended to
  `VPNS_LIST` automatically by `connect.sh` if present.

## The login banner (`sshd.ssh.config/welcome.sh`)

Runs on every login (`/etc/profile.d`) and on SSH connect via MOTD
(`/etc/updated-motd.d`, once linked with `--system`). It replaced an older
neofetch-based script (neofetch is unmaintained and isn't in the Void
repos anymore) with a self-contained bash script that needs nothing beyond
what's already on the box (`awk`, `free`, `df`, `xbps-query`, `numfmt`,
`nproc`, `ip`, `ss`, optionally `docker`):

- Void's ascii logo, colored 1:1 against a real neofetch capture (green
  for a regular user, red as root), with a `© TBS093A` signature footer.
- OS/kernel/uptime/package count, pending xbps updates, and htop-style
  CPU/RAM/DISK meters (colored red/yellow/green by usage), each with a
  compact branch line for the percentage + detail underneath.
- A horizontal Load average + per-core row that wraps to fit the terminal.
- Sessions / IP / Docker containers, side by side when they fit and
  stacked full-width when the terminal's too narrow.
- An "Opened Ports" section (`ss -tulnp`, minimal) laid out as balanced
  branch-columns with a connector "roof", wrapped the same way as the
  cores row.
- A red WARNING banner once `/` crosses 90% used.
- Runit service health (root-only, since `/var/service/*/supervise`
  isn't world-readable).

Everything sizes itself to `tput cols` - separators, the core/ports
wrapping, and a fallback to a stacked (non-side-by-side) layout when the
terminal's too narrow for the logo and info column together. Works
identically sourced (bash or zsh login shell) or executed (run-parts).

## Void Linux notes

`distro.guide/void.linux/README.md` has the install partitioning layout,
`xbps` basics, and `sv`/runit service management commands.
