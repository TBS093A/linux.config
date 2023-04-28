rm -r ~/.gitconfig 
rm -r ~/.zshrc 
rm -r ~/.oh-my-zsh/themes/lambda-00x097.zsh-theme
rm -r /etc/updated-motd.d/welcome.sh
rm -r /etc/profile.d/welcome.sh
rm -r /etc/ssh/sshd_config
rm -r ~/.config/nvim/init.vim

ln -s $(pwd)/git.config/.gitconfig ~/.gitconfig

ln -s $(pwd)/zsh.config/.zshrc ~/.zshrc
ln -s $(pwd)/zsh.config/lambda-00x097.zsh-theme ~/.oh-my-zsh/themes/lambda-00x097.zsh-theme

ln -s $(pwd)/sshd.ssh.config/welcome.sh /etc/updated-motd.d/welcome.sh
ln -s $(pwd)/sshd.ssh.config/welcome.sh /etc/profile.d/welcome.sh
ln -s $(pwd)/sshd.ssh.config/sshd_config /etc/ssh/sshd_config

ln -s $(pwd)/vim.config/init.vim ~/.config/nvim/init.vim

