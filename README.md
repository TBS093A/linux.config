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
                tmux.session.sh - full session/window/pane save+restore
vpn.config/     connect.sh / disconnect.sh wrapping openconnect, + a VPN host list
sshd.ssh.config/ sshd_config + welcome.sh (the login banner, see below)
test/           welcome-smoke.sh - mocks every external command welcome.sh
                calls and asserts its output/behavior (see CI below)
distro.guide/   void.linux/README.md - Void install/xbps/runit cheat sheet
get.package.manager.zsh  detects the box's package manager (apt/pacman/xbps/...)
make.symlinks.sh         installs everything below (see Install)
install.sh               bootstraps a bare box: packages + oh-my-zsh + symlinks
help-cmd.sh              `help-cmd` - prints every command/keybind below (see CLI below)
lint-shell.sh            `lint-shell` - runs CI's shellcheck/syntax checks locally
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

Every question this script would otherwise ask interactively - Docker,
the prompt's `$CLOUD_PROVIDER`/`$SERVER_TYPE` badges (see "The prompt"
below) - can be answered with a flag instead, for a fully non-interactive/
scripted install: `--docker`/`--no-docker`, `--neovim`/`--no-neovim`
(installable on either profile - `--local` includes it and `--server`
skips it by default, this overrides that either way), and
`--cloud-provider=`/`--server-type=` (with `-color=` counterparts for a
custom label - leave those off and a custom label gets a random color
instead of prompting for one).

Each package installs independently, so one missing/renamed package name
on a given distro doesn't abort the run - it just warns and moves on.
`install.sh` is also safe to re-run (every step checks whether it already
ran). It never touches `/etc/passwd` or restarts services on its own - if
zsh isn't your login shell yet, it tells you to run `chsh` yourself at
the end.

If you'd rather skip the package install (already have everything) and
just re-point the symlinks:

```bash
./make.symlinks.sh                 # user-level dotfiles (~/.gitconfig, ~/.zshrc, ~/.tmux.conf, nvim config)
sudo ./make.symlinks.sh --system   # sshd_config + the MOTD banner only (needs root)
```

The two are mutually exclusive, not additive - run the first as yourself,
and the second (only if you also want the system-wide bits) separately
under `sudo`. `--system` never touches the user-level dotfiles: since a
bare `sudo` doesn't reset `$HOME` to root's on most distros (Void
included), if it did, root would `ln -sf` straight over your own
`~/.zshrc`/`~/.gitconfig`/`~/.oh-my-zsh/themes/...`, silently re-owning
them to root and breaking the next unprivileged re-run with a "Permission
denied" on that same symlink.

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
- Per-host SSH shortcuts (`ssh node000` instead of typing out a user/IP/
  key every time) go in `~/.ssh/config` as `Host` blocks - not this repo
  at all, tracked or otherwise, and not a `.zshrc.local` alias either:

  ```
  Host node000
      HostName 203.0.113.10
      User root
      IdentityFile ~/.ssh/hetzner_accesses
  ```

## Day-to-day extras

`help-cmd` prints all of this from the shell itself (colored to match
`welcome.sh`) - run it any time you forget what's here. `install.sh` pulls
in `zoxide`, `direnv`, `eza`, `bat`, `delta`, `yazi`, `ripgrep`, `fd`, `jq`,
`yq`, `lazygit`, `btop`, `k9s`, `nvtop`, `dust`, `duf`, and `procs` alongside
the base packages (`--local` adds `shellcheck`/`shfmt` on top, for editing
this repo itself), plus `mise` via its own official installer (see below);
each piece below only activates if its tool is actually present
(`command -v` guarded), so nothing breaks on a box where one of them failed
to install - not every package manager carries all of these
(`lazygit`/`btop`/`k9s`/`dust`/`duf`/`procs` in particular aren't in every
distro's default repos - RHEL/yum-based boxes are the most likely to be
missing them), and `nvtop` is installed
unconditionally even on a box with no GPU (it's harmless there, just
useless - no separate `--gpu` flag or detection to maintain).

