#!/usr/bin/env bash
# Runs the exact same checks .github/workflows/lint.yml runs in CI, locally,
# before you push - shellcheck + bash -n over BASH_FILES, zsh -n over
# ZSH_FILES. These two lists are a manual copy of lint.yml's (tmux.conf/
# .gitconfig aren't shell, so they're not in either) - change one, change
# the other, same as palette.zsh/tmux.conf's color numbers.
#
# shfmt, if installed, runs too but only as an informational diff - it's
# not part of lint.yml, so it doesn't fail the run; retrofitting every
# existing script to shfmt's formatting would be a large, separate diff of
# its own, not something this should force on a routine lint pass.
#
# Aliased as `lint-shell` in .zshrc, repo-relative, same pattern as
# help-cmd/tmux-session (not symlinked onto PATH).
set -uo pipefail

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)"
cd "$DOTFILES_DIR" || exit 1

BASH_FILES=(
    install.sh
    make.symlinks.sh
    help-cmd.sh
    help-nvim.sh
    lint-shell.sh
    sshd.ssh.config/welcome.sh
    tmux.config/tmux.session.sh
    tmux.config/status-sys.sh
    zsh.config/install.zsh.plugins.sh
    zsh.config/install.zsh.sh
    bash.config/.bashrc
    bash.config/.bash_profile
    test/welcome-smoke.sh
)
ZSH_FILES=(
    get.package.manager.zsh
    vpn.config/connect.sh
    vpn.config/disconnect.sh
    zsh.config/.zshrc
    zsh.config/palette.zsh
    zsh.config/lambda-00x097.zsh-theme
    sshd.ssh.config/welcome.sh
)

fail=0

if command -v shellcheck >/dev/null 2>&1; then
    echo "==> shellcheck"
    # --severity=warning: see the comment in lint.yml - same reasoning,
    # keep both in sync
    shellcheck --shell=bash --severity=warning "${BASH_FILES[@]}" || fail=1
else
    echo "!! shellcheck not installed - skipping (install.sh --local includes it)"
fi

echo "==> bash -n"
for f in "${BASH_FILES[@]}"; do
    bash -n "$f" || fail=1
done

echo "==> zsh -n"
for f in "${ZSH_FILES[@]}"; do
    zsh -n "$f" || fail=1
done

if command -v shfmt >/dev/null 2>&1; then
    echo "==> shfmt (informational - not a lint.yml gate, doesn't fail this run)"
    shfmt -d "${BASH_FILES[@]}" || echo "   (formatting drift above - shfmt -w <file> to fix)"
fi

if (( fail )); then
    echo "lint-shell: FAILED"
    exit 1
else
    echo "lint-shell: OK"
fi
