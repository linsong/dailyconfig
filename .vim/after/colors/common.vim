" colors that will apply no matter what colorscheme is used. 

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
hi Pmenu       guibg=grey35
hi PmenuSel    guifg=DarkBlue guibg=LightGreen
hi PmenuSbar   guibg=Black 
hi PmenuThumb  guifg=SeaGreen	

" for Cursor
"highlight Cursor     gui=none       guibg=DodgerBlue guifg=#ffffff
highlight Cursor     gui=none       guibg=Red guifg=#ffffff
"highlight Cursor     ctermfg=Black	ctermbg=Green	 cterm=reverse
highlight Cursor     ctermfg=Black	ctermbg=Red	 cterm=reverse

if v:version >= 700
    "highlight CursorLine term=underline cterm=underline guibg=#000000 
    "highlight CursorColumn term=underline cterm=underline guibg=#000000 
    highlight CursorLine term=underline cterm=underline gui=none guibg=#003333
    highlight CursorColumn term=underline cterm=underline gui=none guibg=#003333 

    hi MarkWord1  ctermbg=Cyan    ctermfg=Black guibg=#8CCBEA   guifg=DarkRed
    hi MarkWord2  ctermbg=Green   ctermfg=Black guibg=#A4E57E   guifg=DarkRed
    hi MarkWord3  ctermbg=Yellow  ctermfg=Black guibg=#FFDB72   guifg=DarkRed
    hi MarkWord4  ctermbg=Red     ctermfg=Black guibg=#FF7272   guifg=DarkRed
    hi MarkWord5  ctermbg=Magenta ctermfg=Black guibg=#FFB3FF   guifg=DarkRed
    hi MarkWord6  ctermbg=Blue    ctermfg=Black guibg=#9999FF   guifg=DarkRed
endif

" highlight defination for visualmark.vim
if &bg == "dark"
    highlight SignColor ctermfg=white ctermbg=blue guifg=white guibg=RoyalBlue3
else
    highlight SignColor ctermbg=white ctermfg=blue guibg=grey guifg=RoyalBlue3
endif