- **zoxide** - `z <partial-path>` jumps to a frecency-ranked directory
  match, `zi` opens an fzf picker over ranked directories. Replaces `cd`
  for anywhere you've already been.
- **direnv** - per-directory env vars from a `.envrc`, loaded/unloaded
  automatically on `cd`. Opt a directory in once with `direnv allow`.
- **eza / bat** - `ls`/`ll`/`la` and `cat` are aliased to `eza`/`bat` when
  installed (icons + git status on listings, syntax highlighting on file
  contents); bat installs as `batcat` on Debian/Ubuntu, handled either way.
- **ripgrep / fd** - `rg <pattern>` and `fd <pattern>` replace `grep -R`/
  `find` (respects `.gitignore`, much faster); `fd` installs as `fd-find`
  on Debian/Ubuntu (binary `fdfind`), aliased to `fd` either way. Both
  compose with `fzf`, e.g. `fd --type f | fzf` or `Ctrl-T`'s picker.
- **jq / yq** - JSON/YAML query and pretty-print, same filter syntax
  (`yq '.spec.template.spec.containers[].image' deployment.yaml`).
- **lazygit** - `lg` opens a TUI for staging/unstaging, rebase, stash, and
  browsing commits - a faster day-to-day complement to the `git.config`
  aliases below, not a replacement for them.
- **btop** - `btop` for an interactive CPU/RAM/process view; the always-on
  numbers in the login banner and tmux statusbar cover the at-a-glance case.
- **dust / duf / procs** - modern replacements for `du`/`df`/`ps`: `dust`
  shows directory/file sizes as a sorted ASCII tree, `duf` lists disk
  usage/free per mount in a cleaner table, and `procs` lists processes with
  readable columns and a tree view. No aliases over the originals - all
  three are new commands you run directly, same as `rg`/`fd`.
- **k9s / nvtop** - `k9` (= `k9s`) for an interactive Kubernetes TUI, `gpu`
  (= `nvtop`) for interactive GPU monitoring. Both installed unconditionally
  (see above) - `welcome.sh` already only *shows* K8s/GPU info when a
  cluster/card is actually there, so these follow the same "harmless if
  unused" rule rather than adding install-time flags.
- **mise** - per-project tool version manager (python/node/terraform/
  kubectl/...), installed via its own official installer to `~/.local/bin`
  since it isn't reliably packaged across distros. Opt in per project with
  a `.mise.toml`, same as `direnv`'s `.envrc` - `install.sh` only sets up
  the binary and the shell activation hook, nothing project-specific.
- **Docker** - unlike everything else on this list, *not* installed
  unconditionally - `install.sh --server` asks first (`--docker`/
  `--no-docker` to skip that prompt, see Install below), since it's a
  heavier, more invasive install (a daemon + a group membership) than a
  CLI binary. No alias, plain `docker`; running containers show up in
  `welcome.sh`'s login banner when it's present.
- **lint-shell** - runs the exact same checks `.github/workflows/lint.yml`
  runs in CI (`shellcheck` + `bash -n`/`zsh -n` on every script in the
  repo), locally, before you push. `shfmt`, if installed, also prints a
  formatting diff - informational only, not a pass/fail gate, since
  reformatting every existing script to match would be its own large diff.
