" ~~~ Plugins ~~~
call plug#begin('~/.local/share/nvim/plugged')
" Plug 'shougo/deoplete.nvim'
" Plug 'ctrlpvim/ctrlp.vim'
" Plug 'itchyny/lightline.vim'
" Plug 'tpope/vim-commentary'
" Plug 'tpope/vim-surround'
" Plug 'lambdalisue/suda.vim'
" Plug 'jiangmiao/auto-pairs'
" Plug 'machakann/vim-highlightedyank'
" Plug 'vimwiki/vimwiki'
" Plug 'tpope/vim-markdown'
" Plug 'nelstrom/vim-markdown-folding'
    " assuming you're using vim-plug: https://github.com/junegunn/vim-plug
    "Plug 'ncm2/ncm2'
    "Plug 'roxma/nvim-yarp'

    " NOTE: you need to install completion sources to get completions. Check
    " our wiki page for a list of sources: https://github.com/ncm2/ncm2/wiki
    "Plug 'ncm2/ncm2-bufword'
    "Plug 'ncm2/ncm2-path'
    "Plug 'ncm2/ncm2-pyclang'
    if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  Plug 'Shougo/deoplete-clangx'
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
let g:deoplete#enable_at_startup = 1
call plug#end()


    " enable ncm2 for all buffers
    "autocmd BufEnter * call ncm2#enable_for_buffer()

    " IMPORTANT: :help Ncm2PopupOpen for more information
    "set completeopt=noinsert,menuone,noselect


" Highlight the line on which the cursor lives.
set nocursorline

" Always show at least one line above/below the cursor.
set scrolloff=1
" Always show at least one line left/right of the cursor.
set sidescrolloff=5

" Relative line numbers
set number relativenumber

" Highlight matching pairs of brackets. Use the '%' character to jump between them.
set matchpairs+=<:>

" Display different types of white spaces.
set list
set listchars=tab:›\ ,trail:•,extends:#,nbsp:.

" Use system clipboard
set clipboard=unnamedplus

" Remove timeout for partially typed commands
set notimeout

" F keys
" Quick write session with F2
map <F2> :mksession! ~/.vim_session<cr>
" And load session with F3
map <F3> :source ~/.vim_session<cr>

" Fix indentation
map <F7> gg=G<C-o><C-o>
" Toggle auto change directory
map <F8> :set autochdir! autochdir?<CR>

" Toggle vertical line
set colorcolumn=
fun! ToggleCC()
  if &cc == ''
    " set cc=1,4,21
    set cc=80
  else
    set cc=
  endif
endfun
nnoremap <silent> <F9> :call ToggleCC()<CR>

" Beginning and end of line
imap <C-a> <home>
imap <C-e> <end>
cmap <C-a> <home>
cmap <C-e> <end>

" Control-S Save
nmap <C-S> :w<cr>
vmap <C-S> <esc>:w<cr>
imap <C-S> <esc>:w<cr>
" Save + back into insert
" imap <C-S> <esc>:w<cr>a

" Control-C Copy in visual mode
vmap <C-C> y

" Control-V Paste in insert and command mode
imap <C-V> <esc>pa
cmap <C-V> <C-r>0

" Window Movement
nmap <M-h> <C-w>h
nmap <M-j> <C-w>j
nmap <M-k> <C-w>k
nmap <M-l> <C-w>l

" Resizing
nmap <C-M-H> 2<C-w><
nmap <C-M-L> 2<C-w>>
nmap <C-M-K> <C-w>-
nmap <C-M-J> <C-w>+

" Insert mode movement
imap <M-h> <left>
imap <M-j> <down>
imap <M-k> <up>
imap <M-l> <right>
imap <M-f> <C-right>
imap <M-b> <C-left>

" Spacemacs-like keybinds
" Change <leader> bind from default \
" nnoremap <space> <nop>
" let mapleader=" "

" Make ci( work like quotes do
function! New_cib()
    if search("(","bn") == line(".")
        sil exe "normal! f)ci("
        sil exe "normal! l"
        startinsert
    else
        sil exe "normal! f(ci("
        sil exe "normal! l"
        startinsert
    endif
endfunction

" And for curly brackets
function! New_ciB()
    if search("{","bn") == line(".")
        sil exe "normal! f}ci{"
        sil exe "normal! l"
        startinsert
    else
        sil exe "normal! f{ci{"
        sil exe "normal! l"
        startinsert
    endif
endfunction

