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
    local GREEN=$'\e[32m' RED=$'\e[31m' YELLOW=$'\e[33m'
    local logo_color
    if [[ ${EUID} -eq 0 ]]; then
        logo_color=$'\e[1;31m'
    else
        logo_color=$'\e[1;32m'
    fi

    local -a logo=(
        '                __.;=====;.__'
        '            _.=+==++=++=+=+===;.'
        '             -=+++=+===+=+=+++++=_'
        '        .     -=:`` ``--==+=++==.'
        '       _vi,    `            --+=++++:'
        '      .uvnvi.       _._       -==+==+.'
        '     .vvnvnI`    .;==|==;.     :|=||=|.'
        '+QmQQmpvvnv; _yYsyQQWUUQQQm #QmQ#:QQQWUV$QQm.'
        ' -QQWQWpvvowZ?.wQQQE==<QWWQ/QWQW.QQWW(: jQWQE'
        '  -$QQQQmmU`  jQQQ@+=<QWQQ)mQQQ.mQQQC+;jWQQ@`'
        '   -$WQ8YnI:   QWQQwgQQWV`mWQQ.jQWQQgyyWW@!'
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
        "${BOLD}${GREEN}${user_name}${RESET}@${BOLD}${GREEN}${hostname}${RESET}"
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
    local i line plain_len pad
    for (( i=0; i<${#logo[@]}; i++ )); do
        line="${logo[$i]}"
        plain_len=${#line}
        pad=$(( logo_width - plain_len ))
        (( pad < 1 )) && pad=1
        printf '%s%s%s' "$logo_color" "$line" "$RESET"
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