- **Nerd Font (for eza's icons)** - `eza --icons` shows tofu/`?` boxes
  instead of file-type icons without one. Fonts render client-side, so
  which box needs the font depends on how you're looking at the
  terminal:
  - **Local terminal on this box** (an X/Wayland session) - `install.sh`
    installs `nerd-fonts-symbols-ttf` on Void (~5MB, symbols only,
    layered by fontconfig over your existing font - nothing to
    configure). Not auto-installed on other package managers; grab a
    font from [nerdfonts.com](https://www.nerdfonts.com/font-downloads)
    if you're not on Void.
  - **SSH client** (Windows Terminal, PuTTY, iTerm, ...) - install a
    Nerd Font (e.g. JetBrainsMono or FiraCode Nerd Font) *there* and
    set it as the terminal's font. `install.sh` can't reach a remote
    client, so this step is always manual.
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
  `welcome.sh` (gray labels, green accent). `status-right` always shows
  CPU/RAM (`tmux.config/status-sys.sh`, refreshed every 10s, not polled
  every second) plus GPU utilization/VRAM appended only on a box that
  actually has a card - same NVIDIA/AMD dual-vendor detection as
  `welcome.sh`'s GPU meter, trimmed to one instantaneous reading.
- **tmux plugins (TPM)** - `install.sh` bootstraps
  [TPM](https://github.com/tmux-plugins/tpm) and headlessly installs just
  `tmux-yank` (clipboard integration) - no `tmux-resurrect`/`tmux-continuum`.
  Session/pane restore is `tmux.config/tmux.session.sh`'s own job instead
  (see below), which covers the same ground.
- **tmux-session** - `tmux-session save` dumps every pane in every window
  (cwd, running command, exact split layout, which window/pane was
  active) to `~/.tmux-session`; `tmux-session restore` rebuilds it -
  windows that already exist are left alone, so it's safe to run on top
  of a live session. A pane's command is relaunched by name only (no
  args, no in-program state - an editor reopens empty); anything that's
  just a shell is left as a fresh shell in its cwd instead of re-running
  itself. `tmux-session save` on a cron job is a reasonable way to keep
  this current without remembering to run it by hand.
- **git delta** - `git diff`/`git show`/etc. render through
  [delta](https://github.com/dandavison/delta) (line numbers, navigate
  mode) when it's installed - see `[delta]` in `git.config/.gitconfig`.
  Deliberately *not* side-by-side by default (this repo is meant to stay
  usable on a narrow SSH terminal) - `git diff --side-by-side` opts in
  per-command.
- **yazi** - `y` opens the [yazi](https://github.com/sxyazi/yazi) terminal
  file manager and `cd`s the shell to wherever you navigated to on quit.
- **The prompt (`zsh.config/lambda-00x097.zsh-theme`)** - normally two
  lines (`╭ user@host:path` / `╰ λ`). Two more things appear only when
  relevant, same rule as everywhere else in this repo:
  - Two badges between the corner glyph and `user@host`, in order:
    `[PROVIDER]` then `[TYPE]`. Both are set once by `install.sh
    --server`'s interactive prompts (stored in `zsh.config/.zshrc.local`,
    see `.zshrc.local.example`), editable by hand any time after - or
    non-interactively, for a scripted install:
    ```
    ./install.sh --server --cloud-provider=HETZNER --server-type=PROD
    ./install.sh --server --cloud-provider=homelab --cloud-provider-color=213 \
                 --server-type=staging --server-type-color=51
    ```
    Passing a badge's flag skips its prompt entirely, whether or not a
    real terminal is attached.
    - `$CLOUD_PROVIDER` - `AWS`/`OVH`/`AZURE`/`GCP`/`HETZNER` each get a
      fixed, brand-ish color baked into the theme; anything else is a
      custom label, colored by `$CLOUD_PROVIDER_COLOR` (a 256-color
      number - `spectrum_ls` in zsh previews the scale) if given, a
      randomly-picked one if not (chosen once by `install.sh` and
      persisted, not re-rolled on every prompt render) - editing
      `.zshrc.local` by hand without setting one falls back to plain gray
      instead, since there's nothing there to randomize with.
    - `$SERVER_TYPE` - `DEV` green, `PROD` bold red, anything else (a
      custom label) gets `$SERVER_TYPE_COLOR`, same idea (and same
      random-if-unset behavior) as `$CLOUD_PROVIDER_COLOR` - plain yellow
      is the by-hand-editing fallback here instead of gray.
  - A 3rd line, only drawn inside a git repo or a kube-configured
    directory: git branch + ahead/behind + modified/untracked counts
    first (`main ⇡2 ⇣1 ✚3 ?2`), then the current K8s context - bold red
    when the context name contains "prod". Both are icon-prefixed
    (Nerd Font glyphs); the K8s one isn't guaranteed to be in every slim
    Nerd Font build - see the comment above `_k8s_segment` in the theme
    file if it renders as a box instead of a logo.

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
