source /root/linux.config/plugins

for plugin in ${ZSH_INIT_PLUGINS[@]}; do
    git clone https://github.com/zsh-users/${ plugin }.git
done