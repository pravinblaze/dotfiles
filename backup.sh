#!/bin/bash

cp ~/.zshrc ./
mkdir -p .oh-my-zsh/custom/plugins/themes/
cp ~/.oh-my-zsh/custom/themes/my.zsh-theme ./
cp -r ~/.config/nvim/ ./
rm nvim/lazy-lock.json
mkdir -p tmux
cp ~/.config/tmux/tmux.conf ./tmux/
cp -r ~/.config/alacritty ./

