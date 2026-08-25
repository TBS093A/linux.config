#!/usr/bin/env bash
# Smoke test for sshd.ssh.config/welcome.sh: stubs every external command it
# calls (uname, free, df, ss, docker, nvidia-smi, xbps, kubectl, sv) and the
# handful of hardcoded system paths (/proc/stat, /proc/uptime, /proc/loadavg,
# /etc/os-release) it reads directly, then sources the banner under a real
# pty via `script` - not just `bash -c` - because the two regressions this
# guards against (job-control notification spam, and the CPU bar rendering
# empty because it read $cpu_pct before the background job populated it)
# only show up in an actual interactive shell, which `bash -c` doesn't give.
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WELCOME_SRC="$REPO_ROOT/sshd.ssh.config/welcome.sh"

MOCK="$(mktemp -d)"
trap 'rm -rf "$MOCK"' EXIT
mkdir -p "$MOCK/bin" "$MOCK/proc" "$MOCK/etc" "$MOCK/zdotdir"
# an empty (but present) .zshrc stops zsh's newuser-install wizard from
# firing and waiting on stdin - it only checks that an rc file exists
touch "$MOCK/zdotdir/.zshrc"

# --- fake /proc, /etc ---
cat > "$MOCK/etc/os-release" <<'EOF'
PRETTY_NAME="Test Linux"
EOF
echo "123456.00 100000.00" > "$MOCK/proc/uptime"
echo "1.50 1.20 0.90 2/50 12345" > "$MOCK/proc/loadavg"

# two /proc/stat snapshots, 150ms "apart", for 2 cores landing at a known,
# deterministic aggregate/per-core pct (core0 ~75%, core1 ~60%)
python3 - "$MOCK/proc" <<'PYEOF'
import sys
proc = sys.argv[1]
BASE_U, BASE_S, BASE_I = 1_000_000, 500_000, 200_000

def line(name, u, s, i):
    return f"{name}  {u} 0 {s} {i} 0 0 0 0 0 0"

def deltas(pct, totald=1000):
    idled = round(totald * (100 - pct) / 100)
    busyd = totald - idled
    u = int(busyd * 0.6)
    s = busyd - u
    return u, s, idled

core_pcts = [75, 60]
agg_u = agg_s = agg_i = 0
call1, call2 = [], []
for i, pct in enumerate(core_pcts):
    u, s, idl = deltas(pct)
    agg_u += u; agg_s += s; agg_i += idl
    call1.append(line(f"cpu{i}", BASE_U, BASE_S, BASE_I))
    call2.append(line(f"cpu{i}", BASE_U + u, BASE_S + s, BASE_I + idl))

call1.insert(0, line("cpu", BASE_U * len(core_pcts), BASE_S * len(core_pcts), BASE_I * len(core_pcts)))
call2.insert(0, line("cpu", BASE_U * len(core_pcts) + agg_u, BASE_S * len(core_pcts) + agg_s, BASE_I * len(core_pcts) + agg_i))

with open(f"{proc}/stat_call1", "w") as f:
    f.write("\n".join(call1) + "\n")
with open(f"{proc}/stat_call2", "w") as f:
    f.write("\n".join(call2) + "\n")
PYEOF

# --- fake binaries ---
cat > "$MOCK/bin/cat" <<EOF
#!/bin/bash
MOCK_STAT="$MOCK/proc/stat"
MARKER="$MOCK/proc/.stat_call_marker"
if [[ "\$1" == "\$MOCK_STAT" ]]; then
    if [[ -e "\$MARKER" ]]; then rm -f "\$MARKER"; exec /bin/cat "\${MOCK_STAT}_call2"
    else touch "\$MARKER"; exec /bin/cat "\${MOCK_STAT}_call1"
    fi
fi
exec /bin/cat "\$@"
EOF

cat > "$MOCK/bin/uname" <<'EOF'
#!/bin/bash
case "$1" in
    -n) echo "test-node-01" ;;
    -r) echo "1.0.0-test" ;;
    *) /usr/bin/uname "$@" ;;
esac
EOF

