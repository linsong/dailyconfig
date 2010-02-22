"  Description: My own functions and commands for daily use
"  				hope this will let my(perhaps yours) Vimming life easier :)
"  	Maintainer: Linsong Wang (linsong dot qizi at gmail dot com)
"  Last Change: Sun Aug 21 15:26:04     2005
"      Version: 1.0
"      History: 
"      		    1.0) add a command MyWrap 	
"        Usage: 
"               read the documents around the commands/functions
" avoid reload script {{{1
if exists("loaded_myplugin")
	finish
endif

let loaded_myplugin = 1

" MyWrap command {{{1
"Usage: 
"       select some words by visual mode(all types of visual mode), then on
"       command line use this command like the following:
"       :'<,'>MyWrap "
"       then the selected words will be wrapped with " :
"       "SELECTION"
"       Another example: select some words by visual mode,then
"       :'<,'>MyWrap <<<
"       then the selection will be wrapped with '<<<' and '>>>' :
"       <<<SELECTION>>>
"       
" NOTE: if we use <q-args>, vim always parse all arguments as the whole;
" but by <f-args>, it will split arguments by space
command -nargs=+ -range MyWrap call <SID>WrapRegion(<f-args>)

function s:GetMatchWord(word)
	let len = strlen(a:word)
	let result = ""
	let i = 0
	while i<len
		let w = a:word[i]
		if w == '<'
			let result = '>' . result
		elseif w == '('              
			let result = ')' . result
		elseif w == '['              
			let result = ']' . result
		elseif w == '{'              
			let result = '}' . result
		else                         
			let result = w   . result
		endif
		let i = i+1
	endwhile
	if strlen(result)==0
		result = a:word
	endif
	return result
endfunction

function s:WrapRegion(...)
	if a:0 == 1
		let wrapWord0 = a:1
		let wrapWord1 = s:GetMatchWord(wrapWord0)
	elseif a:0 > 1
		let wrapWord0 = a:1
		let wrapWord1 = a:2
	endif

	"modify the end first, because if we modify the beginning first, the '>
	"will get a wrong position since the visual region has been changed
	exec "norm `>a".wrapWord1."\<ESC>"
	exec "norm `<i".wrapWord0."\<ESC>"
endfunction

" MyCount(initial,delta) {{{1
" MyCount function to get a number sequence,this is very useful when we want
" to substitute a number sequence to lines, for example:
"     :let i=0 | %s/^hello.*$/\=submatch(0).MyCount("i",10)
" the above command will append 10,20,30,40 ... to all lines that start with
" "hello".
" Note: another method(maybe more flexible) to do it is: 
"  g// s/^\([^ ]\+\)\s\(.*\)$/\="File" . i . "=" . submatch(1) . "^M" . "Title" . i . "=" . submatch(2) . "^M" . "Length" . i . "=-1"/ | let i +=1
"  the command after "g//" will be executed for every line
"
" the second argument is the delta value
function! MyCount(initial,...)
	if a:0 > 0
		let delta = a:1
	else
		let delta = 1
	endif
	let g:{a:initial} = g:{a:initial} + delta
	return g:{a:initial}
endfunction

"Time2Data(time) {{{1
"for example: 
"   :let res = Time2Data("0:08")
function! s:StripLeftZero(strTime)
	let len = strlen(a:strTime)
	if len>1 && strpart(a:strTime,0,1)=='0'
		return strpart(a:strTime,1,len-1)
	else
		return a:strTime
	endif
endfunction

function! Time2Data(time)
	let index = stridx(a:time,":")	
	let mins = s:StripLeftZero(strpart(a:time,0,index))
	let seconds = s:StripLeftZero(strpart(a:time,index+1,strlen(a:time)-1-index))
	return mins*60+seconds
endfunction

" Python script in Vim demonstration {{{1
" the following codes demonstrate how to use python in vim scripts, this will
" be helpful when we need complexed script that vim script is not competent.

if has("python")

" we can defines python functions here
python << EOF
def printArgs():
	print "arguments passed to python function:  "
	for arg in sys.argv:
		print arg
	print "python: Bye!"
EOF

function! MyPythonTest(...)
	let len = a:0
	python import sys
	while len>0
		" NOTE: the following demonstrate how to pass arguments to python's
		" codes. for now, passing arguments by sys is the only way.
		exec 'python sys.argv.append("'.a:{len}'")'	
		let len=len-1
	endwhile

	python printArgs()
endfunction

endif

"  GetVisualSelectionEscaped function, borrowed from mark.vim {{{1
function! s:GetVisualSelection()
    let save_a = @a
    silent normal! gv"ay
    let res = @a
    let @a = save_a
    return res
endfunction

function! GetVisualSelectionEscaped(flags)
    " flags:
    "  "e" \  -> \\  
    "  "n" \n -> \\n  for multi-lines visual selection
    "  "N" \n removed
    "  "V" \V added   for marking plain ^, $, etc.
    let result = s:GetVisualSelection()
    let i = 0
    while i < strlen(a:flags)
            if a:flags[i] ==# "e"
                    let result = escape(result, '\')
            elseif a:flags[i] ==# "n"
                    let result = substitute(result, '\n', '\\n', 'g')
            elseif a:flags[i] ==# "N"
                    let result = substitute(result, '\n', '', 'g')
            elseif a:flags[i] ==# "V"
                    let result = '\V' . result
            endif
            let i = i + 1
    endwhile
    return result
endfunction
"  }}}1

"Toggle Transparency {{{1
function! ToggleTransparency()	
    let new_val = 100 - str2nr(&transparency)
    exec "set transparency=" . new_val
endfunction
"}}}1

"display git branch info is possible {{{1
function! StatusInfo()
  if exists('*fugitive#statusline')
    return fugitive#statusline()
  else
    return ''
  endif
endfunction
"}}}1

" vim:ft=vim foldmethod=marker ts=4 sw=4 expandtab
