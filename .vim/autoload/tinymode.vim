" Vim autoload plugin - provide "tiny modes" for Normal mode
" File:         tinymode.vim
" Created:      2008 Apr 29
" Last Change:  2008 May 14
" Rev Days:     4
" Author:	Andy Wokula <anwoku@yahoo.de>
" Version:	0.3

" Description:
"   tinymode provides functions to define new Vim modes -- "tiny modes".
"   A "tiny mode" (or "sub mode") is almost like any other Vim mode.
"
"   It has a name that identifies it, mappings that enter the mode, mappings
"   defined within the mode.  There can be a permanent mode message in the
"   command-line that indicates the active mode and can show the available
"   keys.
"
"   Leaving is different: Any key not mapped in the mode goes back to Normal
"   mode and executes there.  The mode is also left automatically when not
"   pressing a key for 'timeoutlen' ms (and 'timeout' is on).  The escape
"   key just leaves the mode.
"
"   tinymode.vim is friendly to your mappings, they aren't touched in any
"   way.  getchar() is not used, the cursor doesn't move to the command-line
"   waiting for a character.
"
"   The count: an initial count is always processed, a count typed within
"   the mode either leaves the mode (default) or is processed within the
"   mode:
"	call tinymode#ModeArg("owncount")
"   Put a placeholder "[N]" for the count in your commands.
"
" Examples:
"   see tinym_ex.vim

" Installation:
"   copy file into your ~\vimfiles\autoload folder (or a similar autoload
"   folder)
"
" Usage:
" - call the functions
"	tinymode#EnterMap()
"	tinymode#ModeMsg()
"	tinymode#Map()
"	tinymode#ModeArg()
"   from your vimrc or interactively to define any number of new tiny modes.
" - increase 'timeoutlen' if 1 second is too short

" TODO
" - key(s) for leaving the mode tinymode#LeaveMap()
" - timeout after N x 'timeoutlen', 0 to disable timeout
" ? recursive modes
" ? enter a tiny mode from other Vim modes
" ? <Del> to remove a digit from the count typed so far
"   ! too complicated
" + (v0.2) count: count on mode enter and count within mode, give
"   unprocessed count back to Normal mode
" + (v0.3) commands to execute when entering/leaving the mode

" Bugs:
" - a Beep! quits the mode (breaks the chain of maps) bypassing <sid>clean()
"   ! nfi how to fix this, cannot detect the beep
" + Map() cannot map keycodes, the timeout doesn't work
" + (v0.3) Map(..., "r", "norm zr") followed by EnterMap(..., "zr", "r")
"   inits an empty map for "r"
" + (v0.3) support i_Ctrl-O: go back to Insert mode when a mode finishes

" To Self:
"   :h vim-modes
" - keys in a mode are not mapped directly to a command, the same key might
"   be reused by another mode; we need to either copy or dereference {rhs}s

