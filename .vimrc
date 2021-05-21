"Start Almighty VIM
"Author:Sarath V

"Syntax related
set title
syntax on
filetype plugin indent on

"Color related
set t_Co=256
set background=light
colorscheme gruvbox

autocmd BufReadPost *
            \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
            \ |   exe "normal! g`\""
            \ | endif

"Indentation and word wrap
set autoindent
set expandtab
set shiftwidth=4
set tabstop=4
set softtabstop=4
set textwidth=120
set wrap

"History
set history=1000

"Status line & number
set nu
set laststatus=2

"enable mouse scrolling in tmux
set mouse=a

"For cleaner looks
set showtabline=0
set noshowmode

"Show matches in brackets
set showmatch

"Search related
set incsearch
set hlsearch
set ignorecase
set smartcase

"Wildmenu related
set wildmenu
set wildignore=*.dll,*.o,*.obj,*.bak,*.exe,*.pyc,*.jpg,*.gif,*.png
set wildmode=list:longest,full

"Scrolling related
set scrolljump=2
set scrolloff=1

"C indentation flags
set cino+=:0,l1,g0,(0,j1,t0

"No error bells
set noeb vb t_vb=

"for gf 
set path+=$HOME 

"Tagbar plugin
let Tlist_WinWidth=40
let Tlist_Exit_OnlyWindow = 1
let g:tagbar_left = 1

"File specific handling
autocmd FileType c,cpp,java,python,go set formatoptions+=olt
autocmd BufNewFile,BufRead *.html set shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType make setlocal expandtab "expandtab for makefile
autocmd FileType go setlocal expandtab "expandtab for go

"Don't run gofmt during write
let g:go_fmt_autosave = 0
let g:go_template_autocreate = 0

nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>

nnoremap <C-P> @:
inoremap <C-f> <C-x><C-o><C-p>
nnoremap <silent> <F3> :TagbarToggle<CR>
nnoremap <F4> :NERDTreeToggle<CR>
nnoremap <F5> <C-w>w
nnoremap <silent> <F6> :call LoadCscope()<CR>
nnoremap <silent> <leader>s :syntax sync fromstart<CR>
nnoremap <silent> q :q<CR>
nnoremap <silent> <leader>; :bp<CR>
nnoremap <silent> <leader>, :bn<CR>

nnoremap <silent> <C-\> :bel sp <CR>:exec(":YcmCompleter GoToDefinition ".expand("<cword>"))<CR>
nnoremap <silent> <C-]> :bel :exec(":YcmCompleter GoToDefinition ".expand("<cword>"))<CR>

vnoremap // y/<C-R>"<CR>

" For manpages
let $GROFF_NO_SGR=1
source $VIMRUNTIME/ftplugin/man.vim
nmap K :Man <cword><CR>

" Ctags path
set tags+=tags;/

"Function to load cscope database
function! LoadCscope()
  let db = findfile("cscope.out", ".;")
  if (!empty(db))
    let path = strpart(db, 0, match(db, "/cscope.out$"))
    set nocscopeverbose " suppress 'duplicate connection' error
    exe "cs add " . db . " " . path
    set cscopeverbose
  endif
endfunction
au BufEnter /* "call LoadCscope()

"No preview needed in auto complete
set completeopt-=preview

"Airline plugin
let g:airline_powerline_fonts = 1
"let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='gruvbox'

" disable syntax check by ycm
let g:ycm_show_diagnostics_ui = 0

"Nerdtree plugin
"let NERDTreeMinimalUI=1
let NERDTreeIgnore=['\.o$', '\~$']
highlight link NERDTreeExecFile Normal

"Pathogen plugin
call pathogen#infect() 

