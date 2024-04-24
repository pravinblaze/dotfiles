#!/bin/bash

cp ~/.zshrc ./
mkdir -p ./.oh-my-zsh/custom/themes/
cp ~/.oh-my-zsh/custom/themes/my.zsh-theme ./.oh-my-zsh/custom/themes/
cp -r ~/.config/nvim/ ./
rm nvim/lazy-lock.json
mkdir -p ./.config/tmux/
cp ~/.config/tmux/tmux.conf ./.config/tmux/
mkdir -p ./.config/alacritty/
cp -r ~/.config/alacritty ./.config

