#!/bin/bash
git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
ln -s ~/bmarty-dotfiles/zsh .zsh

rm -fr ~/.zshrc
ln -s ~/.zsh/zshrc .zshrc


ln -s ~/bmarty-dotfiles/vim .vim
ln -s ~/.vim/vimrc .vimrc
vim +PluginInstall +qall

ln -s ~/bmarty-dotfiles/git/gitconfig .gitconfig
ln -s ~/bmarty-dotfiles/ctags .ctags

mkdir ~/.env

chsh -s /bin/zsh
