#!/bin/bash
# Void Linux login banner: ascii logo (lifted from neofetch's built-in void
# art, see distro.guide/void.linux/README.md for the original capture) +
# htop-style resource meters.
#
# This file is sourced by /etc/profile.d/welcome.sh on every login shell AND
# executed by /etc/updated-motd.d/welcome.sh via run-parts on SSH connect, so
# everything lives inside a function (no top-level exit/return, nothing leaks
# into the interactive shell when sourced).

_welcome_banner() {
    # zsh arrays are 1-indexed by default; KSH_ARRAYS makes them 0-indexed
    # like bash for this function only (LOCAL_OPTIONS auto-reverts it on return).
    [[ -n ${ZSH_VERSION:-} ]] && setopt LOCAL_OPTIONS KSH_ARRAYS 2>/dev/null

    local RESET=$'\e[0m' BOLD=$'\e[1m' DIM=$'\e[2m'
    local GREEN=$'\e[32m' RED=$'\e[31m' YELLOW=$'\e[33m' GRAY=$'\e[38;5;244m'
    local title_color ACCENT
    if [[ ${EUID} -eq 0 ]]; then
        title_color=$RED
        ACCENT=$'\e[38;5;196m'   # neofetch's RED="196" - exact ascii_colors match for root
    else
        title_color=$GREEN
        ACCENT=$'\e[38;5;002m'   # neofetch's GREEN="002" - exact ascii_colors match
    fi

    # Builds one logo line from alternating (color, text) pairs - used for the
    # 4 lines where neofetch's ascii_colors switches between accent/gray
    # mid-line (the shaded "QQQ/WWW" block), captured 1:1 from running the
    # actual upstream neofetch with this repo's original --ascii_colors flags.
    _dual() {
        local out=""
        while (( $# >= 2 )); do
            out+="${1}${BOLD}${2}"
            shift 2
        done
        printf '%s%s' "$out" "$RESET"
    }
    _visible_len() {
        local stripped; stripped=$(printf '%s' "$1" | sed -E 's/\x1b\[[0-9;]*m//g')
        printf '%s' "${#stripped}"
    }

    local -a logo=(
        '                __.;=====;.__'
        '            _.=+==++=++=+=+===;.'
        '             -=+++=+===+=+=+++++=_'
        '        .     -=:`` ``--==+=++==.'
        '       _vi,    `            --+=++++:'
        '      .uvnvi.       _._       -==+==+.'
        '     .vvnvnI`    .;==|==;.     :|=||=|.'
        "$(_dual "$GRAY" '+QmQQm' "$ACCENT" 'pvvnv; ' "$GRAY" '_yYsyQQWUUQQQm #QmQ#' "$ACCENT" ':' "$GRAY" 'QQQWUV$QQm.')"
        "$(_dual "$GRAY" ' -QQWQW' "$ACCENT" 'pvvo' "$GRAY" 'wZ?.wQQQE' "$ACCENT" '==<' "$GRAY" 'QWWQ/QWQW.QQWW' "$ACCENT" '(: ' "$GRAY" 'jQWQE')"
        "$(_dual "$GRAY" "  -\$QQQQmmU'  jQQQ@" "$ACCENT" '+=<' "$GRAY" 'QWQQ)mQQQ.mQQQC' "$ACCENT" '+;' "$GRAY" "jWQQ@'")"
        "$(_dual "$GRAY" '   -$WQ8Y' "$ACCENT" 'nI:   ' "$GRAY" 'QWQQwgQQWV' "$ACCENT" '`' "$GRAY" 'mWQQ.jQWQQgyyWW@!')"
        '     -1vvnvv.     `~+++`        ++|+++'
        '      +vnvnnv,                 `-|==='
        '       +vnvnvns.           .      :=-'
        '        -Invnvvnsi..___..=sv=.     `'
        '          +Invnvnvnnnnnnnnvvnn;.'
        '            ~|Invnvnvvnvvvnnv}+`'
        '               -~|{*l}*|~'
    )
    local logo_width=48

    # --- gather system info ---
    local hostname; hostname=$(uname -n)
    local kernel; kernel=$(uname -r)
    local os_pretty=""
    if [[ -r /etc/os-release ]]; then
        os_pretty=$(. /etc/os-release; echo "$PRETTY_NAME")
    fi
    local shell_name; shell_name=$(basename "${SHELL:-sh}")
    local pkg_count; pkg_count=$(xbps-query -l 2>/dev/null | wc -l)

    local up_secs; up_secs=$(awk '{print int($1)}' /proc/uptime)
    local up_days=$(( up_secs/86400 )) up_hours=$(( (up_secs%86400)/3600 )) up_mins=$(( (up_secs%3600)/60 ))
    local uptime_str="${up_days}d ${up_hours}h ${up_mins}m"

    # CPU load: two /proc/stat samples ~150ms apart, htop-style instantaneous %
    local _cpu u1 n1 s1 i1 w1 irq1 sirq1
    read -r _cpu u1 n1 s1 i1 w1 irq1 sirq1 _ < /proc/stat
    sleep 0.15
    local u2 n2 s2 i2 w2 irq2 sirq2
    read -r _cpu u2 n2 s2 i2 w2 irq2 sirq2 _ < /proc/stat
    local idle1=$((i1+w1)) idle2=$((i2+w2))
    local total1=$((u1+n1+s1+i1+w1+irq1+sirq1)) total2=$((u2+n2+s2+i2+w2+irq2+sirq2))
    local totald=$((total2-total1)) idled=$((idle2-idle1))
    local cpu_pct=0
    (( totald > 0 )) && cpu_pct=$(( (100*(totald-idled))/totald ))
    local cpu_cores; cpu_cores=$(nproc)

    local mem_total mem_used
    read -r mem_total mem_used < <(free -b | awk '/^Mem:/{print $2, $3}')
    local ram_pct=0
    (( mem_total > 0 )) && ram_pct=$(( 100*mem_used/mem_total ))
    local ram_used_h ram_total_h
    ram_used_h=$(numfmt --to=iec --suffix=B --format="%.1f" "$mem_used")
    ram_total_h=$(numfmt --to=iec --suffix=B --format="%.1f" "$mem_total")

    local disk_total disk_used disk_pct_raw
    read -r disk_total disk_used disk_pct_raw < <(df -B1 --output=size,used,pcent / | awk 'NR==2{print $1, $2, $3}')
    local disk_pct=${disk_pct_raw%\%}
    local disk_used_h disk_total_h
    disk_used_h=$(numfmt --to=iec --suffix=B --format="%.1f" "$disk_used")
    disk_total_h=$(numfmt --to=iec --suffix=B --format="%.1f" "$disk_total")

    # --- bar meter, htop style: [colored blocks............] NN% ---
    _meter() {
        local pct=$1 width=$2 color reset=$RESET
        local filled=$(( pct*width/100 ))
        (( filled > width )) && filled=$width
        local empty=$(( width-filled ))
        if   (( pct >= 85 )); then color=$RED
        elif (( pct >= 60 )); then color=$YELLOW
        else color=$GREEN
        fi
        local filled_str="" empty_str=""
        (( filled > 0 )) && filled_str=$(printf '%0.s█' $(seq 1 "$filled"))
        (( empty > 0 )) && empty_str=$(printf '%0.s░' $(seq 1 "$empty"))
        printf '[%s%s%s%s%s%s] %3d%%' "$color" "$filled_str" "$reset" "$DIM" "$empty_str" "$reset" "$pct"
    }

    local bar_width=20
    local cpu_bar; cpu_bar=$(_meter "$cpu_pct" "$bar_width")
    local ram_bar; ram_bar=$(_meter "$ram_pct" "$bar_width")
    local disk_bar; disk_bar=$(_meter "$disk_pct" "$bar_width")

    local user_name; user_name=$(id -un)

    # --- right-hand info block (top-aligned against the logo, like neofetch) ---
    local -a info=(
        "${BOLD}${title_color}${user_name}${RESET}${GRAY}@${hostname}${RESET}"
        "$(printf '%.0s-' $(seq 1 $(( ${#user_name}+${#hostname}+1 ))) )"
        "${BOLD}OS:${RESET}       ${os_pretty}"
        "${BOLD}Kernel:${RESET}   ${kernel}"
        "${BOLD}Uptime:${RESET}   ${uptime_str}"
        "${BOLD}Packages:${RESET} ${pkg_count} (xbps)"
        "${BOLD}Shell:${RESET}    ${shell_name}"
        ""
        "${BOLD}CPU ${RESET} ${cpu_bar} (${cpu_cores} cores)"
        "${BOLD}RAM ${RESET} ${ram_bar} (${ram_used_h}/${ram_total_h})"
        "${BOLD}DISK${RESET} ${disk_bar} (${disk_used_h}/${disk_total_h})"
    )

    # --- render logo + info side by side ---
    # Lines 7-10 (the dense QQQ/WWW block) are pre-colored by _dual above;
    # everything else gets a flat accent-color wrap, matching real neofetch.
    local i line rendered plain_len pad
    for (( i=0; i<${#logo[@]}; i++ )); do
        line="${logo[$i]}"
        if (( i >= 7 && i <= 10 )); then
            rendered="$line"
            plain_len=$(_visible_len "$line")
        else
            rendered="${BOLD}${ACCENT}${line}${RESET}"
            plain_len=${#line}
        fi
        pad=$(( logo_width - plain_len ))
        (( pad < 1 )) && pad=1
        printf '%s' "$rendered"
        printf '%*s' "$pad" ''
        if (( i < ${#info[@]} )); then
            printf '%s' "${info[$i]}"
        fi
        printf '\n'
    done
    echo
}

_welcome_banner
unset -f _welcome_banner
