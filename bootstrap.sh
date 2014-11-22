#!/bin/bash
(cd ~/bmarty-dotfiles && git submodule init && git submodule update)

ln -s ~/bmarty-dotfiles/oh-my-zsh .oh-my-zsh
ln -s ~/bmarty-dotfiles/zsh .zsh
ln -s ~/.zsh/zshrc .zshrc

ln -s ~/bmarty-dotfiles/vim .vim
ln -s ~/.vim/vimrc .vimrc
vim +PluginInstall +qall

ln -s ~/bmarty-dotfiles/tmux/tmux.conf .tmux.conf

ln -s ~/bmarty-dotfiles/git/gitconfig .gitconfig
ln -s ~/bmarty-dotfiles/ctags .ctags

chsh -s /bin/zsh
