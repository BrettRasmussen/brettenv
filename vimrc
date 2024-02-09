" Whenever in vim, see all current settings like this:
"   :set all
" To display any part of the current environment, check out:
"   https://vim.fandom.com/wiki/Displaying_the_current_Vim_environment

" path for vim to find anything in the filesystem
set runtimepath=~/.brettenv/vim,~/.vim,/var/lib/vim/addons,/usr/local/Cellar/neovim/0.4.4_2/share/nvim/runtime,/usr/share/vim/vimfiles,/usr/share/vim/vim72,/usr/share/vim/vimfiles/after,/var/lib/vim/addons/after,~/.vim/after,~/.brettenv/vim/after,$VIMRUNTIME

" remap leader key to comma so I can be like JD
let mapleader=','

" Needed towards the top of vimrc for the match-up plugin, which should override matchit.
let g:loaded_matchit = 1

" theme stuff - at top so what's below can override
set t_Co=256
colorscheme blackburn
set cursorline
highlight CursorLine cterm=none gui=none ctermbg=236
highlight MatchParen cterm=none gui=none ctermbg=8

" vi compatibility stuff
if &cp | set nocp | endif
let s:cpo_save=&cpo
set cpo&vim

" basic settings
let &cpo=s:cpo_save
unlet s:cpo_save
set backspace=2  " make backspace work like in other apps (across lines, etc.)
set clipboard=unnamed
" set clipboard=autoselect,exclude:cons\\|linux,unnamed
set fileencodings=ucs-bom,utf-8,default,latin1
set guicursor=a:blinkon0
set guifont=DejaVu\ Sans\ Mono\ 8
set guioptions=airm
set helplang=en
set hidden
set ignorecase
set incsearch
set number
set scrolloff=5
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
set termencoding=utf-8
set nojoinspaces

" status/command lines
set laststatus=2  "show always
set statusline=%F\ %m\%r\%y\ buf:%n\%=line:\%l\/\%L\ (%p%%)\ col:%c
" set ruler
set showmode

" an easier escape with a quick jk together in insert mode
inoremap jk <Esc>

" Map delete key to escape (useful for kinesis keyboard).
noremap <Del> <Esc>

" change from here to underscore
nnoremap <Leader>u ct_

" ctrl plus j/k (vim down/up) does bigger up/down jumps
let g:BASH_Ctrl_j = 'off'
let g:BASH_Ctrl_k = 'off'
nnoremap <C-j> <C-d>
nnoremap <C-k> <C-u>

" alt plus j/k scrolls up and down
nnoremap <M-j> <C-e>
nnoremap <M-k> <C-y>

" Textwidth stuff: alt plus 7/8/9/0 sets textwidth to the size as shown below. Default: 100.
nnoremap <M-7> :set tw=0<CR>
nnoremap <M-8> :set tw=80<CR>
nnoremap <M-9> :set tw=100<CR>
nnoremap <M-0> :set tw=120<CR>
set textwidth=100

" alt-/ unhighlights search results
nnoremap <M-/> :noh<CR>

" Allow going up and down in the middle of wrapped lines.
nnoremap j gj
nnoremap k gk

" Select everything with alt-a.
nnoremap <M-a> 1GVG

" Hitting hyphen jumps to end of line (single-character convenience).
nnoremap - $

" Quick enabling/disabling of auto-formatting paragraphs.
nnoremap <M-f> :set formatoptions=tcqa<CR>
nnoremap <M-F> :set formatoptions=tcq<CR>

" gV to reselect what was just pasted
nnoremap <expr> gV    "`[".getregtype(v:register)[0]."`]"

" split window stuff ---------
" If in a huge terminal, show 120 chars wide (124 in order to allow for line
" numbers); otherwise, split 70/30. Currently not working in neovim because
" &columns appears not to get set by the time of setting &winwidth.
"let &winwidth = &columns > 160 ? 124 : &columns * 7 / 10
let &winwidth = 124

" F3 to toggle paste mode
set pastetoggle=<F3>

" Syntax highlighting stuff: default on, easy on/off with alt-s/S.
syntax on
nnoremap <M-s> :syntax on<CR>
nnoremap <M-S> :syntax off<CR>

