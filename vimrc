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
set backspace=2  " make backspace work like in other apps (across lines, etc.)
set clipboard=autoselect,exclude:cons\\|linux,unnamed
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
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
set termencoding=utf-8
set textwidth=100
map f :set formatoptions=tcqa
map F :set formatoptions=tcq

" syntax highlighting stuff
syntax on
map s :syntax on
map S :syntax off

" filetype stuff
filetype on
filetype indent on
filetype plugin on

" indentation stuff
set cindent
set cinoptions=l1,c4,(s,U1,w1,m1,j1,J1)
set cinwords=if,elif,else,for,while,try,except,finally,def,class
set expandtab
set shiftwidth=2
set showbreak=-->
set softtabstop=2
set tabstop=2

" pathogen plugin management stuff
call pathogen#infect()

" matchit stuff
runtime! macros/matchit.vim

" keep window position when switching buffers
if v:version >= 700
  au BufLeave * let b:winview = winsaveview()
  au BufEnter * if(exists('b:winview')) | call winrestview(b:winview) | endif
endif

" auto-save certain file types whenever leaving insert mode
"au InsertLeave *.rb :write
"au InsertLeave *.html :write
"au InsertLeave *.erb :write
"au InsertLeave *.js :write
"au InsertLeave *.css :write

" settings for folding
set foldmethod=indent  " foldmethod options: manual|indent|marker
set foldlevel=1000  " starting fold level; high number for all open; 0 for all closed

" theme stuff
set t_Co=256
colorscheme blackburn
set cursorline
highlight CursorLine cterm=none gui=none ctermbg=236 guibg=236

" autoclose plugin stuff
let g:AutoClosePairs = {'(': ')', '{': '}', '[': ']'}
let g:AutoCloseProtectedRegions = ["Character"]

" ack.vim plugin stuff
map <Leader>f :Ack! 

" Indent Guides plugin stuff
let g:indent_guides_auto_colors = 0
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
hi IndentGuidesOdd ctermbg = 233
hi IndentGuidesEven ctermbg = 235

" indexer plugin stuff
let g:indexer_disableCtagsWarning=1

" tagbar plugin stuff
let g:tagbar_left = 1
let g:tagbar_sort = 0
let g:tagbar_autofocus = 1
let g:tagbar_autoclose = 1
map <Leader>t :TagbarToggle

" buffer explorer plugin stuff
let g:bufExplorerSortBy='number'     " Sort by the buffer's number.
let g:bufExplorerShowRelativePath=1  " Show relative paths.
