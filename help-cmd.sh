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
    _row "fkill"                "fuzzy-pick a process (by CPU), confirm, kill -9 it"
else
    _row "fzf"                 "not installed - Ctrl-R/T, Alt-C, fco, fkill need it"
fi

_section "tmux"
_row "tmux-session"           "save/restore the current tmux session (script)"
_row "prefix + | / -"         "split pane vertically / horizontally"
_row "prefix + h/j/k/l"       "move between panes (vim-style)"
_row "prefix + H/J/K/L"       "resize the current pane (vim-style)"
_row "prefix + r"             "reload tmux.conf"
_row "copy-mode: v / y"       "vi-style: start selection / copy and exit"
_row "mouse"                  "click to select pane, drag to resize, scroll for copy-mode"

_section "Neovim (vim.config/init.vim)"
if _have nvim; then
    _row "nvim <file>"        "nvim-tree, bufferline, lualine, treesitter, telescope"
    _row "Ctrl-b"             "toggle the file tree (NvimTree)"
    _row "Ctrl-s"             "save and close the buffer"
    _row "Alt-t"              "toggle a terminal pane (ToggleTerm)"
    _row "Alt-, / Alt-."      "previous / next buffer"
    _row "Alt-1..9 / Alt-0"   "jump to buffer 1-9 / last"
    _row "Alt-c"              "close current buffer"
    _row ":Telescope find_files" "fuzzy file finder - no keybind, run as a command"
    _row ":Telescope live_grep"  "fuzzy grep across the project"
else
    _row "nvim"                "not installed - install.sh --local includes it"
fi

_section "Also on this box (install.sh)"
_row "curl"                   "installed, no alias - plain curl"
_row "openconnect"            "installed for vpn.config/connect.sh (SSL VPN)"
_row "wireguard-tools"        "installed for the vpn-00x097-* aliases (wg-quick)"
if _have fc-list && fc-list 2>/dev/null | grep -qi "nerd font"; then
    _row "Nerd Font symbols"  "installed - eza's icons should render locally"
else
    _row "Nerd Font symbols"  "not found here - eza --icons needs one (see README)"
fi

_section "git ($HOME/.gitconfig aliases)"
_row "git lg / lg0 / lg1"     "graph log, plain / with author+date"
_row "git cmm"                "add -A && commitizen commit"
_row "git ch <branch>"        "checkout"
_row "git psh / pll"          "push / pull"
_row "git rsft / rhrd <n>"    "reset --soft / --hard"

_section "Other"
if _have direnv; then
    _row "direnv allow"       "opt this directory into its .envrc (once, per dir)"
fi
_row "vpn-00x097-connect"     "wg-quick up wg0-00x097"
_row "vpn-00x097-disconnect"  "wg-quick down wg0-00x097"
_row "k8s"                    "= kubectl"
_row "install.sh --local"     "full/desktop profile, incl. neovim (default)"
_row "install.sh --server"    "server profile, skips neovim, offers Docker"
_row "install.sh --system"    "also link sshd_config + the MOTD banner (sudo)"
_row "WELCOME_SECTIONS=..."   "login banner: allowlist of pkg,docker,gpu,k8s,services"
_row "NO_COLOR=1"             "login banner (and this command): strip all color"

echo
