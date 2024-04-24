
cp ./.zshrc ~/
mkdir -p ~/.oh-my-zsh/custom/plugins/themes/
cp ./.oh-my-zsh/custom/themes/my.zsh-theme ~/.oh-my-zsh/custom/plugins/themes/
cp -r ./.config/nvim/ ~/.config
mkdir -p ~/.config/tmux/
cp ./.config/tmux/tmux.conf ~/.config/tmux/
mkdir -p ~/.config/alacritty
cp -r ./.config/alacritty ~/.config

