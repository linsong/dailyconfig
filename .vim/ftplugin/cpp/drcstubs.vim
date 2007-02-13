" drcstubs.vim: Dr Chip's C Stubs  (a plugin)
"   isk is set to include # so as not to break #if
"
"  Author: Charles E. Campbell, Jr. (PhD)
"  Date:   Jan 23, 2003
"
"  Usage:  (requires 6.0 or later)
"
"   These maps all work during insert mode while editing a C
"   or C++ program.  Use either the shorthand or longhand maps
"   below, and the associated construct will be expanded to
"   include parentheses, curly braces, and the cursor will be
"   moved to a convenient location, still in insert mode, for
"   further editing.
"
"   Shorthand  Longhand
"   Map        Map
"   ---------  --------
"   i`         if`
"   e`         els[e]`
"   ei`        eli[f]`
"   f`         for`
"   w`         wh[ile]`
"   s`         sw[itch]`
"   c`         ca[se]`
"   d`         defa[ult]`
"              do`
"              in[clude]` yields #include
"              de[fine]`  yields #define
"   E`         Ed[bg]`    (see http://www.erols.com/astronaut/dbg)
"   R`         Rd[bg]`    (see http://www.erols.com/astronaut/dbg)
"   D`         Dp[rintf]` (see http://www.erols.com/astronaut/dbg)
"
"   Caveat: these maps will not work if "set paste" is on
"
" Installation:
"
" This copy of DrC's C-Stubs is filetype plugin for vim 6.0: put it in
"  ${HOME}/.vim/ftplugin/c/    -and-   ${HOME}/.vim/ftplugin/cpp/
" (or make suitable links) and put "filetype plugin on" in your <.vimrc>.
"
" "For I am convinced that neither death nor life, neither angels nor demons,
"  neither the present nor the future, nor any powers, nor height nor depth,
"  nor anything else in all creation, will be able to separate us from the
"  love of God that is in Christ Jesus our Lord."  Rom 8:38
" =======================================================================

" prevent re-load
if exists("g:loaded_drc")
  finish
endif
let g:loaded_drc= 1

" ---------------------------------------------------------------------
" Only done once
syn keyword cTodo COMBAK
syn match cTodo "^[- ]*COMBAK[- ]*$" 
set isk+=#

" ---------------------------------------------------------------------
" Public Interface:
if !hasmapto('<Plug>UseDrCStubs')
 imap <unique> ` <Plug>UseDrCStubs
endif

" backquote calls DrChipCStubs function
inoremap <Plug>UseDrCStubs <Esc>:call <SID>DrChipCStubs()<CR>a

" ---------------------------------------------------------------------

" DrChipCStubs: this function changes the backquote into
"               text based on what the preceding word was
function! <SID>DrChipCStubs()
 let vekeep= &ve
 set ve=

 let wrd=expand("<cWORD>")

 if     wrd == "if"
  exe "norm! bdWaif()\<CR>{\<CR>}\<Esc>2k$F("
 elseif wrd == "i"
  exe "norm! xaif()\<CR>{\<CR>}\<Esc>2k$F("

 elseif wrd =~ 'els\%[e]'
  exe "norm! bdWaelse\<CR>{\<CR>}\<Esc>O \<c-h>\<Esc>"
 elseif wrd == "e"
  exe "norm! xaelse\<CR>{\<CR>}\<Esc>O \<c-h>\<Esc>"

 elseif wrd =~ 'eli\%[f]'
  exe "norm! bdWaelse if()\<CR>{\<CR>}\<Esc>2k$F("
 elseif wrd == "ei"
  exe "norm! bdWaelse if()\<CR>{\<CR>}\<Esc>2k$F("

 elseif wrd =~ 'for\='
  exe "norm! bdWafor(;;)\<CR>{\<CR>}\<Esc>2k$F("
 elseif wrd == "f"
  exe "norm! xafor(;;)\<CR>{\<CR>}\<Esc>2k$F("

 elseif wrd =~ 'wh\%[ile]'
  exe "norm! bdWawhile()\<CR>{\<CR>}\<Esc>2k$F("
 elseif wrd == "w"
  exe "norm! xawhile()\<CR>{\<CR>}\<Esc>2k$F("

 elseif wrd =~ 'sw\%[itch]'
  exe "norm! bdWaswitch()\<CR>{\<CR>}\<Esc>2k$F("
 elseif wrd == "s"
  exe "norm! xaswitch()\<CR>{\<CR>}\<Esc>2k$F("

 elseif wrd =~ 'ca\%[se]'
  exe "norm! bdWacase :\<CR>break;\<Esc>khf:h"
 elseif wrd == "c"
  exe "norm! xacase :\<CR>break;\<Esc>khf:h"

 elseif wrd =~ 'defa\%[ult]'
  exe "norm! bdWadefault :\<CR>break;\<Esc>O \<c-h>\<Esc>"
 elseif wrd == "d"
  exe "norm! xadefault :\<CR>break;\<Esc>O \<c-h>\<Esc>"

 elseif wrd == "do"
  exe "norm! bdWado\<CR>{\<CR>} while();\<Esc>O \<c-h>\<Esc>"

 elseif wrd =~ 'Ed\%[bg]'
  exe "norm! bdWaEdbg((\"\<Esc>ma[[?)\<CR>%BdwP`apa()\"));\<Esc>F("
 elseif wrd == "E"
  exe "norm! xaEdbg((\"\<Esc>ma[[?)\<CR>%BdwP`apa()\"));\<Esc>F("

 elseif wrd =~ 'Rd\%[bg]'
  exe "norm! bdWaRdbg((\"\<Esc>ma[[?)\<CR>%BdwP`apa\"));\<Esc>F\"h"
 elseif wrd == "R"
  exe "norm! xaRdbg((\"\<Esc>ma[[?)\<CR>%BdwP`apa\"));\<Esc>F\"h"

 elseif wrd =~ 'Dp\%[rintf]'
  exe "norm! bdWaDprintf((1,\"\"));\<Esc>4h"
 elseif wrd == "D"
  exe "norm! xaDprintf((1,\"\"));\<Esc>4h"
 
 elseif wrd =~ 'in\%[clude]'
  exe "norm! bdW0i#include \<Esc>"
 elseif wrd =~ 'de\%[fine]'
  exe "norm! bdW0i#define \<Esc>"

 else
  exe "norm! a`\<Esc>"
 endif

 let &ve= vekeep
endfunction

" ---------------------------------------------------------------------
