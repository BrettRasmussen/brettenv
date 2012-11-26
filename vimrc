if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
imap <Del> 
map! <S-Insert> <MiddleMouse>
map 6 :set tw=0
map 7 :set tw=80
map 8 :set tw=100
map [3~ 
imap [3~ 
map / y:let @z = escape('^R"', '$*.^~[]\')/^Rz
map u ct_

"alt plus h/l (vim left/right) cycles through open file buffers
map <M-h> :bp
map <M-l> :bn
map h :bp
map l :bn

map o Oj
map ? :s/^\/\///g
map / :s/^/\/\//g
map # :s/^#//g
map 3 :s/^/#/g
map a 1GVG
noremap - $
vmap [% [%m'gv``
vmap ]% ]%m'gv``
vmap a% [%v]%
nmap gx <Plug>NetrwBrowseX
map j gj
map k gk
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetBrowseX(expand("<cWORD>"),0)
map <Del> 
map <S-Insert> <MiddleMouse>

let &cpo=s:cpo_save
unlet s:cpo_save
set autoindent
set backspace=2
set clipboard=autoselect,exclude:cons\\|linux,unnamed
set expandtab
set fileencodings=ucs-bom,utf-8,default,latin1
set guicursor=a:blinkon0
set guifont=DejaVu\ Sans\ Mono\ 8
set guioptions=airm
set helplang=en
set hidden
set ignorecase
set incsearch
set printoptions=paper:letter
set ruler
set runtimepath=~/.brettenv/vim,~/.vim,/var/lib/vim/addons,/usr/share/vim/vimfiles,/usr/share/vim/vim72,/usr/share/vim/vimfiles/after,/var/lib/vim/addons/after,~/.vim/after,~/.brettenv/vim/after,$VIMRUNTIME
set scrolloff=5
set shiftwidth=2
set showbreak=-->
set softtabstop=2
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
set tabstop=2
set termencoding=utf-8
set textwidth=100
map f :set formatoptions=tcqa
map F :set formatoptions=tcq

filetype plugin on
syntax on
map s :syntax on
map S :syntax off

runtime! macros/matchit.vim

" settings for folding
set foldmethod=indent  " foldmethod options: manual|indent|marker
set foldlevel=1000  " starting fold level; high number for all open; 0 for all closed

" theme stuff
set t_Co=256
colorscheme blackburn
set cursorline
highlight CursorLine cterm=none gui=none ctermbg=236 guibg=236

" ack.vim stuff
map <Leader>f :Ack! 

" Indent Guides plugin stuff
let g:indent_guides_auto_colors = 0
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
hi IndentGuidesOdd ctermbg = 233
hi IndentGuidesEven ctermbg = 235

" taglist plugin stuff
let Tlist_Exit_OnlyWindow = 1
let Tlist_GainFocus_On_ToggleOpen = 1
let Tlist_Close_On_Select = 1
map <Leader>t :TlistToggle

