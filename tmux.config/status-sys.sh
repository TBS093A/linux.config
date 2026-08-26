#!/usr/bin/env bash
# CPU/RAM/GPU for the tmux statusbar (status-right), refreshed once per
# `status-interval` tick (see tmux.conf) instead of tmux shelling out to
# nvidia-smi/proc every second. CPU/RAM always print - GPU is dual-vendor
# detected the same way welcome.sh's login banner does (NVIDIA nvidia-smi /
# AMD amdgpu sysfs) and only appended when a card is actually found, so the
# segment just doesn't reserve space on a box without one.
set -euo pipefail

RED=$'\033[38;5;196m'; YELLOW=$'\033[38;5;3m'; GREEN=$'\033[38;5;2m'
GRAY=$'\033[38;5;244m'; RESET=$'\033[0m'

_pct_color() {
    local pct=$1
    if   (( pct >= 85 )); then printf '%s' "$RED"
    elif (( pct >= 60 )); then printf '%s' "$YELLOW"
    else printf '%s' "$GREEN"
    fi
}

# CPU%: one /proc/stat snapshot compared against the previous tick's,
# cached in a tmpfile - a statusbar refreshing every few seconds doesn't
# need welcome.sh's 150ms double-sample, just something to diff against.
_cpu_pct() {
    local cache="${TMPDIR:-/tmp}/.tmux-status-sys-cpu"
    local u=0 n=0 s=0 i=0 w=0 irq=0 sirq=0
    read -r _ u n s i w irq sirq _ < /proc/stat

    local pu=0 pn=0 ps=0 pi=0 pw=0 pirq=0 psirq=0
    [[ -r $cache ]] && read -r pu pn ps pi pw pirq psirq < "$cache"
    printf '%s %s %s %s %s %s %s\n' "$u" "$n" "$s" "$i" "$w" "$irq" "$sirq" > "$cache"

    local idle1=$((pi+pw)) idle2=$((i+w))
    local total1=$((pu+pn+ps+pi+pw+pirq+psirq)) total2=$((u+n+s+i+w+irq+sirq))
    local totald=$((total2-total1)) idled=$((idle2-idle1))
    (( totald <= 0 )) && { printf '0'; return; }
    printf '%s' $(( (100*(totald-idled))/totald ))
}

cpu_pct=$(_cpu_pct)
read -r mem_total mem_used < <(free -b | awk '/^Mem:/{print $2, $3}')
ram_pct=0
(( mem_total > 0 )) && ram_pct=$(( 100*mem_used/mem_total ))

out="${GRAY}CPU $(_pct_color "$cpu_pct")${cpu_pct}%${RESET} ${GRAY}RAM $(_pct_color "$ram_pct")${ram_pct}%${RESET}"

gpu_busy="" gpu_used=0 gpu_total=0
if command -v nvidia-smi >/dev/null 2>&1; then
    IFS=',' read -r gpu_busy gpu_used gpu_total < <(nvidia-smi \
        --query-gpu=utilization.gpu,memory.used,memory.total \
        --format=csv,noheader,nounits 2>/dev/null | head -1)
    gpu_busy=${gpu_busy# }; gpu_used=${gpu_used# }; gpu_total=${gpu_total# }
else
    for gdev in /sys/class/drm/card*/device; do
        [[ -r $gdev/gpu_busy_percent ]] || continue
        gpu_busy=$(<"$gdev/gpu_busy_percent")
        if [[ -r $gdev/mem_info_vram_used && -r $gdev/mem_info_vram_total ]]; then
            gpu_used=$(( $(<"$gdev/mem_info_vram_used") / 1048576 ))
            gpu_total=$(( $(<"$gdev/mem_info_vram_total") / 1048576 ))
        fi
        break
    done
fi

if [[ -n $gpu_busy ]]; then
    gpu_used_g=$(awk -v u="$gpu_used" 'BEGIN{printf "%.0f", u/1024}')
    gpu_total_g=$(awk -v t="$gpu_total" 'BEGIN{printf "%.0f", t/1024}')
    out+=" ${GRAY}GPU $(_pct_color "$gpu_busy")${gpu_busy}%${RESET} ${GRAY}${gpu_used_g}/${gpu_total_g}G${RESET}"
fi

printf '%s' "$out"
