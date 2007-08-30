" Vim plugin -- for a given script karma, print possible user votes
" File:         karma.vim
" Created:      2007 Aug 29
" Last Change:  2007 Aug 29
" Author:	Andy Wokula <anwoku@yahoo.de>
" Version:	2

" Installation:
"   :source karma.vim
" or put the file into the ~/.vim/plugin/ folder
"
" Usage:
"   :Karma {score} {votes}
"
" http://vim.sourceforge.net/karma.php
"   script karma    Rating {score}/{votes}, Downloaded by ...
"
" Note: the math is derived from an example, I didn't prove anything

" Credits:
" rewrite of vimscript #936
" Karma Decompiler : Makes statistics based on Karma

if exists("loaded_karma")
    finish
endif
let loaded_karma = 1

if v:version<700
    echo "karma: you need Vim7"
    finish
endif

function! s:Karma(...)
    if a:0 < 2
	echo ":Karma {score} {votes}"
	return
    endif

    let score = a:1+0	" 2155
    let votes = a:2+0	" 659

    echo "Karma:" score."/".votes

    let pm = score / 4    " 538, close to score, still missing votes (p)
    let mv = votes - pm   " 121, number of missing votes
    let sth = pm * 4 + mv  " 2273, score too high, votes ok (p, q)
    let sd = (sth - score)/3 " 39, score diff
    let p = pm - sd	    " 499, lower bound for Life Changing
    let q = mv + sd	    " 160, upper bound for Helpful
    let r = 0		    " 0, min for Unfulfilling
    let s = p*4 + q - r	    " 2156 = 499*4 + 160 - 0
    let sd = 0		    " declare var unused
    if (score-s)%2
	" adjusting with q and r requires an even difference
	let p += 1	    " 500
	let q -= 1	    " 159
    endif
    let sd = (p*4 + q - r - score)/2    " adjust with q and r
    let q -= sd	    " 157
    let r += sd	    " 2

    " :Karma 15 19  vs.  :Karma 15 21
    if p < 0
	let sd = -p / 2 + -p % 2
	let p += 2*sd
	let q -= 5*sd
	let r += 3*sd
    endif

    echo "   1. Life Changing:" p "  Helpful:" q "  Unfulfilling:" r
    " echo "      Check:  Score =" 4*p+q-r "  Votes =" p+q+r
    if p < 0 || q < 0 || r < 0
	echohl WarningMsg
	echo "This score is not possible, typo?"
	echohl none
	return
    endif
    let p+=2
    let q-=5
    let r+=3
    if q < 0
	return
    endif
    echo "   2. Life Changing:" p "  Helpful:" q "  Unfulfilling:" r
    " echo "      Check:  Score =" 4*p+q-r "  Votes =" p+q+r

    let bm = q/5
    let p += bm*2
    let q -= bm*5
    let r += bm*3
    if bm==0
	return
    endif
    if bm>1
	echo "      ..."
    endif
    echo ("    ".(bm+2))[-4:].". Life Changing:" p "  Helpful:" q "  Unfulfilling:" r
    " echo "      Check:  Score =" 4*p+q-r "  Votes =" p+q+r
endfunction

command! -nargs=* Karma call s:Karma(<f-args>)

" vim:set ts=8 sts=4 noet:
