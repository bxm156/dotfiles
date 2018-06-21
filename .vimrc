filetype off

source ~/.vim/include/vundle_setup.vim

set nocompatible
set t_Co=256

imap jj <Esc>

"UI
source ~/.vim/include/ui.vim


"Python
source ~/.vim/include/python.vim


"CTags
source ~/.vim/include/ctags.vim

"Swapfiles
set backupdir=~/.vim/backup
set directory=~/.vim/backup

"Disable viminfo for now
set viminfo=""
