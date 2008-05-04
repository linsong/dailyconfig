" File:         tinym_ex.vim
" Created:      2008 Apr 29
" Last Change:  2008 May 01
" Author:	Andy Wokula <anwoku@yahoo.de>
" Version:	0.2

" examples for tinymode.vim
" Usage:
"   :so %
" or load once from any place:
"   :call tinym_ex#require()

" tiny mode is left after 'timeoutlen' ms
set timeoutlen=3000

" Mode1: cycle tab pages, enter mode with "gt" or "gT", keys in the mode:
" "0", "t", "T", "$", type a Normal mode command to leave mode or wait 3 s
call tinymode#EnterMap("mode1", "gt", "t")
call tinymode#EnterMap("mode1", "gT", "T")
call tinymode#ModeMsg("mode1", "Cycle tab pages [0/t/T/$]", 1)
call tinymode#ModeArg("mode1", "owncount")
call tinymode#Map("mode1", "0", "tabfirst")
call tinymode#Map("mode1", "t", "norm! [N]gt")
call tinymode#Map("mode1", "T", "norm! [N]gT")
call tinymode#Map("mode1", "$", "tablast")
" easter eggs
call tinymode#Map("mode1", "n", "tabnew")
call tinymode#Map("mode1", "c", "tabclose")

" Mode2: cycle through 'cursorline' and 'cursorcolumn', enter mode with
" <Leader>c or <Leader>C
call tinymode#EnterMap("cucl", "<Leader>c", "c")
call tinymode#EnterMap("cucl", "<Leader>C", "C")
call tinymode#ModeMsg("cucl", "Toggle 'cuc'+'cul' [c/C/o(f)f]")
call tinymode#Map("cucl", "c", "let [&l:cuc,&l:cul] = [&cul,!&cuc]")
call tinymode#Map("cucl", "C", "let [&l:cuc,&l:cul] = [!&cul,&cuc]")
call tinymode#Map("cucl", "f", "setl nocuc nocul")

" Mode3: toggle 'debug' values
call tinymode#EnterMap("debug", "<Leader>d", "<Nop>")
" no message
call tinymode#Map("debug", "b", "call tinym_ex#ToggleDebug('beep')")
call tinymode#Map("debug", "m", "call tinym_ex#ToggleDebug('msg')")
call tinymode#Map("debug", "t", "call tinym_ex#ToggleDebug('throw')")
call tinymode#Map("debug", "<Nop>", "call tinym_ex#ToggleDebug('')")

func! tinym_ex#ToggleDebug(value)
    " 'debug' is buggy, debug+=value doesn't work if not empty
    if a:value != ""
	if &debug == ""
	    let &debug = a:value
	elseif &debug =~ a:value
	    let pat =  a:value.',\|,'.a:value.'\|'.a:value
	    let &debug = substitute(&debug, pat, '', '')
	else
	    let &debug .= ",". a:value
	endif
    endif
    echo printf("  debug=%.14s  (b)eep/(m)sg/(t)hrow", &debug. repeat(" ", 14))
endfunc

" Note:
"   :call s:ToggleDebug('beep')
" doesn't work, because the call happens in the context of tinymode.vim.
" Sorry we need to determine the <SNR> of THIS script.  OR with luck, THIS
" is an autoload script.  OR ... simply call a global function.

" Mode4: change window size
call tinymode#EnterMap("winsize", "<C-W>>", ">")
call tinymode#EnterMap("winsize", "<C-W><", "<")
call tinymode#EnterMap("winsize", "<C-W>+", "+")
call tinymode#EnterMap("winsize", "<C-W>-", "-")
call tinymode#ModeMsg("winsize", "Change window size +/-/</>/t/b/w/W")
call tinymode#Map("winsize", ">", "#wincmd >")
call tinymode#Map("winsize", "<", "#wincmd <")
call tinymode#Map("winsize", "+", "#wincmd +")
call tinymode#Map("winsize", "-", "#wincmd -")
call tinymode#Map("winsize", "_", "#wincmd -")
call tinymode#Map("winsize", "t", "#wincmd t")
call tinymode#Map("winsize", "b", "#wincmd b")
call tinymode#Map("winsize", "w", "sil! #wincmd w")
call tinymode#Map("winsize", "W", "sil! #wincmd W")
" keep the mode active when typing digits:
call tinymode#ModeArg("winsize", "owncount", "#")

" echo tinymode#modes

func! tinym_ex#require()
endfunc

" vim:set isk+=# ts=8 sts=4 sw=4 noet:
