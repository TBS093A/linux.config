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
    local title_color="" ACCENT=""
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

    # CPU load: two full /proc/stat samples ~150ms apart, htop-style instantaneous
    # % for both the aggregate line and each individual core (used below for the
    # per-core tree breakdown).
    local stat1="" stat2=""
    stat1=$(cat /proc/stat)
    sleep 0.15
    stat2=$(cat /proc/stat)

    _cpu_pct_from_fields() {
        # args: u1 n1 s1 i1 w1 irq1 sirq1 u2 n2 s2 i2 w2 irq2 sirq2
        local u1=$1 n1=$2 s1=$3 i1=$4 w1=$5 irq1=$6 sirq1=$7
        local u2=$8 n2=$9 s2=${10} i2=${11} w2=${12} irq2=${13} sirq2=${14}
        local idle1=$((i1+w1)) idle2=$((i2+w2))
        local total1=$((u1+n1+s1+i1+w1+irq1+sirq1)) total2=$((u2+n2+s2+i2+w2+irq2+sirq2))
        local totald=$((total2-total1)) idled=$((idle2-idle1))
        local pct=0
        (( totald > 0 )) && pct=$(( (100*(totald-idled))/totald ))
        printf '%s' "$pct"
    }

    local _name="" u1=0 n1=0 s1=0 i1=0 w1=0 irq1=0 sirq1=0
    read -r _name u1 n1 s1 i1 w1 irq1 sirq1 _ <<< "$(awk '/^cpu /{print;exit}' <<< "$stat1")"
    local u2=0 n2=0 s2=0 i2=0 w2=0 irq2=0 sirq2=0
    read -r _name u2 n2 s2 i2 w2 irq2 sirq2 _ <<< "$(awk '/^cpu /{print;exit}' <<< "$stat2")"
    local cpu_pct; cpu_pct=$(_cpu_pct_from_fields "$u1" "$n1" "$s1" "$i1" "$w1" "$irq1" "$sirq1" "$u2" "$n2" "$s2" "$i2" "$w2" "$irq2" "$sirq2")
    local cpu_cores; cpu_cores=$(nproc)

    local -a core_pct=()
    while read -r _name u1 n1 s1 i1 w1 irq1 sirq1 _; do
        [[ $_name =~ ^cpu[0-9]+$ ]] || continue
        read -r _ u2 n2 s2 i2 w2 irq2 sirq2 _ <<< "$(awk -v c="$_name" '$1==c{print;exit}' <<< "$stat2")"
        core_pct+=("$(_cpu_pct_from_fields "$u1" "$n1" "$s1" "$i1" "$w1" "$irq1" "$sirq1" "$u2" "$n2" "$s2" "$i2" "$w2" "$irq2" "$sirq2")")
    done <<< "$stat1"

    # load average, colored per-window relative to core count (same thresholds as the bars)
    local load1="" load5="" load15=""; read -r load1 load5 load15 _ < /proc/loadavg
    _load_color() {
        local ratio; ratio=$(awk -v l="$1" -v c="$cpu_cores" 'BEGIN{printf "%d", (l/c)*100}')
        if   (( ratio >= 100 )); then printf '%s' "$RED"
        elif (( ratio >= 70 ));  then printf '%s' "$YELLOW"
        else printf '%s' "$GREEN"
        fi
    }
    local load1_color; load1_color=$(_load_color "$load1")
    local load5_color; load5_color=$(_load_color "$load5")
    local load15_color; load15_color=$(_load_color "$load15")

    # pending xbps updates - dry run against locally cached repodata (no network sync)
    local update_count; update_count=$(xbps-install -un 2>/dev/null | grep -c .)
    local update_color=$GREEN
    (( update_count > 0 )) && update_color=$YELLOW

    # active logged-in sessions
    local -a sessions=()
    while IFS= read -r wline; do
        [[ -n $wline ]] && sessions+=("$wline")
    done < <(who 2>/dev/null)

    # LAN IPv4 addresses (skip docker/veth bridges and link-local addresses)
    local -a ips=()
    while IFS= read -r iline; do
        local iface="" addr=""
        iface=$(awk '{print $2}' <<< "$iline")
        addr=$(awk '{print $4}' <<< "$iline")
        addr=${addr%%/*}
        case "$iface" in docker*|veth*|br-*) continue ;; esac
        [[ $addr == 169.254.* ]] && continue
        ips+=("${iface}: ${addr}")
    done < <(ip -4 -o addr show scope global 2>/dev/null)

    # running docker containers (works without sudo only if the user is in the docker group)
    local -a containers=()
    if command -v docker >/dev/null 2>&1; then
        while IFS= read -r cline; do
            [[ -n $cline ]] && containers+=("$cline")
        done < <(docker ps --format '{{.Names}}' 2>/dev/null)
    fi

    # runit service health - only meaningful (and readable) as root
    local -a bad_services=()
    if [[ ${EUID} -eq 0 ]]; then
        local svc="" svc_name="" svc_status=""
        for svc in /var/service/*; do
            [[ -e $svc ]] || continue
            svc_name=$(basename "$svc")
            svc_status=$(sv status "$svc" 2>/dev/null)
            [[ $svc_status == run:* ]] || bad_services+=("$svc_name")
        done
    fi

    local mem_total=0 mem_used=0
    read -r mem_total mem_used < <(free -b | awk '/^Mem:/{print $2, $3}')
    local ram_pct=0
    (( mem_total > 0 )) && ram_pct=$(( 100*mem_used/mem_total ))
    local ram_used_h="" ram_total_h=""
    ram_used_h=$(numfmt --to=iec --suffix=B --format="%.1f" "$mem_used")
    ram_total_h=$(numfmt --to=iec --suffix=B --format="%.1f" "$mem_total")

    local disk_total=0 disk_used=0 disk_pct_raw=""
    read -r disk_total disk_used disk_pct_raw < <(df -B1 --output=size,used,pcent / | awk 'NR==2{print $1, $2, $3}')
    local disk_pct=${disk_pct_raw%\%}
    local disk_used_h="" disk_total_h=""
    disk_used_h=$(numfmt --to=iec --suffix=B --format="%.1f" "$disk_used")
    disk_total_h=$(numfmt --to=iec --suffix=B --format="%.1f" "$disk_total")

    # --- bar meter, htop style: [colored blocks............] NN% ---
    _meter() {
        local pct=$1 width=$2 color="" reset=$RESET
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
        printf '[%s%s%s%s%s%s] %s%3d%%%s' "$color" "$filled_str" "$reset" "$DIM" "$empty_str" "$reset" "$color" "$pct" "$reset"
    }

    local bar_width=20
    local cpu_bar; cpu_bar=$(_meter "$cpu_pct" "$bar_width")
    local ram_bar; ram_bar=$(_meter "$ram_pct" "$bar_width")
    local disk_bar; disk_bar=$(_meter "$disk_pct" "$bar_width")

    local user_name; user_name=$(id -un)

    # separator dashes alternate gray/accent, one at a time
    local sep_len=$(( ${#user_name}+${#hostname}+1 )) sep="" j=0
    for (( j=0; j<sep_len; j++ )); do
        if (( j % 2 == 0 )); then
            sep+="${GRAY}-"
        else
            sep+="${ACCENT}-"
        fi
    done
    sep+="$RESET"

    # tree branch glyph: "├─" for every item but the last, "└─" for the last
    _branch() {
        local idx=$1 count=$2
        if (( idx == count-1 )); then printf '└─'; else printf '├─'; fi
    }

    # --- right-hand info block (top-aligned against the logo, like neofetch) ---
    # label = accent (root/user color), value = dark gray; CPU/RAM/DISK meters
    # keep their own threshold color (green/yellow/red) on the percentage.
    local -a info=(
        "${BOLD}${title_color}${user_name}${RESET}${GRAY}@${hostname}${RESET}"
        "$sep"
        "${BOLD}${ACCENT}OS:${RESET}       ${GRAY}${os_pretty}${RESET}"
        "${BOLD}${ACCENT}Kernel:${RESET}   ${GRAY}${kernel}${RESET}"
        "${BOLD}${ACCENT}Uptime:${RESET}   ${GRAY}${uptime_str}${RESET}"
        "${BOLD}${ACCENT}Packages:${RESET} ${GRAY}${pkg_count} (xbps)${RESET}"
        "${BOLD}${ACCENT}Updates:${RESET}  ${update_color}${update_count}${RESET}"
        "${BOLD}${ACCENT}Shell:${RESET}    ${GRAY}${shell_name}${RESET}"
        ""
        "${BOLD}${ACCENT}CPU ${RESET} ${cpu_bar} ${GRAY}(${cpu_cores} cores)${RESET}"
        "${BOLD}${ACCENT}RAM ${RESET} ${ram_bar} ${GRAY}(${ram_used_h}/${ram_total_h})${RESET}"
        "${BOLD}${ACCENT}DISK${RESET} ${disk_bar} ${GRAY}(${disk_used_h}/${disk_total_h})${RESET}"
    )

    local n=0 k=0

    if [[ ${EUID} -eq 0 ]]; then
        info+=("")
        if (( ${#bad_services[@]} > 0 )); then
            info+=("${BOLD}${RED}Services DOWN:${RESET}")
            n=${#bad_services[@]}
            for (( k=0; k<n; k++ )); do
                info+=("${RED}$(_branch "$k" "$n") ${bad_services[$k]}${RESET}")
            done
        else
            info+=("${BOLD}${ACCENT}Services:${RESET} ${GREEN}all running${RESET}")
        fi
    fi

    # --- Load / Sessions / IP / Docker: printed full-width in columns below
    # the logo instead of squeezed into the narrow side-by-side info column ---
    local -a load_col=() sessions_col=() ip_col=() docker_col=()

    load_col+=("${BOLD}${ACCENT}Load${RESET}")
    load_col+=("${GRAY}1m ${RESET} ${load1_color}${load1}${RESET}")
    load_col+=("${GRAY}5m ${RESET} ${load5_color}${load5}${RESET}")
    load_col+=("${GRAY}15m${RESET} ${load15_color}${load15}${RESET}")
    n=${#core_pct[@]}
    for (( k=0; k<n; k++ )); do
        load_col+=("${GRAY}$(_branch "$k" "$n") core${k} $(_meter "${core_pct[$k]}" 8)${RESET}")
    done

    sessions_col+=("${BOLD}${ACCENT}Sessions:${RESET} ${GRAY}${#sessions[@]}${RESET}")
    n=${#sessions[@]}
    for (( k=0; k<n; k++ )); do
        local wuser="" wtty="" wdate="" wtime="" wfrom=""
        read -r wuser wtty wdate wtime wfrom <<< "${sessions[$k]}"
        sessions_col+=("${GRAY}$(_branch "$k" "$n") ${wuser}@${wtty}${RESET}")
    done

    ip_col+=("${BOLD}${ACCENT}IP${RESET}")
    n=${#ips[@]}
    for (( k=0; k<n; k++ )); do
        ip_col+=("${GRAY}$(_branch "$k" "$n") ${ips[$k]}${RESET}")
    done

    if command -v docker >/dev/null 2>&1; then
        docker_col+=("${BOLD}${ACCENT}Docker:${RESET} ${GRAY}${#containers[@]}${RESET}")
        n=${#containers[@]}
        for (( k=0; k<n; k++ )); do
            docker_col+=("${GRAY}$(_branch "$k" "$n") ${containers[$k]}${RESET}")
        done
    fi

    echo
    printf '%s%s%s\n' "$GRAY" "────────────────────────────────────────────────────────" "$RESET"
    echo

    # --- render logo + info side by side ---
    # Lines 7-10 (the dense QQQ/WWW block) are pre-colored by _dual above;
    # everything else gets a flat accent-color wrap, matching real neofetch.
    # The info column can run longer than the 18-line logo (services block),
    # so the loop covers whichever is longer.
    local max_lines=${#logo[@]}
    (( ${#info[@]} > max_lines )) && max_lines=${#info[@]}

    local i=0 line="" rendered="" plain_len=0 pad=0
    for (( i=0; i<max_lines; i++ )); do
        if (( i < ${#logo[@]} )); then
            line="${logo[$i]}"
            if (( i >= 7 && i <= 10 )); then
                rendered="$line"
                plain_len=$(_visible_len "$line")
            else
                rendered="${BOLD}${ACCENT}${line}${RESET}"
                plain_len=${#line}
            fi
        else
            rendered=""
            plain_len=0
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

    # --- Load / Sessions / IP / Docker, side by side in columns under the logo ---
    local w_load=0 w_sessions=0 w_ip=0 w_docker=0 cell="" cell_len=0
    for cell in "${load_col[@]}"; do cell_len=$(_visible_len "$cell"); (( cell_len > w_load )) && w_load=$cell_len; done
    for cell in "${sessions_col[@]}"; do cell_len=$(_visible_len "$cell"); (( cell_len > w_sessions )) && w_sessions=$cell_len; done
    for cell in "${ip_col[@]}"; do cell_len=$(_visible_len "$cell"); (( cell_len > w_ip )) && w_ip=$cell_len; done
    for cell in "${docker_col[@]}"; do cell_len=$(_visible_len "$cell"); (( cell_len > w_docker )) && w_docker=$cell_len; done

    local col_rows=${#load_col[@]}
    (( ${#sessions_col[@]} > col_rows )) && col_rows=${#sessions_col[@]}
    (( ${#ip_col[@]} > col_rows )) && col_rows=${#ip_col[@]}
    (( ${#docker_col[@]} > col_rows )) && col_rows=${#docker_col[@]}

    local r=0 col_pad=0
    for (( r=0; r<col_rows; r++ )); do
        cell="${load_col[$r]:-}"; cell_len=$(_visible_len "$cell"); col_pad=$(( w_load - cell_len + 2 )); (( col_pad < 2 )) && col_pad=2
        printf '%s' "$cell"; printf '%*s' "$col_pad" ''

        cell="${sessions_col[$r]:-}"; cell_len=$(_visible_len "$cell"); col_pad=$(( w_sessions - cell_len + 2 )); (( col_pad < 2 )) && col_pad=2
        printf '%s' "$cell"; printf '%*s' "$col_pad" ''

        cell="${ip_col[$r]:-}"; cell_len=$(_visible_len "$cell"); col_pad=$(( w_ip - cell_len + 2 )); (( col_pad < 2 )) && col_pad=2
        printf '%s' "$cell"; printf '%*s' "$col_pad" ''

        cell="${docker_col[$r]:-}"
        printf '%s\n' "$cell"
    done
    echo

    if (( disk_pct >= 90 )); then
        printf '%s%s⚠ WARNING: disk / at %s%% capacity!%s\n\n' "$BOLD" "$RED" "$disk_pct" "$RESET"
    fi

    local year; year=$(date +%Y)
    printf '%s%s%s\n' "$GRAY" "────────────────────────────────────────────────────────" "$RESET"
    printf '%s%s© %s TBS093A%s %s· %s · linux.config dotfiles%s\n' "$BOLD" "$ACCENT" "$year" "$RESET" "$GRAY" "$hostname" "$RESET"
}

_welcome_banner
# bash (unlike a real nested scope) defines helper functions declared inside
# _welcome_banner as GLOBAL functions the moment it runs - unset every one of
# them here or they leak into the interactive shell on every login.
unset -f _welcome_banner _dual _visible_len _meter _cpu_pct_from_fields _load_color _branch
