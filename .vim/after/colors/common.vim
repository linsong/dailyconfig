" colors that will apply no matter what colorscheme is used. 
"
if v:version >= 700
    hi MarkWord1  ctermbg=Cyan    ctermfg=Black guibg=#8CCBEA   guifg=DarkRed
    hi MarkWord2  ctermbg=Green   ctermfg=Black guibg=#A4E57E   guifg=DarkRed
    hi MarkWord3  ctermbg=Yellow  ctermfg=Black guibg=#FFDB72   guifg=DarkRed
    hi MarkWord4  ctermbg=Red     ctermfg=Black guibg=#FF7272   guifg=DarkRed
    hi MarkWord5  ctermbg=Magenta ctermfg=Black guibg=#FFB3FF   guifg=DarkRed
    hi MarkWord6  ctermbg=Blue    ctermfg=Black guibg=#9999FF   guifg=DarkRed
endif

" highlights for fuzzyfinder mode prompts
hi FileMode       ctermbg=Cyan    ctermfg=Black   guibg=#8CCBEA guifg=DarkCyan
hi BufferMode     ctermbg=Green   ctermfg=Black   guibg=#A4E57E guifg=DarkGreen
hi DirMode        ctermbg=Yellow  ctermfg=Black   guibg=#FFDB72 guifg=DarkYellow
hi MruFileMode    ctermbg=Red     ctermfg=Black   guibg=#FF7272 guifg=DarkRed
hi MruCmdMode     ctermbg=Magenta ctermfg=Black   guibg=#FFB3FF guifg=DarkMagenta
hi BookmarkMode    ctermbg=Blue    ctermfg=Black   guibg=#9999FF guifg=DarkRed
hi TagMode        ctermbg=Yellow  ctermfg=Green   guibg=#FFDB72 guifg=DarkGreen
hi TaggedFileMode ctermbg=Yellow  ctermfg=Magenta guibg=#FFDB72 guifg=DarkMagenta

" for visual mode and fold mode 
hi Visual	gui=none guifg=khaki guibg=olivedrab
hi Folded	guibg=grey30 guifg=gold 
hi FoldColumn	guibg=grey30 guifg=tan

" for diff mode 
hi DiffAdd       ctermbg=4 gui=bold,italic guifg=#000000 guibg=#A86828
hi DiffChange    ctermbg=5  gui=bold,italic guifg=#000000 guibg=#986888 
hi DiffDelete    cterm=bold ctermfg=4 ctermbg=6 gui=bold guifg=#0000ff guibg=#68A898
hi DiffText      cterm=bold ctermbg=1 gui=bold,italic guifg=#000000 guibg=#980000

" for omni completion
if &t_Co>=256
  hi Pmenu       guibg=#4e4e8f guifg=#eeeeee ctermbg=13
  hi PmenuSel    guibg=#2e2e3f guifg=#eeeeee cterm=bold ctermbg=8
  hi PmenuSbar   guibg=#6e6eaf guifg=#eeeeee gui=bold cterm=bold ctermbg=7
  hi PmenuThumb  guibg=#6e6eaf guifg=#eeeeee gui=bold cterm=reverse
else
  hi Pmenu       guibg=grey35 ctermbg=2
  hi PmenuSel    guifg=DarkBlue guibg=LightGreen cterm=bold ctermbg=5
  hi PmenuSbar   guibg=Black cterm=bold ctermbg=4
  hi PmenuThumb  guifg=SeaGreen gui=reverse cterm=reverse
endif

" for Cursor
"highlight Cursor     gui=none       guibg=DodgerBlue guifg=#ffffff
highlight Cursor     gui=none       guibg=Red guifg=#ffffff
"highlight Cursor     ctermfg=Black	ctermbg=Green	 cterm=reverse
highlight Cursor     ctermfg=Black	ctermbg=Red	 cterm=reverse

if &t_Co>=256
  highlight IncSearch  term=reverse cterm=bold ctermfg=232 ctermbg=215 gui=reverse
  highlight Search     term=reverse ctermfg=232 ctermbg=215 guifg=Black guibg=Yellow
else
  highlight IncSearch  term=reverse cterm=reverse gui=reverse
  highlight Search     term=reverse ctermfg=0 ctermbg=3 guifg=Black guibg=Yellow
end

if &background == "dark"

  if v:version >= 700
      highlight CursorLine term=underline cterm=underline guibg=Grey25
      highlight CursorColumn term=reverse ctermbg=8 guibg=Grey25
  endif

  " highlight defination for visualmark.vim
  highlight SignColor ctermfg=white ctermbg=blue guifg=white guibg=RoyalBlue3

else " for light colorscheme
  if v:version >= 700
    highlight CursorLine term=underline cterm=underline gui=none guibg=Grey90
    highlight CursorColumn term=reverse ctermbg=7 guibg=Grey90
  endif

  highlight SignColor ctermbg=white ctermfg=blue guibg=grey guifg=RoyalBlue3
endif
