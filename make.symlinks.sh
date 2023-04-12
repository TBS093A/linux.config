ln -s $(pwd)/.gitconfig ~/.gitconfig

ln -s $(pwd)/.zshrc ~/.zshrc
ln -s $(pwd)/lambda-00x097.zsh-theme ~/.oh-my-zsh/themes/lambda-00x097.zsh-theme

ln -s $(pwd)/welcome.sh /etc/updated-motd.d/welcome.sh
ln -s $(pwd)/welcome.sh /etc/profile.d/welcome.sh

ln -s $(pwd)/sshd_config /etc/ssh/sshd_config