DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "$0")")/.." && pwd)"
source "$DOTFILES_DIR/zsh.config/plugins"

for plugin in ${ZSH_INIT_PLUGINS[@]}; do
    git clone https://github.com/zsh-users/$plugin.git
done