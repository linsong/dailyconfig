" Shortcut for making substitutions using KeepCase.
" Just use:
"   :[range]call S('search','replace')
" to replace "search" with "replace" across optional [range] while preserving 
" case.
function! S(pat,sub) range
  execute a:firstline . "," . a:lastline . "s/" . a:pat . "/\\=KeepCase(submatch(0),'" . a:sub . "')/g"
endfunction

" Shortcut for making substitutions using KeepCaseSameLen.
" Just use:
"   :[range]call SS('search','replace')
" to replace "search" with "replace" across optional [range] while preserving 
" case letter-for-letter.
function! SS(pat,sub) range
  execute a:firstline . "," . a:lastline . "s/" . a:pat . "/\\=KeepCaseSameLen(submatch(0),'" . a:sub . "')/g"
endfunction
