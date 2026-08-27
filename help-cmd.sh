#!/usr/bin/env bash
# Prints a rundown of what these dotfiles add on top of a bare shell: custom
# commands/aliases and their flags, plus the keybindings that come with them.
# Colors match welcome.sh's palette (gray labels, green/red accent) so this
# reads as part of the same "house style", not a bolted-on extra.
#
# Symlinked as `help-cmd` via .zshrc/.bashrc aliases (see make.symlinks.sh -
# it's a repo-relative alias, not installed onto PATH, same pattern as
# tmux-session).

[[ -n ${NO_COLOR:-} ]] && NOCOLOR=1 || NOCOLOR=0
if (( NOCOLOR )); then
    RESET="" BOLD="" GRAY="" ACCENT="" DIM=""
else
    RESET=$'\e[0m'; BOLD=$'\e[1m'; DIM=$'\e[2m'
    GRAY=$'\e[38;5;244m'; ACCENT=$'\e[38;5;002m'
fi

_section() { printf '\n%s%s%s\n' "${BOLD}${ACCENT}" "$1" "$RESET"; }
_row() {
    # $1 = command/keybind, $2 = description
    printf '  %s%-28s%s %s%s%s\n' "$BOLD" "$1" "$RESET" "$GRAY" "$2" "$RESET"
}
_have() { command -v "$1" >/dev/null 2>&1; }

printf '%s%shelp-cmd%s %s- what you can run on this box%s\n' "$BOLD" "$ACCENT" "$RESET" "$DIM" "$RESET"

_section "Prompt (zsh.config/lambda-00x097.zsh-theme)"
_row "╭ [PROVIDER] [TYPE] user@host:path" "line 1 - each badge only shows if its env var is set"
_row "  [PROVIDER]"              "AWS/OVH/AZURE/GCP/HETZNER (fixed color) or a custom label+color"
_row "  [TYPE]"                  "[DEV] green, [PROD] bold red, anything else (custom) its own color"
_row "  custom, no color given"  "install.sh picks a random one - not re-rolled after that"
_row "3rd line: git + K8s"      "only drawn when at least one has something to show"
_row "  branch ⇡N ⇣N ✚N ?N"    "commits ahead/behind upstream, modified, untracked (0s hidden)"
_row "  K8s context"            "read from \$KUBECONFIG / ~/.kube/config - no kubectl call"
_row "  bold red context"       "context name contains \"prod\""
_row "╰ λ"                      "always there - this is where you actually type"

_section "Navigation"
if _have zoxide; then
    _row "z <partial-path>"   "jump to a frecency-ranked directory match"
    _row "zi"                 "interactive (fzf) picker over ranked directories"
else
    _row "cd <path>"          "zoxide not installed - plain cd for now"
fi

_section "Files"
if _have eza; then
    _row "ls / ll / la"       "eza - icons, git status, dirs first (aliased)"
else
    _row "ls"                 "eza not installed - plain ls (--color=auto)"
fi
if _have bat || _have batcat; then
    _row "cat <file>"         "bat - syntax-highlighted (aliased, --style=plain)"
else
    _row "cat <file>"         "bat not installed - plain cat"
fi
_row "ex <archive>"           "extract tar/zip/gz/bz2/rar/7z - whatever it is (.bashrc)"
if _have yazi; then
    _row "y"                  "yazi file manager, cd's the shell to where you quit"
    _row "  hjkl / Enter"     "move around / open (h also goes up a directory)"
    _row "  q"                "quit - back to the shell, now in that directory"
fi

_section "Search"
if _have rg; then
    _row "rg <pattern>"       "ripgrep - fast recursive grep, respects .gitignore"
    _row "rg -i <pattern>"    "case-insensitive; -l for filenames only, -A/-B/-C N for context"
fi
if _have fd || _have fdfind; then
    _row "fd <pattern>"       "fast recursive find (fdfind, aliased, on Debian/Ubuntu)"
    _row "fd -e yaml"         "filter by extension; -t f / -t d for files-only / dirs-only"
    _row "fd -t f | fzf"      "pipe into fzf for an interactive picker"
fi
if ! _have rg && ! (_have fd || _have fdfind); then
    _row "grep -R / find"     "ripgrep/fd not installed - plain grep/find for now"