" customize tabline
" function adapted from Weibing Chen's answer on
" https://stackoverflow.com/questions/35448357/how-to-let-vim-tabs-not-display-full-file-path-and-only-display-relative-folders
if exists("+showtabline")
  function MyTabLine()
    let s = ''
    let t = tabpagenr()
    let i = 1
    while i <= tabpagenr('$')
      let buflist = tabpagebuflist(i)
      let winnr = tabpagewinnr(i)
      let s .= '%' . i . 'T'
      let s .= (i == t ? '%1*' : '%2*')
      let s .= (i == t ? '%#TabLineSel#' : '%#TabLine#')
      let file = bufname(buflist[winnr - 1])
      let file = fnamemodify(file, ':p:t')
      if file == ''
        let file = '[No Name]'
      endif
      let file = ' ' . i . '-' . file
      let s .= file
      let s .= ' '
      let i = i + 1
    endwhile
    let s .= '%T%#TabLineFill#%='
    let s .= (tabpagenr('$') > 1 ? '%999XX' : 'X')
    return s
  endfunction
  set stal=1
  set tabline=%!MyTabLine()

  highlight TabLineFill cterm=none ctermfg=Black ctermbg=Black
  highlight TabLine cterm=none ctermfg=Gray ctermbg=Black
  highlight TabLineSel cterm=none ctermfg=White ctermbg=DarkGray
endif

" ctrl plus h/l (vim left/right) cycles through open tabs
" ctrl-n/m moves tabs
noremap <M-y> :tabp<CR>
noremap <M-o> :tabn<CR>
noremap <M-n> :tabmove -<CR>
noremap <M-m> :tabmove +<CR>

" <Leader>3 jumps between two most recent tabs
au TabLeave * let g:lasttab = tabpagenr()
nnoremap <silent> <Leader>3 :exe "tabn ".g:lasttab<cr>
vnoremap <silent> <Leader>3 :exe "tabn ".g:lasttab<cr>

" filetype stuff
filetype on
" filetype indent on
filetype plugin on

" explicitly set fileype based on extension
" autocmd BufRead,BufNewFile *.hbs setlocal filetype=html

" indentation stuff ---------
" To see settings relevant to indentation:
"   :verbose set ai? cin? cink? cino? si? inde? indk?
" Don't forget filetype indentation, which might be turned on somewhere you're
" not aware of. Can be disabled (bottom of vimrc to be sure):
"   :set filetype indent off
" Worth looking it up to understand it:
"   :help ftplugin
" Plugins and vimrc can set indentexpr, that sometimes is set and causing indent
" behavoirs, but less frequently mentioned on the web:
"   :help indentexpr
" Can write custom indent plugins that use indentexpr.
" Don't forget about indentkeys! It's the list of keys that cause the current
"   line to get reindented.
" If having indentation headaches, read this stuff:
"   https://vim.fandom.com/wiki/How_to_stop_auto_indenting
"   https://vim.fandom.com/wiki/Indenting_source_code
"   https://www.serverwatch.com/tutorials/article.php/3845506/Automatic-Indenting-With-Vim.htm
"   https://thoughtbot.com/blog/writing-vim-syntax-plugins
"   http://psy.swansea.ac.uk/staff/carter/vim/vim_indent.htm
"   google: vim auto indent
"   google: vim indent
set autoindent " also note if 'filetype indent on' is set somewhere
set indentexpr=""
set indentkeys=''
set expandtab
set shiftwidth=2
set showbreak=-->
set softtabstop=2
set tabstop=2
" The following customizes the 'cindent' option, which requires 'set cindent'
" instead of 'set autoindent'
"set cinoptions=l1,c4,(s,U1,w1,m1,j1,J1)
"set cinwords=if,elif,else,for,while,try,except,finally,def,class

" vim-plug plugin manager. After adding a plugin to this list, restart vim and
" run :PlugInstall.
call plug#begin('~/.brettenv/vim/plugged')
Plug 'tomtom/tcomment_vim'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'jlanzarotta/bufexplorer'
Plug 'easymotion/vim-easymotion'
Plug 'vim-scripts/ShowTrailingWhitespace'
Plug 'vim-scripts/DeleteTrailingWhitespace'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'majutsushi/tagbar'
Plug 'elixir-editors/vim-elixir'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'andymass/vim-matchup'
Plug 'mileszs/ack.vim'
Plug 'mustache/vim-mustache-handlebars'
Plug 'mattn/emmet-vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
call plug#end()

