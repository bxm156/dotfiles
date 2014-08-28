colorscheme solarized
set background="dark"
set gfn=Monaco:h12
set ruler
set wildmenu
set wildmode=list:longest,full
set previewheight=17
set nostartofline
set noshowcmd
set backspace=2
set report=0
set scrolloff=2
syntax on
set title


set number
set showmatch
set incsearch
set hlsearch
set laststatus=2
set ignorecase
set smartcase
set nobk
set hidden
set cursorline
set showtabline=2

set smartindent
set autoindent
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4

"Window Control
function! CloseQuickfix()
    if(len(getqflist()) <= 1)
        echo "No errors! Yippe!"
        execute ":ccl"
    endif
endfunction
autocmd BufWritePost,FileWritePost *.py call CloseQuickfix()
aug QFClose
    au!
    au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&buftype") == "quickfix"|q|endif
aug END
