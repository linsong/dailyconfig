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
hi Pmenu       guibg=grey30
hi PmenuSel    guifg=DarkBlue guibg=LightGreen
hi PmenuSbar   guibg=Black 
hi PmenuThumb  guifg=SeaGreen	

" for Cursor
highlight Cursor     gui=none       guibg=DodgerBlue guifg=#ffffff
highlight Cursor     ctermfg=Black	ctermbg=Green	 cterm=reverse
