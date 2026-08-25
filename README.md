# linux.config

Personal dotfiles built around [Void Linux](https://voidlinux.org/)
(`void.node.00`) - shell configs, a custom login banner, VPN/tmux helpers,
and a couple of Void-specific setup notes. `install.sh` isn't Void-only
though - see Install below.

## Layout

```
bash.config/    .bashrc, .bash_profile
zsh.config/     .zshrc, oh-my-zsh install/plugin scripts, the lambda-00x097
                theme, palette.zsh (shared LS_COLORS/fzf/bat theming)
git.config/     .gitconfig (aliases, commitizen, per-host TLS override for git.00x097.com)
vim.config/     init.vim (plugins, keybindings, formatting)
tmux.config/    tmux.conf (vim-style panes, welcome.sh-matched statusbar) +
                tmux.session.sh - save/restore tmux sessions
vpn.config/     connect.sh / disconnect.sh wrapping openconnect, + a VPN host list
sshd.ssh.config/ sshd_config + welcome.sh (the login banner, see below)
test/           welcome-smoke.sh - mocks every external command welcome.sh
                calls and asserts its output/behavior (see CI below)
distro.guide/   void.linux/README.md - Void install/xbps/runit cheat sheet
get.package.manager.zsh  detects the box's package manager (apt/pacman/xbps/...)
make.symlinks.sh         installs everything below (see Install)
install.sh               bootstraps a bare box: packages + oh-my-zsh + symlinks
help-cmd.sh              `help-cmd` - prints every command/keybind below (see CLI below)
```

## Install

On a fresh/bare box, one command sets up everything these dotfiles assume -
packages, oh-my-zsh + its plugins, fzf's shell integration, and the
symlinks below. The package manager is auto-detected (via
`get.package.manager.zsh` - Void/`xbps`, Debian-Ubuntu/`apt`,
Arch-Manjaro/`pacman`, CentOS-RHEL/`yum`), so this isn't Void-only:

```bash
git clone <this repo> ~/linux.config   # any path works, nothing is hardcoded
cd ~/linux.config
./install.sh --local      # (default) full/desktop set - includes neovim
./install.sh --server     # server set - skips neovim; asks whether to add Docker
./install.sh --system     # combine with either: also link sshd_config + the MOTD banner (sudo)
```

Each package installs independently, so one missing/renamed package name
on a given distro doesn't abort the run - it just warns and moves on.
`install.sh` is also safe to re-run (every step checks whether it already
ran). It never touches `/etc/passwd` or restarts services on its own - if
zsh isn't your login shell yet, it tells you to run `chsh` yourself at
the end.

If you'd rather skip the package install (already have everything) and
just re-point the symlinks:

```bash
./make.symlinks.sh            # user-level dotfiles only (~/.gitconfig, ~/.zshrc, ~/.tmux.conf, nvim config)
sudo ./make.symlinks.sh --system   # also links sshd_config + the MOTD banner (needs root)
```

`--system` is opt-in on purpose (in both scripts): it replaces
`/etc/ssh/sshd_config` and the `/etc/updated-motd.d` / `/etc/profile.d`
welcome script system-wide, so it's not something you want to run by
accident. Re-running either form is safe (`ln -sf`, idempotent) - it just
re-points the symlinks.

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

## Day-to-day extras

`help-cmd` prints all of this from the shell itself (colored to match
`welcome.sh`) - run it any time you forget what's here. `install.sh` pulls
in `zoxide`, `direnv`, `eza`, and `bat` alongside the base packages; each
piece below only activates if its tool is actually present (`command -v`
guarded), so nothing breaks on a box where one of them failed to install.

- **zoxide** - `z <partial-path>` jumps to a frecency-ranked directory
  match, `zi` opens an fzf picker over ranked directories. Replaces `cd`
  for anywhere you've already been.
- **direnv** - per-directory env vars from a `.envrc`, loaded/unloaded
  automatically on `cd`. Opt a directory in once with `direnv allow`.
- **eza / bat** - `ls`/`ll`/`la` and `cat` are aliased to `eza`/`bat` when
  installed (icons + git status on listings, syntax highlighting on file
  contents); bat installs as `batcat` on Debian/Ubuntu, handled either way.
- **`zsh.config/palette.zsh`** - the gray/accent numbers `welcome.sh` uses,
  in one place, sourced by `.zshrc` and turned into `LS_COLORS` (so
  directories/symlinks/executables in `ls`/`eza` match), `FZF_DEFAULT_OPTS`
  (so every fzf picker - history, `Ctrl-T`, `fco`, `fkill`, `zi` - matches),
  and `BAT_THEME=ansi` (so `bat` renders through the terminal's own ANSI
  colors instead of a fixed theme). `tmux.conf`'s statusbar uses the same
  numbers directly, since tmux config can't source shell files.
- **fzf, deeper than completion** - `Ctrl-T`'s file picker previews with
  `bat` when it's around; `fco` fuzzy-picks a local/remote git branch and
  checks it out; `fkill` fuzzy-picks a process (sorted by CPU) and
  `kill -9`s it.
- **tmux.conf** - keeps the default `C-b` prefix, adds vim-style pane
  splits/navigation (`| -` to split, `hjkl` to move, `HJKL` to resize),
  vi copy-mode, mouse support, and a statusbar in the same palette as
  `welcome.sh` (gray labels, green accent).

## The login banner (`sshd.ssh.config/welcome.sh`)

Runs on every login (`/etc/profile.d`) and on SSH connect via MOTD
(`/etc/updated-motd.d`, once linked with `--system`). It replaced an older
neofetch-based script (neofetch is unmaintained and isn't in the Void
repos anymore) with a self-contained bash script that needs nothing beyond
what's already on the box (`awk`, `free`, `df`, `xbps-query`, `numfmt`,
`nproc`, `ip`, `ss`; `docker` and `kubectl` are optional and auto-detected):

