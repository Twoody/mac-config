"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""" VUNDLE CONFIG """"""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible              " Be iMproved, required for Vundle
filetype off                  " Required for Vundle

" Set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

" Syntax Highlighting & Language Support
Plugin 'posva/vim-vue'          " Vue syntax highlighting
Plugin 'digitaltoad/vim-pug'    " Pug HTML syntax highlighting
Plugin 'leafgarland/typescript-vim' " TypeScript syntax highlighting

" UI & Appearance
Plugin 'dracula/vim', { 'name': 'dracula' } " Dracula colorscheme
Plugin 'vim-airline/vim-airline'            " Status line enhancement

" Add other plugins here, for example:
" Plugin 'tpope/vim-fugitive'
" Plugin 'L9'
" Plugin 'git://git.wincent.com/command-t.git'
" Plugin 'file:///home/gmarik/path/to/plugin'
" Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Plugin 'ascenator/L9', {'name': 'newL9'}

call vundle#end()            " Required
filetype plugin indent on    " Required: Enable filetype detection, plugins, and indenting
                             " To ignore plugin indent changes, instead use: filetype plugin on

" Brief Vundle help:
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
" See :h vundle for more details or wiki for FAQ
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""" END VUNDLE CONFIG """""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""" GENERAL VIM SETTINGS """""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set modelines=0               " Security: CVE-2007-2438, disable modelines in files

" Encoding
set encoding=utf-8
set termencoding=utf-8        " Set terminal encoding

" History and Undo
set history=5000              " Keep 1000 lines of history
set undolevels=1000           " Many levels of undo
if v:version >= 730
    set undofile              " Keep a persistent undo file
    set undodir=~/.vim/.undo,~/tmp,/tmp " Directories for undo files
endif

" File Handling
set nobackup                  " Do not keep backup files
set noswapfile                " Do not write intermediate swap files
set directory=~/.vim/.tmp,~/tmp,/tmp " Store temporary files here if swapfile is enabled

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""" UI & APPEARANCE """"""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set t_Co=256                  " Enable 256 colors in the terminal
" set termguicolors           " For true colors in compatible terminals (requires compatible colorscheme)
colorscheme dracula           " Load Dracula colorscheme

syntax on                     " Syntax highlighting

set ruler                     " Show the cursor position
set showmode                  " Show current mode (e.g., -- INSERT --)
set showcmd                   " Show (partial) command in the last line of the screen
set laststatus=2              " Always show the status line
set cmdheight=1               " Command line height (1 row)

set title                     " Change the terminal's title to the current file
set visualbell                " Use visual bell instead of beeping
set noerrorbells              " No beeping for errors

set scrolloff=3               " Keep 3 lines visible above/below cursor when scrolling

" Line Numbers
set nu                        " Always show line numbers

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""" TEXT FORMATTING & INDENTATION """"""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set autoindent noexpandtab tabstop=3 shiftwidth=3 " Indentation: use tabs, 3 spaces wide
set smarttab                  " Insert tabs based on shiftwidth at the start of a line

set showmatch                 " Show matching parenthesis

" Paste mode toggle
set pastetoggle=<F2>
nnoremap <F2> :set invpaste paste?<CR> " Toggle paste mode, show current state

" White space characters (toggle with F3)
set nolist
set listchars=eol:$,tab:.\ ,trail:.,extends:>,precedes:<,nbsp:_
highlight SpecialKey term=standout ctermfg=darkgray guifg=darkgray
nnoremap <F3> :set list! list?<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""" SEARCH SETTINGS """""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set hlsearch                  " Highlight search terms
set incsearch                 " Show search matches as you type

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""" VIM BEHAVIOR """"""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set lazyredraw                " Don't update display while executing macros (faster)

" Tab completion for commands, files, buffers
set wildmenu                  " Enhanced command-line completion
set wildmode=list:full        " Show list of matches, complete first full match
set wildignore=*.swp,*.bak,*.pyc,*.class " Ignore these files for completion

" Restore cursor position to where it was last time when opening a file
if has("autocmd")
  autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") && &ft !~# 'commit'
    \ |   exe "normal! g'\""
    \ | endif
endif

let skip_defaults_vim=1       " Skip loading some default vim plugins/settings if desired

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"""""""""""""""""""""""""" LANGUAGE-SPECIFIC SETTINGS """""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Python specific indentation
augroup python_settings
  autocmd!
  autocmd FileType python setlocal ts=2 sts=2 sw=2 expandtab
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""" MISC & NOTES """"""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Mouse setting (currently disabled as it can interfere with terminal copy/paste)
" set mouse=a                 " Enable mouse in all modes if terminal emulator supports it

" Regex Search & Replace Examples (for reference)
" For Markdown:
"   :%s!`\(\_.\{-1,\}\)`!<code>\1</code>!g
"   :%s!__\(\_.\{-1,\}\)__!<em>\1</em>!g
"
" For Stripping HTML:
"   :%s/<\_.\{-1,\}>//g
"
" For Annoying ^M DOS characters:
"   :%s!<C-V><C-M>!\r!g  (Note: <C-V><C-M> means Ctrl+V then Ctrl+M)
"
" For removing all double newlines in files:
"   :g/^\s*$/d

" Find Vim configuration file location:
" In terminal: vim --version | grep vimrc
" Or in Vim: :version and look for "user vimrc file"