cat > "$MOCK/bin/id" <<'EOF'
#!/bin/bash
[[ "$1" == "-un" ]] && echo "testuser" || /usr/bin/id "$@"
EOF

echo '#!/bin/bash
echo 2' > "$MOCK/bin/nproc"

cat > "$MOCK/bin/free" <<'EOF'
#!/bin/bash
echo "              total        used        free"
echo "Mem:    8000000000  4000000000  4000000000"
EOF

cat > "$MOCK/bin/df" <<'EOF'
#!/bin/bash
echo "         Size          Used Use%"
echo "100000000000 95000000000  95%"
EOF

cat > "$MOCK/bin/who" <<'EOF'
#!/bin/bash
echo "testuser pts/0 2026-01-01 00:00 (10.0.0.1)"
EOF

cat > "$MOCK/bin/ip" <<'EOF'
#!/bin/bash
echo "2: eth0    inet 10.0.0.5/24 brd 10.0.0.255 scope global eth0"
EOF

cat > "$MOCK/bin/docker" <<'EOF'
#!/bin/bash
[[ "$1" == "ps" ]] && printf 'web\ndb\n'
EOF

cat > "$MOCK/bin/nvidia-smi" <<'EOF'
#!/bin/bash
echo "Test GPU 0, 87, 1024, 8192"
echo "Test GPU 1, 60, 512, 8192"
EOF

echo '#!/bin/bash
seq 1 50' > "$MOCK/bin/xbps-query"

echo '#!/bin/bash
printf "pkgA\npkgB\n"' > "$MOCK/bin/xbps-install"

cat > "$MOCK/bin/kubectl" <<'EOF'
#!/bin/bash
if [[ "$1" == "get" && "$2" == "node" ]]; then
    [[ "$*" == *"labels"* ]] && echo "map[kubernetes.io/hostname:test-node-01]" || echo "$3"
elif [[ "$1" == "get" && "$2" == "pods" ]]; then
    printf 'pod-a\npod-b\n'
fi
EOF

cat > "$MOCK/bin/ss" <<'EOF'
#!/bin/bash
cat <<'INNER'
tcp   LISTEN 0      128        0.0.0.0:22       0.0.0.0:*    users:(("sshd",pid=1,fd=3))
tcp   LISTEN 0      2048       0.0.0.0:8080     0.0.0.0:*    users:(("webapp",pid=2,fd=4))
INNER
EOF

