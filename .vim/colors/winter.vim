
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" File Name:      winter.vim
" Abstract:       A color sheme file (only for GVIM) which uses a light grey 
"                 background makes the VIM look like the scenes of winter.
" Author:         CHE Wenlong <chewenlong AT buaa.edu.cn>
" Version:        1.1
" Last Change:    February 12, 2009

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

if !has("gui_running")
    runtime! colors/default.vim
    finish
endif

set background=light

hi clear

" Version control
if version > 580
    hi clear
    if exists("syntax_on")
        syntax reset
    endif
endif

let colors_name = "winter"

" Common
hi Normal           guifg=#000000   guibg=#d4d0c8   gui=NONE
hi Visual           guifg=#ffffff   guibg=#000080   gui=NONE
hi Cursor           guifg=#d4d0c8   guibg=#0000ff   gui=NONE
hi LineNr           guifg=#707070   guibg=#e0e0e0   gui=NONE
hi Title            guifg=#202020   guibg=NONE      gui=NONE
hi Underlined       guifg=#202020   guibg=NONE      gui=underline

" Split
hi StatusLine       guifg=#e0e0e0   guibg=#707070   gui=NONE
hi StatusLineNC     guifg=#e0e0e0   guibg=#909090   gui=NONE
hi VertSplit        guifg=#909090   guibg=#909090   gui=NONE

" Folder
hi Folded           guifg=#707070   guibg=#e0e0e0   gui=NONE

" Syntax
hi Type             guifg=#0000ff   guibg=NONE      gui=NONE
hi Define           guifg=#0000ff   guibg=NONE      gui=NONE
hi Comment          guifg=#008080   guibg=NONE      gui=NONE
hi Constant         guifg=#a000a0   guibg=NONE      gui=NONE
hi String           guifg=#880000   guibg=NONE      gui=NONE
hi Number           guifg=#ff0000   guibg=NONE      gui=NONE
hi Statement        guifg=#0000ff   guibg=NONE      gui=NONE

" Others
hi PreProc          guifg=#a000a0    guibg=NONE     gui=NONE
hi Special          guifg=#a000a0    guibg=NONE     gui=NONE
hi SpecialKey       guifg=#a000a0    guibg=NONE     gui=NONE
hi Error            guifg=#ff0000    guibg=#ffffff  gui=NONE,underline
hi Todo             guifg=#ff0000    guibg=#ffff00  gui=NONE,underline

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" vim:tabstop=4

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

