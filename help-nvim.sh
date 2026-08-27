#!/usr/bin/env bash
# Prints the Neovim-specific rundown: keybindings and startup behavior for
# everything vim.config/init.vim wires up (avante.nvim, the 4-pane startup
# layout, barbar/NvimTree/gitgutter/jedi-vim/etc). Split out of help-cmd.sh
# once the nvim section grew past a quick glance - help-cmd's "Also on this
# box" section points here instead of listing all of it inline.
#
# Aliased as `help-nvim` via .zshrc (see make.symlinks.sh) - repo-relative,
# not installed onto PATH, same pattern as help-cmd/tmux-session.

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

if ! command -v nvim >/dev/null 2>&1; then
    printf '%s%shelp-nvim%s %s- nvim not installed here%s\n' "$BOLD" "$ACCENT" "$RESET" "$DIM" "$RESET"
    printf '  install.sh --local includes it (or --neovim on --server)\n\n'
    exit 0
fi

printf '%s%shelp-nvim%s %s- Neovim keybindings/behavior (vim.config/init.vim)%s\n' "$BOLD" "$ACCENT" "$RESET" "$DIM" "$RESET"

_section "Startup layout"
_row "opens automatically"  "terminal (bottom split) -> tree (left) -> avante (right sidebar)"
_row "cursor lands in"      "the editor - focus is restored there after all three open"

_section "Moving between panes (tree / editor / terminal / avante)"
_row "Ctrl-w h/j/k/l"      "move to the pane left/down/up/right (nvim default, works everywhere)"
_row "Ctrl-w w"            "cycle through all panes"
_row "in the terminal"     "Ctrl-\\ Ctrl-n first - terminal mode eats Ctrl-w otherwise"
_row "\\af"                 "jump straight to/from avante's sidebar, from anywhere"
_row "Tab / Shift-Tab"     "in avante's sidebar: switch between its own chat/files/input panes"
_row "Ctrl-w F"            "jump straight to the file tree - opens it first if it's closed"
_row "Ctrl-w T"            "jump straight to the terminal - opens it first if it's closed"
_row "Ctrl-w C"            "jump straight to avante (its input if open, else its chat)"
_row "Ctrl-w E"            "jump to the editor - the first (top-left) split, if there are several"
_row "Ctrl-w E1..E9"       "jump to that specific editor split, same top-left-to-bottom-right order"

_section "Buffers/tabs (barbar.nvim)"
_row "Ctrl-s"              "save and close the buffer"
_row "Alt-, / Alt-."       "previous / next buffer"
_row "Alt-< / Alt->"       "move current buffer left / right"
_row "Alt-1..9 / Alt-0"    "jump to buffer 1-9 / last"
_row "Alt-p"               "pin the current buffer"
_row "Alt-c"               "close current buffer"
_row "Alt-Shift-c"         "restore last closed buffer"
_row "Ctrl-p"              "pick a buffer to delete (BufferPickDelete)"
_row "Space-b b/d/l/w"     "reorder buffers: by number/dir/language/window"

_section "File tree (NvimTree, Ctrl-b toggles, opens on startup)"
_row "H / I"               "toggle hidden files / gitignored files"
_row "a"                   "add a file (or folder, trailing /)"
_row "Ctrl-r"              "rename"
_row "d / x / c / p"       "delete / cut / copy / paste"
_row "y / Y / g y"         "copy name / relative path / absolute path"
_row "Enter / Tab"         "open / open keeping cursor in the tree"
_row "Ctrl-t"              "open in a new tab"
_row "Ctrl-v"              "open in a vertical split"
_row "Ctrl-x"              "open in a horizontal split"

_section "Terminal (ToggleTerm, opens on startup) + multi-cursor (vim-visual-multi)"
_row "Alt-t"               "toggle a terminal pane (normal + insert mode)"
_row "Ctrl-t (in terminal)" "toggle the terminal back off"
_row "Ctrl-\\ Ctrl-n"      "exit terminal mode (nvim default)"
_row "Ctrl-n"              "select word under cursor (or selection, in visual)"
_row "Ctrl-Down / Ctrl-Up" "add cursors vertically down / up (normal mode)"
_row "Q"                   "remove a cursor/region (normal mode)"
_row "n / N / q"           "next / previous / skip cursor (normal mode)"
_row "\\\\A"                "select all occurrences of the word"
_row "\\\\/"                "create cursors from a regex search"
_row "\\\\\\"               "add a single cursor at the current position"
_row "\\\\gS"               "reselect regions from the last session"
_row "Ctrl-LeftMouse"      "add a cursor where clicked"
_row "Ctrl-RightMouse"     "select the word where clicked"
_row "Alt-Ctrl-RightMouse" "create a column of cursors from here to where clicked"
_row "Esc"                 "exit multi-cursor mode"

_section "Clipboard, completion, formatting"
_row "Shift-RightClick+drag+Enter" "copy selection to the host/Windows clipboard"
_row "Ctrl-Shift-V"        "paste from the host/Windows clipboard"
_row "Ctrl-Space"          "Jedi completion - needs :set nopaste first"
_row "on save (:w)"        "auto-formats + strips trailing whitespace (not Makefiles)"
_row ":Telescope find_files" "fuzzy file finder - no keybind, run as a command"
_row ":Telescope live_grep"  "fuzzy grep across the project"

_section "Code navigation (jedi-vim, tagbar - Python-aware)"
_row "\\d"                  "go to definition"
_row "\\g"                  "go to assignment"
_row "\\n"                  "show usages"
_row "\\r"                  "rename (all usages)"
_row "K"                    "show documentation for what's under the cursor"
_row ":TagbarToggle"        "ctags outline sidebar (classes/functions in the file) - no keybind"

_section "Git diff in the sign column (vim-gitgutter)"
_row "]c / [c"             "jump to the next / previous changed hunk"
_row "\\hs"                 "stage the hunk under the cursor"
_row "\\hu"                 "undo (revert) the hunk under the cursor"
_row "\\hp"                 "preview the hunk's diff in a popup"

_section "Alignment + snippets (vim-easy-align, UltiSnips)"
_row "ga<motion/selection>" "interactive align on a character, e.g. gaip= aligns = signs in the paragraph"
_row "Tab"                  "expand a snippet trigger, or jump to the next placeholder"
_row "Ctrl-j / Ctrl-k"      "jump to the next / previous snippet placeholder"

_section "AI (avante.nvim - Cursor-style ask/edit, opens on startup)"
_row "\\aa"                 "open the AI sidebar and ask a question"
_row "\\at"                 "toggle the sidebar"
_row "\\ae"                 "edit the selected code (visual mode) - returns a diff"
_row "co / ct / ca"        "in a diff: choose ours / theirs / all theirs"
_row "\\a?"                 "pick a model for the current provider"
_row ":AvanteSwitchProvider claude|openai|grok" "switch which one you're talking to"
_row "ANTHROPIC/OPENAI/XAI_API_KEY" "set in zsh.config/.zshrc.local, not tracked (see .example)"
_row "first install"       "builds in the background - \$XDG_CACHE_HOME/nvim/avante-nvim-build.log if \\aa errors right away"

echo