" vim-vsnip plugin stuff
" Where snippets are located.
let g:vsnip_snippet_dir = '~/.brettenv/vim/snippets'
" Expand
imap <expr> <Tab>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<Tab>'
smap <expr> <Tab>   vsnip#expandable()  ? '<Plug>(vsnip-expand)'         : '<Tab>'
" Expand or jump
" imap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
" smap <expr> <C-l>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'
" imap <expr> <Tab>   vsnip#available(1)   ? '<Plug>(vsnip-expand-or-jump)'  : '<Tab>'
" smap <expr> <Tab>   vsnip#available(1)   ? '<Plug>(vsnip-expand-or-jump)'  : '<Tab>'
" Jump forward or backward
imap <expr> <C-j>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<C-j>'
smap <expr> <C-j>   vsnip#jumpable(1)   ? '<Plug>(vsnip-jump-next)'      : '<C-j>'
imap <expr> <C-k> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<C-k>'
smap <expr> <C-k> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<C-k>'
" Select or cut text to use as $TM_SELECTED_TEXT in the next snippet.
" See https://github.com/hrsh7th/vim-vsnip/pull/50
nmap        s   <Plug>(vsnip-select-text)
xmap        s   <Plug>(vsnip-select-text)
nmap        S   <Plug>(vsnip-cut-text)
xmap        S   <Plug>(vsnip-cut-text)
" If you want to use snippet for multiple filetypes, you can `g:vsnip_filetypes` for it.
let g:vsnip_filetypes = {}
let g:vsnip_filetypes.javascriptreact = ['javascript']
let g:vsnip_filetypes.typescriptreact = ['typescript']
let g:vsnip_filetypes.vue = ['vue', 'javascript', 'html']

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

" ack.vim plugin stuff (leave the trailing space)
nnoremap <Leader>f :Ack! 

" Indent Guides plugin stuff
let g:indent_guides_auto_colors = 0
let g:indent_guides_enable_on_vim_startup = 1
let g:indent_guides_start_level = 2
let g:indent_guides_guide_size = 1
function SetIndentGuidesStyles()
  hi IndentGuidesOdd ctermbg = 233
  hi IndentGuidesEven ctermbg = 235
endfunction
nnoremap <F5> :call SetIndentGuidesStyles()<CR>
call SetIndentGuidesStyles()

" indexer plugin stuff
let g:indexer_disableCtagsWarning=1

" tagbar plugin stuff
let g:tagbar_left = 1
let g:tagbar_sort = 0
let g:tagbar_autofocus = 1
let g:tagbar_autoclose = 1
nnoremap <Leader>n :TagbarToggle<CR>

let g:tagbar_type_ruby = {
    \ 'kinds' : [
        \ 'm:modules',
        \ 'c:classes',
        \ 'd:describes',
        \ 'C:contexts',
        \ 'f:methods',
        \ 'F:singleton methods'
    \ ]
\ }
let g:tagbar_type_elixir = {
    \ 'ctagstype' : 'elixir',
    \ 'kinds' : [
        \ 'f:functions',
        \ 'functions:functions',
        \ 'c:callbacks',
        \ 'd:delegates',
        \ 'e:exceptions',
        \ 'i:implementations',
        \ 'a:macros',
        \ 'o:operators',
        \ 'm:modules',
        \ 'p:protocols',
        \ 'r:records',
        \ 't:tests'
    \ ]
\ }

" FZF plugin stuff
set runtimepath+=/usr/local/opt/fzf
function! s:find_git_root()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction
command! ProjectFiles execute 'FZF' s:find_git_root()
nnoremap <Leader>t :ProjectFiles<CR>

" buffer explorer plugin stuff
let g:bufExplorerSortBy='fullpath'     " Sort by the buffer's number.
let g:bufExplorerShowRelativePath=1  " Show relative paths.

" vim session stuff
nnoremap SQ <ESC>:mksession!<CR>:wqa<CR>
" For some reason, session reload loses IndentGuides styles, so we reset them explicitly.
nnoremap SR <ESC>:source Session.vim<CR>:call SetIndentGuidesStyles()<CR>

" EasyMotion plugin stuff
let g:EasyMotion_leader_key = '\'

" UltiSnips plugin stuff
let g:UltiSnipsSnippetDirectories = ["UltiSnips", "my_ultisnips"]

" Emmet plugin stuff
let g:user_emmet_leader_key = ',e'

" match-up plugin stuff
let g:matchup_matchparen_enabled = 0
nnoremap <Leader>m :DoMatchParen<CR>
nnoremap <Leader>M :NoMatchParen<CR>

" DeleteTrailingWhitespace plugin stuff
let g:DeleteTrailingWhitespace_Action = 'ask'
nnoremap <Leader>d :<C-u>%DeleteTrailingWhitespace<CR>
vnoremap <Leader>d :DeleteTrailingWhitespace<CR>
highlight ShowTrailingWhitespace ctermbg=Magenta guibg=Magenta

" rails.vim plugin stuff
let g:rails_no_abbreviations = 1 " don't need their snippets since I have snipMate

" tcomment plugin stuff
let g:tcomment_opleader1 = ',c'

" format XML via python3
com! FormatXML :%!python3 -c "import xml.dom.minidom, sys; print(xml.dom.minidom.parse(sys.stdin).toprettyxml())"
nnoremap = :FormatXML<CR>
