"Start Almighty VIM
"Author:Sarath V

call plug#begin("~/.config/nvim/plugged")
  " Color
  Plug 'morhetz/gruvbox'
  Plug 'NLKNguyen/papercolor-theme'

  " Language Client
  Plug 'neoclide/coc.nvim', {'branch': 'release'}

  " File Search
  Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
  Plug 'junegunn/fzf.vim'

  " File Explorer with Icons
  Plug 'scrooloose/nerdtree'
  Plug 'ryanoasis/vim-devicons'

  "Go
  Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

  " Others
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'tpope/vim-surround'
  Plug 'preservim/tagbar'
  " End
call plug#end()

if (has("nvim"))
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

if (has("termguicolors"))
  set termguicolors
endif

set background=light
colorscheme PaperColor

"Syntax related
set title
syntax on
filetype plugin indent on

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
"set cino+=:0,l1,g0,(0,j1,t0

"No error bells
set noeb vb t_vb=

"for gf 
set path+=$HOME 

"Tagbar plugin
let Tlist_WinWidth=40
let Tlist_Exit_OnlyWindow = 1
"let g:tagbar_left = 1

"File specific handling
au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif
autocmd FileType c,cpp,java,python,go set formatoptions+=olt
autocmd BufNewFile,BufRead *.html set shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

"Don't run gofmt during write
let g:go_fmt_autosave = 0
let g:go_template_autocreate = 0

nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
nnoremap <silent> <F3> :TagbarToggle<CR>
nnoremap <F4> :NERDTreeToggle<CR>
nnoremap <silent> <F5> :call Copy()<CR>

nnoremap <silent> <leader>s :syntax sync fromstart<CR>
nnoremap <silent> q :q<CR>
nnoremap <silent> <leader>; :bp<CR>
nnoremap <silent> <leader>, :bn<CR>
nnoremap <C-P> @:

"use tab for completion if pop menu available
inoremap <expr> <TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr> <S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

map <C-\> :bel sp <CR>:exec(":GoDef ".expand("<cword>"))<CR><CR>

vnoremap // y/<C-R>"<CR>

" For manpages
let $GROFF_NO_SGR=1
source $VIMRUNTIME/ftplugin/man.vim
nmap K :Man <cword><CR>

" Ctags path
set tags+=tags;/

"Function to enable mouse copy
function! Copy()
    set nonu
    set mouse=
endfunction

let g:airline_powerline_fonts = 1
"let g:airline_theme='papercolor'