nnoremap ci( :call New_cib()<CR>
nnoremap cib :call New_cib()<CR>
nnoremap ci{ :call New_ciB()<CR>
nnoremap ciB :call New_ciB()<CR>

" Alt-m for creating a new line in insert mode
imap <M-m> <esc>o

" netrw configuration
let g:netrw_browse_split = 0
let g:netrw_altfile = 1

" Cycle windows
nmap <M-o> <C-W>w
vmap <M-o> <C-W>w
tmap <M-o> <esc><C-W>w
imap <M-o> <esc><C-W>w

" Command mode history
cmap <M-p> <up>
cmap <M-n> <down>
cmap <M-k> <up>
cmap <M-j> <down>

" Back to normal mode from insert
" inoremap jk <esc>
" inoremap JK <esc>

" Manually refresh file
nmap <F5> :e!<cr>

" Indentation
set smarttab
set expandtab
set tabstop=8
set softtabstop=4
set shiftwidth=4

"set smartindent
set autoindent
"set cindent

set nocompatible
filetype plugin indent on

" Write buffer through sudo (works on vim but not neovim)
" cnoreabbrev w!! w !sudo -S tee % >/dev/null
" Neovim: suda plugin
cnoreabbrev w!! w suda://%

" Allow switching between buffers without saving
set hidden

" Mouse support
set mouse=a

"Case insensitive searching
set ignorecase

"Will automatically switch to case sensitive if you use any capitals
set smartcase

" Auto toggle smart case of for ex commands
" Assumes 'set ignorecase smartcase'
augroup dynamic_smartcase
    autocmd!
    autocmd CmdLineEnter : set nosmartcase
    autocmd CmdLineLeave : set smartcase
augroup END

" Substitute live preview
set inccommand=nosplit

" Markdown Folding
let g:markdown_fold_style = 'nested'

" Vimwiki
" let g:vimwiki_list = [{'path': '~/dox/vimwiki/', 'syntax': 'markdown', 'ext': '.md'}]
let g:vimwiki_global_ext=0
let g:vimwiki_table_mappings=0
let g:vimwiki_folding='expr'
nmap <leader>vv <Plug>VimwikiIndex
nmap <leader>vV <Plug>VimwikiTabIndex
nmap <leader>vs <Plug>VimwikiUISelect
nmap <leader>vi <Plug>VimwikiDiaryIndex
nmap <leader>vdd <Plug>VimwikiMakeDiaryNote
nmap <leader>vDD <Plug>VimwikiTabMakeDiaryNote
nmap <leader>vdy <Plug>VimwikiMakeYesterdayDiaryNote
nmap <leader>vdt <Plug>VimwikiMakeTomorrowDiaryNote
nmap <M-space> <Plug>VimwikiToggleListItem

" Highlighted yank (-1 for persistent)
let g:highlightedyank_highlight_duration = 400

" If lightline/airline is enabled, don't show mode under it
set noshowmode

" Shell
set shell=/bin/zsh

" Ctrlp
let g:ctrlp_switch_buffer = '0'
" Useful for large projects
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=10
" So that it does not only index starting from current directory
let g:ctrlp_working_path_mode = ""
let g:ctrlp_cache_dir = $HOME . '/.cache/ctrlp'
" Use ag AKA the_silver_searcher for indexing. Faster!!!
" TIP: Use ~/.ignore to ignore directories/files
" set grepprg=ag\ --nogroup\ --nocolor
" let g:ctrlp_user_command = 'ag %s -l --hidden --nocolor -g ""'
""if executable('ag')
""  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
""endif
let g:ctrlp_show_hidden =1
let g:ctrlp_clear_cache_on_exit = 0

" Lightline
" Get default from :h lightline
let g:lightline = {
    \ 'colorscheme': 'lena',
    \ }

let g:lightline.active = {
    \ 'left': [ [ 'mode', 'paste', 'sep1' ],
    \           [ 'readonly', 'filename', 'modified' ],
    \           [ ] ],
    \ 'right': [ [ 'lineinfo' ],
    \            [ 'percent' ],
    \            [ 'filetype' ] ]
    \ }

let g:lightline.inactive = {
    \ 'left': [ [ 'mode', 'paste', 'sep1' ],
    \           [ 'readonly', 'filename', 'modified' ] ],
    \ 'right': [ [ 'lineinfo' ],
    \            [ 'percent' ],
    \            [ 'filetype' ] ]
    \ }

let g:lightline.tabline = {
    \ 'left': [ [ 'tabs' ] ],
    \ 'right': [ ] }

let g:lightline.tab = {
    \ 'active': [ 'tabnum', 'filename', 'modified' ],
    \ 'inactive': [ 'tabnum', 'filename', 'modified' ] }

let g:lightline.component = {
    \ 'mode': '%{lightline#mode()}',
    \ 'absolutepath': '%F',
    \ 'relativepath': '%f',
    \ 'filename': '%t',
    \ 'modified': '%M',
    \ 'bufnum': '%n',
    \ 'paste': '%{&paste?"PASTE":""}',
    \ 'readonly': '%R',
    \ 'charvalue': '%b',
    \ 'charvaluehex': '%B',
    \ 'fileencoding': '%{&fenc!=#""?&fenc:&enc}',
    \ 'fileformat': '%{&ff}',
    \ 'filetype': '%{&ft!=#""?&ft:"no ft"}',
    \ 'percent': '%3p%%',
    \ 'percentwin': '%P',
    \ 'spell': '%{&spell?&spelllang:""}',
    \ 'lineinfo': '%3l:%-2v',
    \ 'line': '%l',
    \ 'column': '%c',
    \ 'close': '%999X X ',
    \ 'winnr': '%{winnr()}',
    \ 'sep1': '*'
    \}

let g:lightline.mode_map = {
    \ 'n' : 'N',
    \ 'i' : 'I',
    \ 'R' : 'R',
    \ 'v' : 'V',
    \ 'V' : 'L',
    \ "\<C-v>": 'B',
    \ 'c' : 'C',
    \ 's' : 'S',
    \ 'S' : 'S-LINE',
    \ "\<C-s>": 'S-BLOCK',
    \ 't': 'T',
    \ }


let g:lightline.separator = {
    \   'left': '', 'right': ''
    \}
let g:lightline.subseparator = {
    \   'left': '', 'right': '' 
    \}

let g:lightline.tabline_separator = g:lightline.separator
let g:lightline.tabline_subseparator = g:lightline.subseparator

let g:lightline.enable = {
    \ 'statusline': 1,
    \ 'tabline': 1
    \ }

" deoplete
let g:deoplete#enable_at_startup = 1
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" Clear search highlighting with Escape key
nnoremap <silent><esc> :noh<return><esc>

" Allow color schemes to do bright colors without forcing bold.
if &t_Co == 8 && $TERM !~# '^linux\|^Eterm'
  set t_Co=16
endif

set wildmenu

set encoding=utf8
scriptencoding utf-8

" Colorscheme
colorscheme lena
set fillchars=vert::

" Restore last cursor position and marks on open
au BufReadPost *
         \ if line("'\"") > 1 && line("'\"") <= line("$") && &ft !~# 'commit' 
         \ |   exe "normal! g`\""
         \ | endif

" Make sure to source this file somewhere at the bottom of your config.
" ====================================================================
" ====================================================================

" Do not show mode under the statusline since the statusline itself changes
" color depending on mode
set noshowmode

set laststatus=2
" ~~~~ Statusline configuration ~~~~
" ':help statusline' is your friend!
function! RedrawModeColors(mode) " {{{
  " Normal mode
  if a:mode == 'n'
    hi MyStatuslineAccent ctermfg=8 cterm=NONE ctermbg=NONE
    hi MyStatuslineFilename ctermfg=4 cterm=none ctermbg=0
    hi MyStatuslineAccentBody ctermbg=8 cterm=NONE ctermfg=4
  " Insert mode
  elseif a:mode == 'i'
    hi MyStatuslineAccent ctermfg=8 cterm=NONE ctermbg=NONE
    hi MyStatuslineFilename ctermfg=3 cterm=none ctermbg=0
    hi MyStatuslineAccentBody ctermbg=8 cterm=NONE ctermfg=3
  " Replace mode
  elseif a:mode == 'R'
    hi MyStatuslineAccent ctermfg=8 cterm=NONE ctermbg=NONE
    hi MyStatuslineFilename ctermfg=1 cterm=none ctermbg=0
    hi MyStatuslineAccentBody ctermbg=8 cterm=NONE ctermfg=1
  " Visual mode
  elseif a:mode == 'v' || a:mode == 'V' || a:mode == '^V'
    hi MyStatuslineAccent ctermfg=8 cterm=NONE ctermbg=NONE
    hi MyStatuslineFilename ctermfg=5 cterm=none ctermbg=0
    hi MyStatuslineAccentBody ctermbg=8 cterm=NONE ctermfg=5
  " Command mode
  elseif a:mode == 'c'
    hi MyStatuslineAccent ctermfg=8 cterm=NONE ctermbg=NONE
    hi MyStatuslineFilename ctermfg=6 cterm=none ctermbg=0
    hi MyStatuslineAccentBody ctermbg=8 cterm=NONE ctermfg=6
  " Terminal mode
  elseif a:mode == 't'
    hi MyStatuslineAccent ctermfg=8 cterm=NONE ctermbg=NONE
    hi MyStatuslineFilename ctermfg=1 cterm=none ctermbg=0
    hi MyStatuslineAccentBody ctermbg=8 cterm=NONE ctermfg=1
  endif
  " Return empty string so as not to display anything in the statusline
  return ''
endfunction
" }}}
function! SetModifiedSymbol(modified) " {{{
    if a:modified == 1
        hi MyStatuslineModifiedBody ctermbg=0 cterm=bold ctermfg=1
    else
        hi MyStatuslineModifiedBody ctermbg=0 cterm=bold ctermfg=8
    endif
    return '●'
endfunction
" }}}
function! SetFiletype(filetype) " {{{
  if a:filetype == ''
      return '-'
  else
      return a:filetype
  endif
endfunction
" }}}

" Statusbar items
" ====================================================================

" This will not be displayed, but the function RedrawModeColors will be
" called every time the mode changes, thus updating the colors used for the
" components.
set statusline=%{RedrawModeColors(mode())}
" Left side items   """"  "" "  "
" =======================
set statusline+=%#MyStatuslineAccentBody#\ 
set statusline+=%#MyStatuslineAccent#
set statusline+=%#MyStatuslineAccent#
set statusline+=%#MyStatuslineAccentBody#\ 
set statusline+=%#MyStatuslineAccentBody#
set statusline+=%#MyStatuslineAccentBody#\ 
" Filename
set statusline+=%#MyStatuslineFilename#\ %.20f
set statusline+=%#MyStatuslineFilename#\ 
set statusline+=%#MyStatuslineSeparator#
" Modified status
set statusline+=%#MyStatuslineModified#
set statusline+=%#MyStatuslineFilename#\ 
set statusline+=%#MyStatuslineModifiedBody#%{SetModifiedSymbol(&modified)}
set statusline+=%#MyStatuslineFilename#\ 
set statusline+=%#MyStatuslineModified#


" Right side items
" =======================
set statusline+=%=
" Line and Column
set statusline+=%#MyStatuslineLineCol#
set statusline+=%#MyStatuslineFilename#\ 
set statusline+=%#MyStatuslineLineColBody#%2l
set statusline+=\/%#MyStatuslineLineColBody#%2c
set statusline+=%#MyStatuslineFilename#\ 
set statusline+=%#MyStatuslineLineCol#
" Padding
" set statusline+=\ 
" Current scroll percentage and total lines of the file
set statusline+=%#MyStatuslinePercentage#
set statusline+=%#MyStatuslineFilename#\ 
set statusline+=%#MyStatuslinePercentageBody#%P
set statusline+=\/\%#MyStatuslinePercentageBody#%L
set statusline+=%#MyStatuslineFilename#\ 
set statusline+=%#MyStatuslinePercentage#
" Padding
" set statusline+=\ 
" Filetype
set statusline+=%#MyStatuslineFiletype#
set statusline+=%#MyStatuslineFilename#\ 
set statusline+=%#MyStatuslineFiletypeBody#%{SetFiletype(&filetype)}
set statusline+=%#MyStatuslineFilename#\ 
set statusline+=%#MyStatuslineFiletype#

set statusline+=%#MyStatuslineFiletype#
set statusline+=%#MyStatuslineFilename#\ 

" Setup the colors
hi StatusLine          ctermfg=5     ctermbg=NONE     cterm=NONE
hi StatusLineNC        ctermfg=8     ctermbg=NONE     cterm=bold

hi MyStatuslineSeparator ctermfg=0 cterm=NONE ctermbg=NONE

hi MyStatuslineModified ctermfg=0 cterm=NONE ctermbg=NONE

hi MyStatuslineFiletype ctermbg=NONE cterm=NONE ctermfg=0
hi MyStatuslineFiletypeBody ctermfg=5 cterm=italic ctermbg=0

hi MyStatuslinePercentage ctermfg=0 cterm=NONE ctermbg=NONE
hi MyStatuslinePercentageBody ctermbg=0 cterm=none ctermfg=6

hi MyStatuslineLineCol ctermfg=0 cterm=NONE ctermbg=NONE
hi MyStatuslineLineColBody ctermbg=0 cterm=none ctermfg=2
