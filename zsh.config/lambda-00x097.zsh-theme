autoload colors

# use `spectrum_ls` command for getting color scale

export WHITE="251"
export GRAY="244"
export GREEN="002"
export YELLOW="190"
export RED="196"

# Cloud/host provider badge (line 1, before the server-type badge) - set by
# `install.sh --server` into zsh.config/.zshrc.local as $CLOUD_PROVIDER.
# Empty/unset means nothing shown. The 5 known providers get a fixed,
# brand-ish color; anything else (a custom label) reads $CLOUD_PROVIDER_COLOR
# if set (also asked for by install.sh's CUSTOM option), falling back to
# plain gray. Just %F/%f here, no %B/%b - no bold-consistency gotcha to
# work around, unlike _server_type_segment below.
_cloud_provider_segment() {
    [[ -n ${CLOUD_PROVIDER:-} ]] || return
    local color=$GRAY
    case "${(U)CLOUD_PROVIDER}" in
        AWS)     color=208 ;;   # orange
        OVH)     color=33  ;;   # blue
        AZURE)   color=45  ;;   # cyan
        GCP)     color=178 ;;   # gold
        HETZNER) color=202 ;;   # red-orange
        *)       [[ -n ${CLOUD_PROVIDER_COLOR:-} ]] && color=$CLOUD_PROVIDER_COLOR ;;
    esac
    printf '%%F{%s}[%s]%%f ' "$color" "$CLOUD_PROVIDER"
}

# Server-type badge (line 1, between the corner glyph and user@host) - set
# by `install.sh --server` into zsh.config/.zshrc.local as $SERVER_TYPE.
# Empty/unset means nothing shown, same "only if relevant" rule as the
# git/K8s segments below.
_server_type_segment() {
    [[ -n ${SERVER_TYPE:-} ]] || return
    local color=$YELLOW bold=""
    case "${(U)SERVER_TYPE}" in
        PROD) color=$RED; bold="%B" ;;
        DEV)  color=$GREEN ;;
    esac
    # %b isn't a targeted un-bold in zsh - it's a full attribute reset (sgr0),
    # so without restoring %B here it silently kills the ambient bold that
    # PROMPT='%B$(prompt)%b ' applies to the whole prompt, leaving everything
    # after the badge (user@host, the git/K8s line) visibly lighter-weight
    # than the "╭" before it.
    printf '%%F{%s}%s[%s]%%b%%f%%B ' "$color" "$bold" "$SERVER_TYPE"
}

# Git status (3rd prompt line, first segment) - one `git status
# --porcelain=v2 --branch` call, parsed for branch name, ahead/behind
# counts (branch.ab), and modified ("1 "/"2 " lines) vs. untracked ("?"
# lines) counts. Nothing outside a git work tree - status just prints
# nothing to stdout there, so branch stays empty and this returns early.
_git_segment() {
    local branch="" ahead=0 behind=0 modified=0 untracked=0 line=""
    while IFS= read -r line; do
        case "$line" in
            "# branch.head "*)
                branch=${line#\# branch.head }
                ;;
            "# branch.ab "*)
                local rest=${line#\# branch.ab } a="" b=""
                a=${rest%% *}; b=${rest##* }
                ahead=${a#+}; behind=${b#-}
                ;;
            "1 "*|"2 "*) modified=$((modified+1)) ;;
            "?"*)        untracked=$((untracked+1)) ;;
        esac
    done < <(git status --porcelain=v2 --branch 2>/dev/null)
    [[ -n $branch && $branch != "(detached)" ]] || return

    local icon=$'\U0000e702'   # nf-dev-git (Devicons) - part of the slim symbols-only Nerd Font too
    local out="%F{$GRAY}${icon} ${branch}"
    (( ahead > 0 ))      && out+=" ⇡${ahead}"
    (( behind > 0 ))     && out+=" ⇣${behind}"
    (( modified > 0 ))   && out+="%F{$YELLOW} ✚${modified}%F{$GRAY}"
    (( untracked > 0 ))  && out+="%F{$YELLOW} ?${untracked}%F{$GRAY}"
    out+="%f"
    printf '%s' "$out"
}

# K8s context (3rd prompt line, second segment) - read straight out of the
# kubeconfig with awk, no `kubectl` subprocess spawn, so it stays fast on
# every prompt render. Nothing when there's no kubeconfig file.
_k8s_segment() {
    local kubecfg="${KUBECONFIG:-$HOME/.kube/config}"
    [[ -r $kubecfg ]] || return
    local ctx=""
    ctx=$(awk '/^current-context:/{print $2; exit}' "$kubecfg" 2>/dev/null)
    [[ -n $ctx ]] || return

    # nf-md-kubernetes - not confirmed present in every slim Nerd Font
    # build (Material Design Icons is huge). Swap for the plain '☸' (no
    # font needed) if this renders as a tofu box on your terminal.
    local icon=$'\U000f10fe'
    if [[ ${ctx:l} == *prod* ]]; then
        # same %b-is-a-full-reset gotcha as _server_type_segment - restore
        # %B after or this is the last thing on the line and everything
        # past it (nothing, currently, but the next thing added here later)
        # loses the ambient bold silently.
        printf '%%F{%s}%%B%s %s%%b%%f%%B' "$RED" "$icon" "$ctx"
    else
        printf '%%F{%s}%s %s%%f' "$GRAY" "$icon" "$ctx"
    fi
}

prompt() {
    local user_color=$GREEN host_color=$GREEN lambda_color=$GREEN
    if [[ $EUID -eq 0 ]]; then
        user_color=$RED; host_color=$RED; lambda_color=$RED
    fi

    local line1="%F{$GRAY}╭ $(_cloud_provider_segment)$(_server_type_segment)%F{$user_color}%n%F{$GRAY}@%F{$host_color}%M%F{$GRAY}:%~%f"

    local git_seg="" k8s_seg="" mid=""
    git_seg=$(_git_segment)
    k8s_seg=$(_k8s_segment)
    if [[ -n $git_seg || -n $k8s_seg ]]; then
        mid="%F{$GRAY}│%f "
        [[ -n $git_seg ]] && mid+="$git_seg"
        [[ -n $git_seg && -n $k8s_seg ]] && mid+="  "
        [[ -n $k8s_seg ]] && mid+="$k8s_seg"
        mid+=$'\n'
    fi

    printf '%s\n%s%%F{%s}╰ %%F{%s}λ%%f' "$line1" "$mid" "$GRAY" "$lambda_color"
}

# returns 👾 if there are errors, nothing otherwise
return_status() {
   echo "%(?..👾)"
}

PROMPT='%B$(prompt)%b '
