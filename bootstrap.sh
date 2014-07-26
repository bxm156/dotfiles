#!/bin/bash
ln -s ~/bmarty-dotfiles/oh-my-zsh .oh-my-zsh
ln -s ~/bmarty-dotfiles/zsh .zsh
ln -s ~/.zsh/zshrc .zshrc

ln -s ~/bmarty-dotfiles/vim .vim
ln -s ~/.vim/vimrc .vimrc
vim +PluginInstall +qall

ln -s ~/bmarty-dotfiles/tmux/tmux.conf .tmux.conf

chsh -s /bin/zsh
