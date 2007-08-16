" visswap.vim   : Visual Mode Based Swapping
"  Author:	Charles E. Campbell, Jr.
"  Date:	Nov 10, 2003
"  Version:	2
"  Usage:
"		Visually select some text, then <ctrl-y>  (initialize)
"       Visually select some text, then <ctrl-x>  (swap)

" ---------------------------------------------------------------------
" Public Interface:
if !hasmapto('<Plug>VisualPreSwap')
 map <silent> <unique> <c-y> <Plug>VisualPreSwap
endif
vnoremap <silent> <unique> <Plug>VisualPreSwap <Esc>:call <SID>VisualPreSwap()<CR>
if !hasmapto('<Plug>VisualSwap')
 map <silent> <unique> <c-x> <Plug>VisualSwap
endif
vnoremap <silent> <unique> <Plug>VisualSwap <Esc>:call <SID>VisualSwap()<CR>

" ---------------------------------------------------------------------

" VisualPreSwap: initializes a visual-mode swap by recording visual-selection
"                zone parameters
fu! s:VisualPreSwap()
  let s:vismode1      = visualmode()
  let s:startswapline1= line("'<")
  let s:startswapcol1 = virtcol("'<")
  let s:endswapline1  = line("'>")
  let s:endswapcol1   = virtcol("'>")
  if s:vismode1 =~ "[vV]"
   echo "visual (".s:vismode1.") mode swap initialized"
  else
   echo "visual (ctrl-v) mode swap initialized"
  endif
endfunction

" ---------------------------------------------------------------------

" VisualSwap: Perform the swap:
"
"             Yanks both visual selections into the a and b registers
"             (their original contents will be restored later)
"
"             Based on visual mode and where the two zones start:
"               A zone will be deleted and the appropriate register
"               used to put in the new contents.
"               Then the other zone will be deleted and the other
"               register's contents will inserted.
fu! s:VisualSwap()
  let s:vismode2      = visualmode()
  let s:startswapline2= line("'<")
  let s:startswapcol2 = virtcol("'<")
  let s:endswapline2  = line("'>")
  let s:endswapcol2   = virtcol("'>")

  let keep_rega= @a
  let keep_regb= @b

  exe "norm! ".s:startswapline1."G".s:startswapcol1."|".s:vismode1.s:endswapline1."G".s:endswapcol1.'|"ay'
  exe "norm! ".s:startswapline2."G".s:startswapcol2."|".s:vismode2.s:endswapline2."G".s:endswapcol2.'|"by'

  if ( s:vismode1 =~ "[vV]" && s:startswapline1 < s:startswapline2 || ( s:startswapline1 == s:startswapline2 && s:startswapcol1 < s:startswapcol2 ) ) || ( s:startswapcol1 <= s:startswapcol2 )
   exe "norm! ".s:startswapline2."G".s:startswapcol2."|".s:vismode2.s:endswapline2."G".s:endswapcol2.'|x"aP'
   exe "norm! ".s:startswapline1."G".s:startswapcol1."|".s:vismode1.s:endswapline1."G".s:endswapcol1.'|x"bP'
  else
   exe "norm! ".s:startswapline1."G".s:startswapcol1."|".s:vismode1.s:endswapline1."G".s:endswapcol1.'|x"bP'
   exe "norm! ".s:startswapline2."G".s:startswapcol2."|".s:vismode2.s:endswapline2."G".s:endswapcol2.'|x"aP'
  endif

  let @a= keep_rega
  let @b= keep_regb
endfunction
" ---------------------------------------------------------------------
