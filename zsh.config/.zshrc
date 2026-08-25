# Resolves to the repo root regardless of where it's cloned, by following
# the ~/.zshrc symlink make.symlinks.sh creates back to its source.
DOTFILES_DIR="$(dirname "$(dirname "$(readlink -f "$HOME/.zshrc")")")"

# vpn connectivity commands aliases

alias vpn-00x097-connect='sudo wg-quick up wg0-00x097'
alias vpn-00x097-disconnect='sudo wg-quick down wg0-00x097'

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Host-specific / employer aliases (ssh shortcuts, k8s node queries, etc.)
# live in .zshrc.local (gitignored) - see .zshrc.local.example for the pattern.
[ -f "$DOTFILES_DIR/zsh.config/.zshrc.local" ] && source "$DOTFILES_DIR/zsh.config/.zshrc.local"

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="lambda-00x097"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
source "$DOTFILES_DIR/zsh.config/plugins"
plugins=(${ZSH_INIT_PLUGINS[@]})

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# zoxide: frecency-ranked `cd` (z <partial>, zi for the fzf picker)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# direnv: per-directory env vars from .envrc, opted in with `direnv allow`
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# eza/bat: same info as ls/cat, easier to read. bat ships as `batcat` on
# Debian/Ubuntu (name clash with another package) - alias whichever exists.
if command -v eza >/dev/null 2>&1; then
    alias ls='eza --icons --group-directories-first'
    alias ll='eza --icons --group-directories-first -l'
    alias la='eza --icons --group-directories-first -la'
fi
if command -v bat >/dev/null 2>&1; then
    alias cat='bat --style=plain --paging=never'
elif command -v batcat >/dev/null 2>&1; then
    alias cat='batcat --style=plain --paging=never'
fi

# fzf's file-insert widget (Ctrl-T) previews with bat when it's around
if command -v bat >/dev/null 2>&1 || command -v batcat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview '(bat --color=always --style=numbers --line-range=:500 {} || batcat --color=always --style=numbers --line-range=:500 {}) 2>/dev/null'"
fi

# fco: fuzzy git checkout - pick a local or remote branch
fco() {
    local branch
    branch=$(git branch --all --format='%(refname:short)' 2>/dev/null | sed 's#^origin/##' | sort -u | fzf --height 40% --reverse) || return
    [[ -n $branch ]] && git checkout "$branch"
}

# fkill: fuzzy-pick a process, confirm, kill -9 it
fkill() {
    local pid
    pid=$(ps -eo pid,user,pcpu,pmem,comm --sort=-pcpu | fzf --height 40% --reverse --header-lines=1 | awk '{print $1}') || return
    [[ -n $pid ]] && kill -9 "$pid"
}

alias tmux-session="$DOTFILES_DIR/tmux.config/tmux.session.sh"
alias help-cmd="$DOTFILES_DIR/help-cmd.sh"

alias add-tbs093a-git-id='eval "$(ssh-agent -s)"; ssh-add ~/.ssh/git_accesses'

alias k8s=kubectl

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"


autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/terraform/terraform terraform
