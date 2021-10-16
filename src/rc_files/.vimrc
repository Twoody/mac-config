"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""__VUNDLE CONFIG__""""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'               " This module...
Plugin 'posva/vim-vue'                      " Vue syntax highlighting
Plugin 'digitaltoad/vim-pug'                " Pug html syntax highlighting
Plugin 'dracula/vim', { 'name': 'dracula' } " Testing some new colors...
Plugin 'vim-airline/vim-airline'            " Status line enhancement

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
"  Plugin 'tpope/vim-fugitive'
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" plugin from http://vim-scripts.org/vim/scripts.html
" Plugin 'L9'
" Git plugin not hosted on GitHub
"  Plugin 'git://git.wincent.com/command-t.git'
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" git repos on your local machine (i.e. when working on your own plugin)
"  Plugin 'file:///home/gmarik/path/to/plugin'
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"  Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Install L9 and avoid a Naming conflict if you've already installed a
" different version somewhere else.
"  Plugin 'ascenator/L9', {'name': 'newL9'}
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line


" Configuration file for vim
set modelines=0        " CVE-2007-2438
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""__END VUNDLE CONFIG__""""""""""""""""""""""""""""
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Use vim settings, rather then vi settings (much better!)
" This must be first, because it changes other options as a side effect.
set nocompatible

set t_Co=256            " iTerm2 supports 256 color mode.
set ai                  " auto indenting
set history=1000        " keep 1000 lines of history
set ruler               " show the cursor position
syntax on               " syntax highlighting
filetype plugin on      " use the file type plugins

set showmode                    " always show what mode we're currently editing in

"set expandtab                   " don't expand tabs to spaces by default
"set tabstop=3                   " a tab is two spaces
"set softtabstop=3               " when hitting <BS>, pretend like a tab is removed, even if spaces
"set shiftwidth=3                " number of spaces to use for autoindenting
"set shiftround                  " use multiple of shiftwidth when indenting with '<' and '>'
"set backspace=indent,eol,start  " allow backspacing over everything in insert mode
"set autoindent                  " always set autoindenting on
"set copyindent                  " copy the previous indentation on autoindenting
"set expandtab                   " don't expand tabs to spaces by default
set autoindent noexpandtab tabstop=3 shiftwidth=3
   
set showmatch                   " set show matching parenthesis
set smarttab                    " insert tabs on the start of a line according to
                                "    shiftwidth, not tabstop
set scrolloff=3                 " keep 4 lines off the edges of the screen when scrolling

set hlsearch                    " highlight search terms
set incsearch                   " show search matches as you type

set nu                          " Always have line count on
colorscheme ron                 " One of the oldest colorschemese I've used
"colorscheme dracula            " Newer colorscheme; Might be better when light out;


" white space characters
set nolist
set listchars=eol:$,tab:.\ ,trail:.,extends:>,precedes:<,nbsp:_
highlight SpecialKey term=standout ctermfg=darkgray guifg=darkgray
" display white space characters with F3
nnoremap <F3> :set list! list?<CR>

" no indent on paste
set pastetoggle=<F2>
nnoremap <F2> :set invpaste paste?<CR>
set pastetoggle=<F2>
set showmode

"set mouse=a                     " enable using the mouse if terminal emulator supports it
" turned off - it kills copy/paste

" Editor layout {{{
set termencoding=utf-8
set encoding=utf-8
set lazyredraw                  " don't update the display while executing macros
set laststatus=2                " tell VIM to always put a status line in, even
                                "    if there is only one window
set cmdheight=1                 " use a status bar that is 1 rows high


" Vim behaviour {{{
set history=1000                " remember more commands and search history
set undolevels=1000             " use many muchos levels of undo
if v:version >= 730
    set undofile                " keep a persistent backup file
    set undodir=~/.vim/.undo,~/tmp,/tmp
endif
set nobackup                    " do not keep backup files, it's 70's style cluttering
set noswapfile                  " do not write annoying intermediate swap files,
                                "    who did ever restore from swap files anyway?
set directory=~/.vim/.tmp,~/tmp,/tmp
                                " store swap files in one of these directories
                                "    (in case swapfile is ever turned on)
"set viminfo='20,\"80            " read/write a .viminfo file, don't store more
                                "    than 80 lines of registers
set wildmenu                    " make tab completion for files/buffers act like bash
set wildmode=list:full          " show a list when pressing tab and complete
                                "    first full match
set wildignore=*.swp,*.bak,*.pyc,*.class
set title                       " change the terminal's title
set visualbell                  " don't beep
set noerrorbells                " don't beep
set showcmd                     " show (partial) command in the last line of the screen
                                "    this also shows visual selection info
set nomodeline                  " disable mode lines (security measure)

" When editing a file, always jump to the last cursor position
autocmd BufReadPost *
\ if ! exists("g:leave_my_cursor_position_alone") |
\ if line("'\"") > 0 && line ("'\"") <= line("$") |
\ exe "normal g'\"" |
\ endif |
\ endif

if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

let skip_defaults_vim=1

" Stupid python trying to use special vim props
aug python
  " ftype/python.vim overwrites this
  au FileType python setlocal ts=2 sts=2 sw=2 expandtab
aug end


"** ** ** ** ** ** ** ** ** REGEX S&R ** ** ** ** ** ** ** ** ** **"
"    FOR MARKDOWN:
"        :%s!`\(\_.\{-1,\}\)`!<code>\1</code>!g
"        :%s!__\(\_.\{-1,\}\)__!<em>\1</em>!g
"
"    FOR STRIPPING HTML:
"        :%s/<\_.\{-1,\}>//g
"
"   For Annoying ^M dos characters:
"        :%s!<cntrl+V><cntr+M>!\r!g
"   
"   For all of the double newlines in files:
"        :g/^\s*$/d
"** ** ** ** ** ** ** ** ** Windows ** ** ** ** ** ** ** ** ** **"
" #Find out where your vim is being config'ed at:
" vim --version | grep vimrc
