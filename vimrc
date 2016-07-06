set term=xterm
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim
map! <S-Insert> <MiddleMouse>
"map [3~ 
"imap [3~ 
"map / y:let @z = escape('^R"', '$*.^~[]\')<CR>/^Rz<CR>
map u ct_

"ctrl plus h/j/k/l (vim left/right) cycles through open file buffers or jumps to
"first/last open buffer
map <C-h> :bp<CR>
map <C-j> :bl<CR>
map <C-k> :bf<CR>
map <C-l> :bn<CR>

"alt plus 7/8/9/0 set textwidth size
map 7 :set tw=0<CR>
map 8 :set tw=80<CR>
map 9 :set tw=100<CR>
map 0 :set tw=120<CR>
set textwidth=120

"an easier escape with a quick jk together in insert mode
inoremap jk <Esc>

map o O<CR>j
"map ? :s/^\/\///g<CR>
"map / :s/^/\/\//g<CR>
"map # :s/^#//g<CR>
"map 3 :s/^/#/g<CR>
map a 1GVG
noremap - $
vmap [% [%m'gv``
vmap ]% ]%m'gv``
vmap a% [%v]%
nmap gx <Plug>NetrwBrowseX
map j gj
map k gk
nnoremap <silent> <Plug>NetrwBrowseX :call netrw#NetBrowseX(expand("<cWORD>"),0)<CR>
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
set number
set runtimepath=~/.brettenv/vim,~/.vim,/var/lib/vim/addons,/usr/share/vim/vimfiles,/usr/share/vim/vim72,/usr/share/vim/vimfiles/after,/var/lib/vim/addons/after,~/.vim/after,~/.brettenv/vim/after,$VIMRUNTIME
set scrolloff=5
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
set termencoding=utf-8
map f :set formatoptions=tcqa<CR>
map F :set formatoptions=tcq<CR>

" split window stuff ---------
" If in a huge terminal, show 120 chars wide (124 in order to allow for line
" numbers); otherwise, split 70/30.
let &winwidth = &columns > 160 ? 124 : &columns * 7 / 10

" F3 to toggle paste mode
set pastetoggle=<F3>

" syntax highlighting stuff
syntax on
map s :syntax on<CR>
map S :syntax off<CR>

" filetype stuff
filetype on
filetype indent on
filetype plugin on

" indentation stuff
set autoindent " also note if "filetype indent on" is set somewhere
set expandtab
set shiftwidth=2
set showbreak=-->
set softtabstop=2
set tabstop=2
" The following customizes the "cindent" option, which requires "set cindent"
" instead of "set autoindent"
"set cinoptions=l1,c4,(s,U1,w1,m1,j1,J1)
"set cinwords=if,elif,else,for,while,try,except,finally,def,class

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
highlight MatchParen cterm=none gui=none ctermbg=8 guibg=8

" remap leader key to comma so I can be like JD
let mapleader=','

" ack.vim plugin stuff
map <Leader>f :Ack!

" Indent Guides plugin stuff
let g:indent_guides_auto_colors = 0
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
function SetIndentGuidesStyles()
  hi IndentGuidesOdd ctermbg = 233
  hi IndentGuidesEven ctermbg = 235
endfunction
map <F5> :call SetIndentGuidesStyles()<CR>
call SetIndentGuidesStyles()

" indexer plugin stuff
let g:indexer_disableCtagsWarning=1

" tagbar plugin stuff
let g:tagbar_left = 1
let g:tagbar_sort = 0
let g:tagbar_autofocus = 1
let g:tagbar_autoclose = 1
map <Leader>n :TagbarToggle<CR>

" CtrlP plugin stuff
map <Leader>t :CtrlPMixed<CR>
let g:ctrlp_by_filename = 1
let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:25,results:25'
let g:ctrlp_user_command = "find %s -type f | egrep -v '/\.(git|hg|svn|gem)|solr|tmp/' | egrep -v '\.(png|exe|jpg|gif|jar|class|swp|swo|log|gitkep|keepme|so|o)$'"

" buffer explorer plugin stuff
let g:bufExplorerSortBy='fullpath'     " Sort by the buffer's number.
let g:bufExplorerShowRelativePath=1  " Show relative paths.

" AutoClose plugin stuff
"let g:AutoClosePairs = {'(': ')', '{': '}', '[': ']'}
let g:AutoClosePairs = {}  " effectively disables autoclose for now

" vim session stuff
nmap SQ <ESC>:mksession!<CR>:wqa<CR>
" For some reason, session reload loses IndentGuides styles, so we reset them explicitly.
nmap SR <ESC>:source Session.vim<CR>:call SetIndentGuidesStyles()<CR>

" EasyMotion plugin stuff
let g:EasyMotion_leader_key = '\'

" snipMate plugin stuff
let g:snips_author = 'Brett Rasmussen'

" DeleteTrailingWhitespace plugin stuff
let g:DeleteTrailingWhitespace_Action = 'ask'
nnoremap <Leader>d :<C-u>%DeleteTrailingWhitespace<CR>
vnoremap <Leader>d :DeleteTrailingWhitespace<CR>
highlight ShowTrailingWhitespace ctermbg=Magenta guibg=Magenta

" rails.vim plugin stuff
let g:rails_no_abbreviations = 1 " don't need their snippets since I have snipMate

" xml-plugin (xmledit) stuff
let xml_tag_completion_map = "<C-l>"

" tcomment plugin stuff
let g:tcommentMapLeaderOp1 = ',c'
