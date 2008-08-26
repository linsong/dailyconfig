" Vim BlockDiff-Plugin
"
" Author: Timo Teifel
" Email: timo dot teifel at teifel dot net
" Version: 1.1
" Date: 23 Oct 2007
" Licence: GPL v2.0
"
" Usage:
"   - Select first block
"   - Depending on the configuration, select:
"       - Menu Tools->BlockDiff-> This\ is\ Block\ 1
"       - Popup-Menu    -> This\ is\ Block\ 1
"       - :BlockDiff1
"       - ,d1
"   - select second block (may be in another file, but in the same
"     Vim window)
"       - Menu Tools->BlockDiff-> This\ is\ Block\ 2,\ start\ diff
"       - Popup-Menu    -> This\ is\ Block\ 2,\ start\ diff
"       - :BlockDiff2
"       - ,d2
"   - Script opens a new tab, splits it and shows the diff between
"     the two blocks.
"   - Close the tab when done 
" 
" History:
"   V1.0: Initial upload
"   V1.1: Added commands and inclusion guard, Thanks to Ingo Karkat


" Avoid installing twice or when in compatible mode 
if exists('g:loaded_blockdiff') || (v:version < 700) 
finish 
endif 
let g:loaded_blockdiff = 1


let s:save_cpo = &cpo
set cpo&vim

" ---------- Configuration ----------------------------------------------------
" uncomment one or more of these blocks:


" Create menu entry:
    vmenu 40.352.10 &Tools.Bloc&kDiff.This\ is\ Block\ &1 :call BlockDiff_GetBlock1()<CR>
    vmenu 40.352.20 &Tools.Bloc&kDiff.This\ is\ Block\ &2,\ start\ diff :call BlockDiff_GetBlock2()<CR>


" Create popup-menu-entry:
    "vmenu PopUp.BlockDiff.This\ is\ Block\ 1 :call BlockDiff_GetBlock1()<CR>
    "vmenu PopUp.BlockDiff.This\ is\ Block\ 2,\ start\ diff :call BlockDiff_GetBlock2()<CR>

" Shortcuts
    "vmap ,d1 :call BlockDiff_GetBlock1()<CR>
    "vmap ,d2 :call BlockDiff_GetBlock2()<CR>

" Commands 
    command! -range BlockDiff1 :<line1>,<line2>call BlockDiff_GetBlock1() 
    command! -range BlockDiff2 :<line1>,<line2>call BlockDiff_GetBlock2()


" ---------- Code -------------------------------------------------------------
fun! BlockDiff_GetBlock1() range
  let s:regd = @@
  " copy selected block into unnamed register
  exe a:firstline . "," . a:lastline . "y"
  " save block for later use in variable
  let s:block1 = @@
  " restore unnamed register
  let @@ = s:regd
endfun

fun! BlockDiff_GetBlock2() range
  let s:regd = @@
  exe a:firstline . "," . a:lastline . "y"

  " Open new tab, paste second selected block
  tabnew
  normal P
  " to prevent 'No write since last change' message:
  se buftype=nowrite
  diffthis

  " vsplit left for first selected block
  lefta vnew
  " copy first block into unnamed register & paste
  let @@ = s:block1
  normal P
  se buftype=nowrite

  " start diff
  diffthis

  " restore unnamed register
  let @@ = s:regd
endfun


let &cpo = s:save_cpo
unlet s:save_cpo

