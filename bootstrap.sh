#!/bin/bash
if [ ! -d "$HOME/.zgen" ]; then
    git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
fi

ln -s ~/bmarty-dotfiles/zsh .zsh
ln -s ~/bmarty-dotfiles/vim .vim

ln -s ~/.zsh/zshrc .zshrc
ln -s ~/.vim/vimrc .vimrc


vim +PluginInstall +qall

ln -s ~/bmarty-dotfiles/git/gitconfig .gitconfig
ln -s ~/bmarty-dotfiles/ctags .ctags

chsh -s /bin/zsh
/bin/zsh
