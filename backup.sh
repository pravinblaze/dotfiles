#!/bin/bash

cp ~/.zshrc ./
cp -r ~/.config/nvim/ ./
rm ~/.config/nvim/lazy-lock.json
mkdir tmux
cp ~/.config/tmux/tmux.conf ./tmux/
cp -r ~/.config/alacritty ./