" Init: "{{{
nn <sid>do :<c-u>call <sid>action
nn <sid>atc :<c-u>call <sid>addtocount
nn <script><silent> <sid>clean :call <sid>clean()<cr><sid>fdc
" feed count to Normal mode
nmap <expr> <sid>fdc <sid>count()
let s:quitnormal = 1
nmap <sid>r <sid>_
ino <script> <sid>r <C-O><sid>r
ino <sid>fdc x<BS>

" nn <sid>_ <sid>_
" let mp = maparg("<sid>_")

if !exists("g:tinymode#modes")
    let g:tinymode#modes = {}
endif
if !exists("g:tinymode#defaults")
    let g:tinymode#defaults = {
		\   "owncount": '\C\[N]'
		\,  "entercmd": "", "leavecmd": "" }
endif

"}}}

func! tinymode#enter(mode, startkey) "{{{
    nn <script> <sid>_ <sid>clean
    nn <script> <sid>_<esc> <sid>clean

    if s:quitnormal
	let s:sav_sc = &sc
    endif
    set noshowcmd
    let s:quitnormal = 0
    let s:goterror = 0

    let s:curmode = g:tinymode#modes[a:mode]

    let s:count = v:count>0 ? v:count : ""
    if has_key(s:curmode, "owncount")
	let s:countpat = s:curmode.owncount
	for digit in range(0, 9)
	    exec "nn <script><silent> <sid>_".digit '<sid>atc("'.digit.'")<cr><sid>r'
	endfor
    else
	let s:countpat = g:tinymode#defaults.owncount
    endif
    for key in keys(s:curmode.map)
	exec "nn <script><silent> <sid>_".key '<sid>do("'.s:esclt(key).'")<cr><sid>r'
    endfor
    if has_key(s:curmode, "entercmd")
	try
	    exec s:curmode.entercmd
	catch
	    call <sid>clean()
	    call s:showexception()
	    return
	endtry
    endif
    call <sid>action(a:startkey)
endfunc "}}}

func! <sid>action(key) "{{{
    let cmd = get(s:curmode.map, a:key, "")
    try
	exec substitute(cmd, s:countpat, s:count, 'g')
    catch
	call <sid>clean()
	call s:showexception()
	return
    endtry
    let s:count = ""
    if has_key(s:curmode, "redraw")
	redraw
    endif
    call s:showmodemsg()
endfunc "}}}

func! <sid>addtocount(digit) "{{{
    let s:count .= a:digit
    call s:showmodemsg()
endfunc "}}}

func! <sid>count() "{{{
    return s:count
endfunc "}}}

func! s:showmodemsg() "{{{
    if has_key(s:curmode, "msg")
	echohl ModeMsg
	if s:count == ""
	    echo s:curmode.msg
	else
	    echo s:curmode.msg. " /". s:count
	endif
	echohl none
    endif
endfunc "}}}

func! <sid>clean() "{{{
    if has_key(s:curmode, "leavecmd")
	try
	    exec s:curmode.leavecmd
	catch
	    call s:showexception()
	endtry
    endif
    try
	call tinymode#MapClear()
    catch
	call s:showexception()
    endtry
    let &sc = s:sav_sc
    let s:quitnormal = 1
    if !s:goterror
	exec "norm! :\<c-u>"
    endif
endfunc "}}}

func! s:esclt(key) "{{{
    return substitute(a:key, "<", "<lt>", "g")
endfunc "}}}

func! s:showexception() "{{{
    let s:goterror = 1
    echohl ErrorMsg
    if v:exception =~ '^Vim'
	echomsg matchstr(v:exception, ':\zs.*')
    else
	echomsg v:exception
    endif
    echohl none
    " sleep 2
endfunc "}}}

" Interface:
" mode is an arbitrary, unique name to identify the mode
" the following functions can be called in any order

" Map a Normal mode {key} that enters the new {mode}.  {startkey} can
" simulate an initial keypress in the new mode.
func! tinymode#EnterMap(mode, key, ...) "{{{
    " a:1 -- startkey
    let startkey = a:0>=1 ? escape(a:1, '\"') : ""
    let mode = escape(a:mode, '\"')
    exec "nn <script><silent>" a:key ':<c-u>call tinymode#enter("'.mode.'", "'.s:esclt(startkey).'")<cr><sid>r'

    if startkey == "" || exists('g:tinymode#modes[a:mode].map[startkey]')
	return
    endif
    try
	let g:tinymode#modes[a:mode].map[startkey] = ""
    catch
	if !has_key(g:tinymode#modes, a:mode)
	    let g:tinymode#modes[a:mode] = {"map": {startkey : ""}}
	else
	    let g:tinymode#modes[a:mode].map = {startkey : ""}
	endif
    endtry
endfunc "}}}

" Define a permanent {message} for the command-line, useful to know which
" {mode} you are in; if your commands overwrite the message, try setting
" {redraw} to 1
func! tinymode#ModeMsg(mode, message, ...) "{{{
    " a:1 -- redraw (1 or default 0)
    if a:message == ""
	sil! unlet g:tinymode#modes[a:mode].msg
	sil! unlet g:tinymode#modes[a:mode].redraw
	return
    endif
    let redraw = a:0>=1 ? a:1 : 0
    try
	let g:tinymode#modes[a:mode].msg = a:message
    catch
	let g:tinymode#modes[a:mode] = {"msg": a:message}
    endtry
    if redraw
	let g:tinymode#modes[a:mode].redraw = 1
    endif
endfunc "}}}

" Map a {key} to an Ex-{command} within the new {mode}.  You can use
" ":normal" to execute Normal mode commands from the mapping and to control
" remapping of keys.  Place "[N]" in the command for the count.
func! tinymode#Map(mode, key, command) "{{{
    try
	let g:tinymode#modes[a:mode].map[a:key] = a:command
    catch
	if !has_key(g:tinymode#modes, a:mode)
	    let g:tinymode#modes[a:mode] = {"map": {a:key : a:command}}
	else
	    let g:tinymode#modes[a:mode].map = {a:key : a:command}
	endif
    endtry
endfunc "}}}

com! -bar LeaveMode call feedkeys("\e")

" Set a {mode}-local {option} to a given {value}.  Every {option} is also
" boolean: it can exist or not exist.
" Description: {option}: {value} "{{{
" "owncount": if set, typed digits are processed within the mode; value is a
"	pattern for replacing the count placeholder in a command (default
"	'\C\[N]')
" "entercmd": command to execute when entering the mode, before simulating
"	any startkey (default "")
" "leavecmd": command to execute when leaving the mode (default "")
" TODO still unused:
" "timeout": multiple of 'timeoutlen'
" "}}}
func! tinymode#ModeArg(mode, option, ...) "{{{
    " a:1 -- {value} (default depends on option)
    if !has_key(g:tinymode#defaults, a:option)
	echomsg "tinymode: not a valid modearg: '".a:option."'"
	return
    endif
    let value = a:0>=1 ? a:1 : g:tinymode#defaults[a:option]
    try
	let g:tinymode#modes[a:mode][a:option] = value
    catch
	let g:tinymode#modes[a:mode] = {a:option : value}
    endtry
endfunc "}}}

" like :mapclear for {mode}
func! tinymode#MapClear(...) "{{{
    if a:0 >= 1
	let mode = a:1
	let db = g:tinymode#modes[mode]
    else
	let db = s:curmode
    endif
    if has_key(db, "owncount")
	for digit in range(0, 9)
	    exec "sil! unmap <sid>_". digit
	endfor
    endif
    for key in keys(db.map)
	exec "sil! unmap <sid>_". key
    endfor
endfunc "}}}

" " delete a tinymode, including the EnterMap() mappings
" func! tinymode#DeleteMode(mode) "{{{
"     call tinymode#MapClear(a:mode)
"     unlet g:tinymode#modes[a:mode]
"     let escmode = escape(a:mode, '\"')
"     for key in anwolib#MappingsTo('tinymode#enter("'.escmode.'"', "n")
" 	exec "nunmap" key
"     endfor
" endfunc "}}}

" vim:set fdm=marker ts=8 sts=4 sw=4 noet:
