"  Description: some useful functions collected from web
"  	Maintainer: Linsong Wang (linsong dot qizi at gmail dot com)
"  Last Change: Fri Sep 30 10:12:45 CST 2005
"      Version: 1.0
"      History: 
"      		    * add TextEnableCodeSnip function that support 
"				  highlight several different parts of source 
"				  codes at the same time
"        Usage: 
"               read the documents around the commands/functions
" avoid reload script {{{1
if exists("loaded_misc")
	finish
endif
let loaded_misc = 1

function! s:TextEnableCodeSnip(filetype,start,end) abort
  let ft=toupper(a:filetype)
  let group='textGroup'.ft
  execute 'syntax include @'.group.' syntax/'.a:filetype.'.vim'
  unlet b:current_syntax
  execute 'syntax region textSnip'.ft.'
    \ matchgroup=textSnip
    \ start="'.a:start.'" end="'.a:end.'"
    \ contains=@'.group
  hi link textSnip SpecialComment
endfunction 
command -nargs=+ -range TextEnableCodeSnip call <SID>TextEnableCodeSnip(<f-args>)

function! s:Count( patt) range
  if a:patt == ""
    let patt = @/
  else
    let patt = a:patt
  endif
  let m = 0
  let n = a:firstline
  while n <= a:lastline
    let l = getline( n)
    let s = 0
    while 1
      let olds = s
      let s = matchend( l, patt, s)
      if s == olds
        throw "pattern " . patt . " found infinitely often."
      endif
      if s == -1
          break
      endif
      let m = m + 1
    endwhile
    let n = n + 1
  endwhile
  echo m . " occurrence".(m==1 ? "" : "s")." of pattern " . patt
endfunction
command! -nargs=* -range=% Count <line1>,<line2>call <SID>Count(<q-args>)

function! s:IndentObject( mode )
	if a:mode == 'a' 
		let temp_var=indent(line(".")) 
		let s:count = 0
		let s:start = line(".")
		while indent(s:start+s:count+1) >= temp_var
			let s:count = s:count + 1
		endwhile  
		exe "norm g0"
		exe "norm " . s:count . "j"  
	else
		echo "not implement yet. coming soon"
	endif
endfunction
command! -nargs=1 -range IndentObject call <SID>IndentObject(<q-args>)

" visit http://vim.sourceforge.net/tips/tip.php?tip_id=1030 for more details
" about following command
function! s:DiffWithSaved() 
	let filetype=&ft 
	diffthis 
	" new | r # | normal 1Gdd - for horizontal split 
	vnew | r # | normal 1Gdd 
	diffthis 
	exe "setlocal bt=nofile bh=wipe nobl noswf ro ft=" . filetype 
endfunction 
com! Diff call s:DiffWithSaved() 
		  