chmod +x "$MOCK"/bin/*
rm -f "$MOCK/proc/.stat_call_marker"

# --- mocked copy of welcome.sh: every hardcoded system path swapped for the
# fixture above; the real script is never modified ---
MOCKED="$MOCK/welcome_mock.sh"
cp "$WELCOME_SRC" "$MOCKED"
sed -i \
    -e "s#/etc/os-release#$MOCK/etc/os-release#g" \
    -e "s#/proc/uptime#$MOCK/proc/uptime#g" \
    -e "s#/proc/loadavg#$MOCK/proc/loadavg#g" \
    -e "s#/proc/stat#$MOCK/proc/stat#g" \
    "$MOCKED"

fail() { echo "FAIL: $1" >&2; exit 1; }
strip_ansi() { sed -E 's/\x1b\[[0-9;]*m//g'; }

run_banner() {
    # env vars are passed through the quoted inner command so they apply
    # inside the pty's shell, not to `script` itself
    local extra_env="$1"
    rm -f "$MOCK/proc/.stat_call_marker"
    script -qec "PATH='$MOCK/bin:$PATH' ${extra_env} bash --norc -i -c 'source \"$MOCKED\" 2>&1; echo __DONE__'" /dev/null
}

echo "--- default run ---"
out="$(run_banner "")"
plain="$(strip_ansi <<< "$out")"

[[ "$plain" == *"__DONE__"* ]] || fail "banner did not complete"

# regression: cpu_bar (the aggregate "CPU [bar]" in the info panel) must be
# built AFTER cpu_pct is populated by the background job, not before - an
# empty $cpu_pct at build time silently renders as an all-dim, unfilled bar
# instead of erroring, which is exactly what shipped once. Aggregate is 68%
# ((75+60)/2), so the bar must contain a filled block.
cpu_line="$(grep 'CPU .*\[' <<< "$plain" || true)"
[[ -n "$cpu_line" ]] || fail "no aggregate CPU bar line found"
[[ "$cpu_line" == *"█"* ]] || fail "CPU bar rendered empty (stale cpu_pct regression)"

# same class of bug, same fix shape: the per-card GPU aggregate bar
gpu_line="$(grep 'GPU .*\[' <<< "$plain" || true)"
[[ -n "$gpu_line" ]] || fail "no aggregate GPU bar line found"
[[ "$gpu_line" == *"█"* ]] || fail "GPU bar rendered empty (stale gpu_pct regression)"

grep -q "Packages: 50" <<< "$plain" || fail "package count missing"
grep -q "Docker: 2" <<< "$plain" || fail "docker section missing"
grep -q "tcp 22 (sshd)" <<< "$plain" || fail "sshd port with process name missing"
grep -q "tcp 8080 (webapp)" <<< "$plain" || fail "webapp port with process name missing"
grep -q "GPU " <<< "$plain" || fail "GPU meter missing"
grep -q "g0 \[" <<< "$plain" || fail "per-card GPU row missing"
grep -q "K8s Node: test-node-01" <<< "$plain" || fail "k8s node section missing"
grep -q "WARNING: disk / at 95% capacity" <<< "$plain" || fail "disk warning missing at 95%"
echo "OK: default run"

echo "--- WELCOME_SECTIONS= (all optional sections off) ---"
plain="$(strip_ansi <<< "$(run_banner "WELCOME_SECTIONS=''")")"
grep -q "Packages:" <<< "$plain" && fail "Packages shown with WELCOME_SECTIONS="
grep -q "Docker:" <<< "$plain" && fail "Docker shown with WELCOME_SECTIONS="
grep -q "GPU " <<< "$plain" && fail "GPU shown with WELCOME_SECTIONS="
grep -q "K8s Node:" <<< "$plain" && fail "K8s shown with WELCOME_SECTIONS="
echo "OK: WELCOME_SECTIONS= disables every optional section"

echo "--- WELCOME_SECTIONS=docker (only docker on) ---"
plain="$(strip_ansi <<< "$(run_banner "WELCOME_SECTIONS=docker")")"
grep -q "Docker: 2" <<< "$plain" || fail "Docker missing with WELCOME_SECTIONS=docker"
grep -q "Packages:" <<< "$plain" && fail "Packages shown with WELCOME_SECTIONS=docker"
echo "OK: WELCOME_SECTIONS=docker enables only docker"

echo "--- NO_COLOR=1 ---"
out="$(run_banner "NO_COLOR=1")"
if grep -qP '\x1b\[' <<< "$out"; then
    fail "ANSI escape codes present with NO_COLOR=1"
fi
grep -q "Packages: 50" <<< "$out" || fail "content missing with NO_COLOR=1"
echo "OK: NO_COLOR=1 strips all color"

echo "--- zsh: job-control notification regression ---"
# `zsh -i -c '...'` (like `bash -i -c`) exits before zsh ever reaches its own
# "about to print a prompt" point, which is what flushes deferred job-control
# notifications - so it can't reproduce this bug regardless of whether the
# fix is present. Feeding the same commands over stdin to a real interactive
# zsh does reach that point (matching an actual login shell sourcing this
# file from /etc/profile.d before its first prompt), and reliably reproduces
# the exact "[1] PID" / "[1]+ done ..." spam this test guards against.
rm -f "$MOCK/proc/.stat_call_marker"
zout="$(script -qec "PATH='$MOCK/bin:$PATH' ZDOTDIR='$MOCK/zdotdir' zsh -i" /dev/null <<EOF
source "$MOCKED"
echo __DONE__
exit
EOF
)"
zplain="$(strip_ansi <<< "$zout")"
[[ "$zplain" == *"__DONE__"* ]] || fail "zsh: banner did not complete"
if grep -qE '^\[[0-9]+\]( |$)' <<< "$zplain"; then
    fail "zsh: job-control notification leaked into the banner output"
fi
echo "OK: zsh run, no job-control spam"

echo
echo "all welcome.sh smoke tests passed"