- Void's ascii logo, colored 1:1 against a real neofetch capture (green
  for a regular user, red as root), with a `© TBS093A` signature footer.
- OS/kernel/uptime/package count, pending xbps updates, and htop-style
  CPU/RAM/DISK/GPU meters (colored red/yellow/green by usage), each with a
  compact branch line for the percentage + detail underneath. GPU is
  NVIDIA (`nvidia-smi`) or AMD (`amdgpu` sysfs), averaged/summed across
  multiple cards; skipped entirely if there isn't one.
- A horizontal Load average + per-core row, and (only with a GPU present)
  a matching per-card row - both wrap to fit the terminal.
- Sessions / IP / Docker containers / K8s node (name, role, scheduled
  pods) - as a 2-4 column row, side by side when they fit and stacked
  full-width when the terminal's too narrow. Docker and K8s each only
  claim a column when there's actually something to show (docker
  installed / this host registers as a reachable cluster node - `kubectl`
  calls are timeout-guarded so an unconfigured client can't hang the banner).
- An "Opened Ports" section (`ss -tulnp`, minimal) laid out as balanced
  branch-columns with a connector "roof", wrapped the same way as the
  cores row.
- A red WARNING banner once `/` crosses 90% used.
- Runit service health (root-only, since `/var/service/*/supervise`
  isn't world-readable).
- A pointer to `help-cmd` (see Day-to-day extras above) right before the
  footer, for anyone landing on the box for the first time.

Everything sizes itself to `tput cols` - separators, the core/ports
wrapping, and a fallback to a stacked (non-side-by-side) layout when the
terminal's too narrow for the logo and info column together. Works
identically sourced (bash or zsh login shell) or executed (run-parts).

The slow, independent lookups (xbps, docker, GPU, kubectl, service health)
run backgrounded and concurrently rather than piling up serially, so total
time is bounded by the slowest one instead of their sum. Two env vars tune
this further:

- `WELCOME_SECTIONS` - comma-separated allowlist of `pkg,docker,gpu,k8s,services`
  (default: all). Skips the background job itself, not just its rendering -
  useful on slower/headless boxes. `WELCOME_SECTIONS=` (empty) turns every
  optional section off.
- `NO_COLOR` - any non-empty value strips every ANSI escape code, per the
  [NO_COLOR](https://no-color.org) convention.

## CI

Two GitHub Actions workflows run on every push:

- `lint.yml` - `shellcheck` on every bash script, plus `bash -n`/`zsh -n`
  syntax checks (`welcome.sh` is checked under both, since it's sourced by
  either shell).
- `test.yml` - `test/welcome-smoke.sh`: stubs every external command and
  hardcoded system path `welcome.sh` reads, then sources it under a real
  pty. Runs under both bash and zsh, since the two bugs it guards against
  (job-control notification spam leaking into the login shell, and a
  meter bar built from a variable the backgrounded job hadn't populated
  yet) only show up in a genuinely interactive shell - `bash -c`/`zsh -c`
  don't reach the code path that would catch either one.

## Void Linux notes

`distro.guide/void.linux/README.md` has the install partitioning layout,
`xbps` basics, and `sv`/runit service management commands.
