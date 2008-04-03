" Configuration file for gvim
" Written for Debian GNU/Linux by W.Akkerman <wakkerma@debian.org>

" Make external commands work through a pipe instead of a pseudo-tty
"set noguipty
" Switch syntax highlighting on, when the terminal has colors

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

" Also switch on highlighting the last used search pattern.
if has("syntax") && (&t_Co > 2 || has("gui_running"))
  syntax on
  set hlsearch
endif

" Extensions by i18n teams
if filereadable( "/etc/vim/langrc/" . $LANG . ".vim" )
   exe "so " . "/etc/vim/langrc/" . $LANG . ".vim"
endif

" You can also specify a different font, overriding the default font and the
" one from the hooks above:
" set guifont=-misc-fixed-medium-r-normal--14-130-75-75-c-70-iso8859-1
"

"set colorscheme randomly
let colorscheme_list = ['blacksea', 'desert', 'mymud',
            \ 'dante', 'candy', 'elflord', 'golden',
            \ 'less']
exec "colorscheme " . colorscheme_list[localtime()%len(colorscheme_list)]
":colorscheme desert "mymud zenburn ps_color elflord metacosm dusk

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" the following config to make gvim startup faster
set guioptions-=M
"set guioptions-=m

set guioptions-=T
"if ! has("gui_macvim")
    "set guioptions-=T
"endif

" turn &cursorline on only in GUI && normal mode
if exists("&cursorline")
    set cursorline
    autocmd InsertLeave * set cursorline                    
    autocmd InsertEnter * set nocursorline
endif

"mark.vim should be re-sourced after any changing to colors. For example, if you
":set background=dark  OR
":colorscheme default
"you should
":source PATH_OF_PLUGINS/mark.vim
"after that. Otherwise, you won't see the colors.
"Unfortunately, it seems that .gvimrc runs after plugin scripts. So if you set any color settings in .gvimrc, you have to add one line to the end of .gvimrc to source mark.vim. 
if has('win32')
	:source $VIMCFG\plugin\mark.vim
else
	:source $VIMCFG/plugin/mark.vim
endif

" following config to make gvim startup faster
set guiheadroom=0

set guioptions-=mTrRlLb

