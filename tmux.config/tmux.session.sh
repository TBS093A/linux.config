#!/usr/bin/env bash
# Save and restore full tmux state: every pane's cwd and running command,
# each window's exact split layout, and which window/pane was active - not
# just session/window/cwd like the old version. This is what tmux-resurrect
# does; doing it here instead keeps the "own small tool, not a framework"
# philosophy the rest of this repo already follows for prompt/statusbar/MOTD.
#
# You can put `tmux.session.sh save` on a cron job - handy since it's easy
# to forget to save manually before a reboot.
#
# usage:
#   tmux-session save      (dump every session/window/pane to ~/.tmux-session)
#   tmux-session restore   (recreate whatever's in that file)
#
# Limits, same ones tmux-resurrect has: a pane's running command is
# relaunched by name only, no arguments and no in-program state (an editor
# reopens empty, not on the file/line you had open) - anything that's just
# a shell (bash/zsh/sh/fish/csh/...) is left as a fresh shell in its cwd
# instead, since re-running "zsh" would just spawn a nested shell.
set -euo pipefail

SESSION_FILE="$HOME/.tmux-session"

warn() { printf '!! %s\n' "$1" >&2; }

save() {
    local fmt=$'#{session_name}\t#{window_index}\t#{window_name}\t#{window_active}\t#{window_layout}\t#{pane_index}\t#{pane_active}\t#{pane_current_path}\t#{pane_current_command}'
    tmux list-panes -a -F "$fmt" > "$SESSION_FILE"
}

terminal_size() {
    # piping stty straight into awk trips `set -o pipefail` when there's no
    # controlling tty (cron, a non-pty SSH command, ...) since stty itself
    # fails even though awk's half of the pipe is fine with empty input -
    # that would abort the whole restore before it creates anything, so
    # break the pipe and swallow stty's failure explicitly instead
    local size
    size=$(stty size 2>/dev/null) || true
    [[ -n $size ]] || return 0
    awk '{ printf "-x%d -y%d", $2, $1 }' <<< "$size"
}

session_exists() { tmux has-session -t "$1" 2>/dev/null; }
window_exists() { tmux list-windows -t "$1" -F '#{window_index}' 2>/dev/null | grep -qx "$2"; }

restore() {
    [[ -r $SESSION_FILE ]] || { warn "no saved session at $SESSION_FILE - run 'tmux-session save' first"; exit 1; }
    tmux start-server
    local dimensions; dimensions="$(terminal_size)"

    declare -A created_window=()   # "$session:$widx" -> 1 once built by this run
    declare -A window_layout=()    # "$session:$widx" -> its captured layout string
    local -a active_windows=()     # "$session:$widx"
    local -a active_panes=()       # "$session:$widx.$pidx"
    local restored=0

    local session widx wname wactive wlayout pidx pactive pdir pcmd
    while IFS=$'\t' read -r session widx wname wactive wlayout pidx pactive pdir pcmd; do
        [[ -d $pdir ]] || continue
        # skip-list carried over from the old version - scratch windows this
        # user never wants auto-recreated
        [[ $wname == "log" || $wname == "man" ]] && continue

        local key="${session}:${widx}"
        window_layout["$key"]="$wlayout"
        [[ $wactive == 1 ]] && active_windows+=("$key")
        [[ $pactive == 1 ]] && active_panes+=("${key}.${pidx}")

        if [[ -n ${created_window[$key]:-} ]]; then
            # already built this run - one more pane in the same window
            tmux split-window -t "$key" -c "$pdir" \
                || { warn "couldn't split a pane into $key - skipping it"; continue; }
        elif session_exists "$session"; then
            if window_exists "$session" "$widx"; then
                continue   # pre-existing window from before this restore - leave it alone
            fi
            tmux new-window -d -t "${session}:" -n "$wname" -c "$pdir" \
                || { warn "couldn't create window $key - skipping it"; continue; }
            created_window["$key"]=1
            restored=$((restored + 1))
        else
            # shellcheck disable=SC2086  # $dimensions is meant to word-split (-x123 -y45)
            ( cd "$pdir" && tmux new-session -d -s "$session" -n "$wname" -c "$pdir" $dimensions ) \
                || { warn "couldn't create session $session - skipping it"; continue; }
            created_window["$key"]=1
            restored=$((restored + 1))
        fi

        if [[ -n $pcmd ]]; then
            case "$pcmd" in
                *sh|*csh) ;;   # a shell - leave it as a fresh interactive shell in $pdir
                *) tmux send-keys -t "${key}.${pidx}" "$pcmd" Enter ;;
            esac
        fi
    done < "$SESSION_FILE"

    local key
    for key in "${!window_layout[@]}"; do
        [[ -n ${created_window[$key]:-} ]] || continue
        tmux select-layout -t "$key" "${window_layout[$key]}" 2>/dev/null || true
    done

    local w p
    for w in "${active_windows[@]}"; do
        tmux select-window -t "$w" 2>/dev/null || true
    done
    for p in "${active_panes[@]}"; do
        tmux select-pane -t "$p" 2>/dev/null || true
    done

    echo "restored $restored window(s)"
}

case "${1:-}" in
    save | restore) "$1" ;;
    *) echo "valid commands: save, restore" >&2; exit 1 ;;
esac
