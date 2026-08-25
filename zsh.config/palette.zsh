# Single source of truth for the "house" 256-color palette: welcome.sh's
# gray labels + green (root: red) accent. Sourced by .zshrc, which derives
# LS_COLORS/EZA_COLORS, FZF_DEFAULT_OPTS, and BAT_THEME from it below, so
# ls/eza, fzf, and bat read as the same theme as the login banner instead
# of each picking their own defaults. tmux.conf can't source this (it's
# not shell), so its statusbar hardcodes the same numbers directly -
# change a value here, change it there too.

export PALETTE_GRAY=244    # labels, borders, secondary text
export PALETTE_ACCENT=2    # regular user accent (green)
export PALETTE_ACCENT_ROOT=196  # root accent (red)
export PALETTE_RED=1
export PALETTE_YELLOW=3

# root gets the red accent everywhere, matching welcome.sh's own EUID check
if [[ ${EUID} -eq 0 ]]; then
    PALETTE_ACCENT=$PALETTE_ACCENT_ROOT
fi

# classic dircolors syntax (di=directory, ln=symlink, ex=executable) -
# eza falls back to this for its base file-type coloring; plain ls/GNU
# coreutils read it directly too. Appended, not prepended: LS_COLORS
# resolves duplicate keys last-wins, so ours have to come after whatever
# default the system already set to actually take effect.
export LS_COLORS="${LS_COLORS:-}:di=38;5;${PALETTE_ACCENT}:ln=38;5;${PALETTE_GRAY}:ex=38;5;${PALETTE_ACCENT}"

if command -v fzf >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="--color=fg:-1,fg+:-1,bg:-1,bg+:-1 --color=hl:${PALETTE_ACCENT},hl+:${PALETTE_ACCENT} --color=pointer:${PALETTE_ACCENT},marker:${PALETTE_ACCENT} --color=prompt:${PALETTE_ACCENT},info:${PALETTE_GRAY},border:${PALETTE_GRAY} --color=header:${PALETTE_GRAY}"
fi

if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    # "ansi" renders through the terminal's own 16-color ANSI palette
    # instead of a fixed theme, so it inherits whatever green/gray this
    # terminal is already using - no hardcoded hex to keep in sync
    export BAT_THEME="ansi"
fi