fi
if _have jq; then
    _row "jq <filter>"        "JSON query/pretty-print, e.g. jq '.status.phase'"
    _row "kubectl ... -o json | jq" "pretty-print/filter API output"
fi
if _have yq; then
    _row "yq <filter>"        "same filter syntax as jq, for YAML"
    _row "yq '.spec.template...image'" "e.g. read an image tag out of a deployment.yaml"
fi

_section "Fuzzy search (fzf)"
if _have fzf; then
    _row "Ctrl-R"              "fuzzy search command history"
    if _have bat || _have batcat; then
        _row "Ctrl-T"          "fuzzy-insert a file path, previewed with bat"
    else
        _row "Ctrl-T"          "fuzzy-insert a file path at the cursor"
    fi
    _row "Alt-C"               "fuzzy-cd into a subdirectory"
    _row "fco"                 "fuzzy git checkout - pick a local/remote branch"
    _row "fkill"                "fuzzy-pick a process (by CPU), kill -TERM it"
    _row "fkill9"               "same picker, kill -9/SIGKILL it (when fkill doesn't stick)"
else
    _row "fzf"                 "not installed - Ctrl-R/T, Alt-C, fco, fkill/fkill9 need it"
fi

_section "tmux"
_row "prefix"                 "Ctrl-b - press, RELEASE, then press the key below"
_row "tmux-session save"      "dump every pane's cwd/command + each window's layout"
_row "tmux-session restore"   "rebuild it - panes, layout, active window/pane"
_row "prefix + | / -"         "split pane vertically / horizontally"
_row "prefix + h/j/k/l"       "move between panes (vim-style)"
_row "prefix + H/J/K/L"       "resize the current pane (vim-style)"
_row "prefix + r"             "reload tmux.conf"
_row "prefix + d"             "detach - session/panes keep running, tmux attach to come back"
_row "tmux ls"                "list sessions, from a plain (non-tmux) terminal"
_row "tmux a / attach"        "reattach - the most recently active session if more than one exists"
_row "tmux a -t <name>"       "reattach to that specific session instead"
_row "prefix + \$"            "rename the current session (tmux default: 0/1/2... otherwise)"
_row "tmux new -s <name>"     "name a session at creation time instead of renaming after"
_row "tmux rename-session -t old new" "rename one from a plain terminal, no attaching needed"
_row "copy-mode: v / y"       "vi-style: start selection / copy and exit"
_row "mouse"                  "click to select pane, drag to resize, scroll for copy-mode"
_row "prefix + I"             "TPM: (re)install tmux-yank"
_row "status-right"           "CPU/RAM always shown, GPU appended if present (status-sys.sh)"

_section "Also on this box (install.sh)"
_row "curl"                   "installed, no alias - plain curl"
_row "openconnect"            "installed for vpn.config/connect.sh (SSL VPN)"
_row "wireguard-tools"        "installed for the vpn-00x097-* aliases (wg-quick)"
if _have nvim; then
    _row "nvim"                "installed - run ${BOLD}help-nvim${RESET}${GRAY} for its keybindings/behavior"
else
    _row "nvim"                "not installed - install.sh --local includes it"
fi
if _have btop; then
    _row "btop"                "interactive CPU/RAM/process monitor"
    _row "  q"                  "quit"
fi
if _have dust; then
    _row "dust"                "like du - directory/file sizes, sorted, ASCII tree"
fi
if _have duf; then
    _row "duf"                 "like df - disk usage/free, all mounts, cleaner output"
fi
if _have procs; then
    _row "procs"               "like ps - readable columns, tree view, search by name"
fi
if _have docker; then
    _row "docker"              "installed, no alias - plain docker (install.sh --server, optional)"
    _row "docker ps"            "running containers - also shown in welcome.sh's banner"
fi
if _have fc-list && fc-list 2>/dev/null | grep -qi "nerd font"; then
    _row "Nerd Font symbols"  "installed - eza's icons should render locally"
else
    _row "Nerd Font symbols"  "not found here - eza --icons needs one (see README)"
fi
_row "lint-shell"             "shellcheck + bash/zsh -n on every script (what CI runs)"
if _have shellcheck; then
    _row "shellcheck <file>"  "run it directly on one script (lint-shell runs it on all of them)"
fi
if _have shfmt; then
    _row "shfmt -d <file>"    "show formatting diff; shfmt -w <file> to apply it"
fi

_section "git ($HOME/.gitconfig aliases)"
_row "git lg / lg0 / lg1"     "graph log, plain / with author+date"
_row "git cmm"                "add -A && commitizen commit"
_row "git ch <branch>"        "checkout"
_row "git psh / pll"          "push / pull"
_row "git rsft / rhrd <n>"    "reset --soft / --hard"
if _have delta; then
    _row "git diff / show"    "rendered through delta (line numbers, navigate mode)"
    _row "  n / N"             "in a delta pager: jump to the next/previous file in the diff"
fi
if _have lazygit; then
    _row "lg"                  "lazygit - stage/unstage, rebase, stash, browse commits"
    _row "  space / c / P"     "stage/unstage the selected item / commit / push"
    _row "  ?"                  "lazygit's own keybind cheat sheet"
fi

_section "GitHub / Gitea (gh, gh-dash, tea)"
if _have gh; then
    _row "gh auth login"      "one-time per box - install.sh can't script an interactive OAuth flow"
    _row "gh pr create/view/list" "open, view, or list pull requests without leaving the terminal"
    _row "gh issue create/list" "same, for issues"
    _row "gh dash"             "TUI dashboard (gh extension) - PRs/issues across repos, one screen"
else
    _row "gh"                  "not installed - install.sh includes it"
fi
if _have tea; then
    _row "tea login add"      "one-time per Gitea instance (e.g. git.00x097.com) - needs a token"
    _row "tea pulls / issues" "list pull requests / issues on the logged-in instance"
else
    _row "tea"                 "not installed - install.sh includes it"
fi

_section "Other"
if _have direnv; then
    _row "direnv allow"       "opt this directory into its .envrc (once, per dir)"
fi
_row "vpn-00x097-connect"     "wg-quick up wg0-00x097"
_row "vpn-00x097-disconnect"  "wg-quick down wg0-00x097"
_row "add-tbs093a-git-id"     "ssh-agent + ssh-add ~/.ssh/git_accesses"
_row "k8s"                    "= kubectl"
if _have k9s; then
    _row "k9"                  "= k9s - interactive K8s TUI"
    _row "  :pods / :svc / :ns" "switch resource view (type the colon command, Enter)"
    _row "  d / l / :q"        "describe / logs for the selected resource / quit"
fi
if _have nvtop; then
    _row "gpu"                 "= nvtop - interactive GPU monitor"
    _row "  q"                  "quit"
fi
if _have mise; then
    _row "mise use <tool>@<ver>" "pin a per-project tool version (opt-in .mise.toml, like direnv)"
    _row "mise install"        "install every version pinned in the current .mise.toml"
fi
_row "install.sh --local"     "full/desktop profile, incl. neovim (default)"
_row "install.sh --server"    "server profile, skips neovim, offers Docker"
_row "install.sh --system"    "also link sshd_config + the MOTD banner (sudo)"
_row "  --docker / --no-docker" "skip the --server Docker prompt, force install/skip instead"
_row "  --neovim / --no-neovim" "force install/skip neovim on either profile, no prompt either way"
_row "  --cloud-provider=X"   "skip that --server prompt, set it non-interactively instead"
_row "  --cloud-provider-color=N" "256-color number (0-255); a custom provider left uncolored gets a random one"
_row "  --server-type=X"      "skip that --server prompt, set it non-interactively instead"
_row "  --server-type-color=N" "256-color number (0-255); a custom type left uncolored gets a random one"
_row "WELCOME_SECTIONS=..."   "login banner: allowlist of pkg,docker,gpu,k8s,services"
_row "NO_COLOR=1"             "login banner (and this command): strip all color"
_row "SERVER_TYPE=DEV|PROD|.." "prompt badge (zsh.config/.zshrc.local, set by install.sh --server)"
_row "SERVER_TYPE_COLOR=N"    "256-color number for a custom SERVER_TYPE label (0-255)"
_row "CLOUD_PROVIDER=AWS|.."   "prompt badge, shows before SERVER_TYPE (same file, same install step)"
_row "CLOUD_PROVIDER_COLOR=N"  "256-color number for a custom CLOUD_PROVIDER label (0-255)"

echo
