"Map ENV and current directory
map <F4> :!/usr/local/bin/ctags -R -f ./tags $VIRTUAL_ENV/lib/python2.7/site-packages .<CR>

"Search for tag file in the current directory and up until $HOME
set tags=./tags;$HOME
