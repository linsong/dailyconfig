" WhereFrom.vim
"  Author:	Charles E. Campbell, Jr.
"  Date:	Apr 20, 2005
"  Version:	2
"
"  Usage: {{{1
"    WhereFrom[!] functionname(s)      WF[!] functionname(s)
"    WhereFrom[!] map(s)               WF[!] map(s)
"    WhereFrom[!] setting(s)           WF[!] setting(s)
"    WhereFrom[!] command(s)           WF[!] command(s)
"
"    The command searches the runtimepath (see :he runtimepath) to
"    determine where the function, map, or command is written.
"    With the "!", WhereFrom will continue looking for more than
"    one instance.
"
"    WF-style commands are available only if the command has
"    not been previously defined.
"
" GetLatestVimScripts: 1203 1 :AutoInstall: WhereFrom.vim
" GetLatestVimScripts: 1066 1 :AutoInstall: cecutil.vim

" ---------------------------------------------------------------------
"  Load Once: {{{1
if exists("g:loaded_WhereFrom")
 finish
endif
let s:keepcpo          = &cpo
let g:loaded_WhereFrom = "v2"
set cpo&vim

" ---------------------------------------------------------------------
"  Public Interface: {{{1
com! -bang -nargs=+ WhereFrom :call s:WhereFrom(<bang>0,<f-args>)
silent! com -bang -nargs=+ WF :call s:WhereFrom(<bang>0,<f-args>)

" ---------------------------------------------------------------------
"  Support Functions: {{{1
" ---------------------------------------------------------------------
" WhereFrom: {{{2
fun! s:WhereFrom(bang,...)
"  call Dfunc("WhereFrom(bang=".a:bang."...) a:0=".a:0)

  " --------------------
  " initialize settings: {{{3
  " --------------------
  let iarg   = 1
  let akeep  = @a
  let eikeep = &ei
  let lzkeep = &lz
  set ei=all
  set lz
  let s:keeplastbufnr = bufnr("$")

  " for all arguments on the command line...
  while iarg <= a:0
"   call Decho(iarg.") <".a:{iarg}.">")

   " ---------------------------
   "  is the argument a mapping? {{{3
   " ---------------------------
   if maparg(a:{iarg},"") != "" || maparg(a:{iarg},"i") != "" || maparg(a:{iarg},"c") != "" || maparg(a:{iarg},"l") != ""
    if exists("g:mapleader") && match(a:{iarg},'^'.g:mapleader) == 0
    	" allow a:{iarg} to handle map...<Leader>modsrch
	 let mlgt      = '[>'.escape(escape(g:mapleader,'\'),'\').']'
	 let modsrch   = substitute(a:{iarg},g:mapleader,mlgt,'')
    else
    	" support searching for maps or commands
	 let mlgt      = '[>\\\\]'
	 let modsrch   = substitute(a:{iarg},'^\\',mlgt,'')
    endif
    call WhereFromSrch(a:bang,a:{iarg},'\(map\|[nvoilc]m\%[ap]\|\([oilc]\=no\|[nv]n\)\%[remap]\|com\%[mand]\)!\=\s.*'.modsrch.'\s')
    let foundit = 1
    let iarg    = iarg + 1
    continue
   else
"    call Decho("not a mapping")
   endif

   " don't even bother looking further if there's a
   " non-alphanumeric character involved
   if a:{iarg} =~ '\W'
    let iarg= iarg + 1
    continue
   endif

   " --------------------------
   " is the argument a setting? {{{3
   " --------------------------
   let foundit= 1
   try
   	redir @a
	exe "keepjumps silent verbose set ".a:{iarg}."?"
	redir END
   catch /^Vim\%((\a\+)\)\=:E518/
   	" Not a setting
"   	call Decho("catch occurred on a:{".iarg."}<".a:{iarg}.">")
    let foundit= 0
   endtry
   if foundit
    echomsg substitute(@a,'^.*\(Last.*\)$',a:{iarg}.': \1','')
	let iarg= iarg + 1
	continue
   else
"   	call Decho("not a setting")
   endif

   " --------------------------------
   " is the argument an abbreviation? {{{3
   " --------------------------------
   let foundit= 0
   redir @a
   exe "keepjumps silent ab ".a:{iarg}
   redir END
   if @a =~ '\<'.a:{iarg}.'\>' && @a != "No abbreviation found"
    call WhereFromSrch(a:bang,a:{iarg},'ab\%[breviate]\s\+'.a:{iarg}.'\>')
	let foundit = 1
	let iarg    = iarg + 1
	continue
   else
"   	call Decho("not an abbreviation")
   endif

  " ---------------------------
  "  is the argument a command? {{{3
  " ---------------------------
   redir @a
    exe "keepjumps silent com ".a:{iarg}
   redir END
   if @a =~ "\n".'....\zs\<'.a:{iarg}.'\>'
"   call Decho("found a command a:{".iarg."}<".a:{iarg}.">")
    call WhereFromSrch(a:bang,a:{iarg},'\<com\%[mand]\>.*\<'.a:{iarg}.'\>')
    let foundit = 1
    let iarg    = iarg + 1
    continue
   else
"   call Decho("not a command")
   endif

   " -----------------------------
   "   is the argument a function? {{{3
   " -----------------------------
   let foundit= 0
   redir @a
    exe "keepjumps silent! function ".a:{iarg}
   redir END
   if @a =~ 'function \%('.a:{iarg}.'\|\S*_'.a:{iarg}.'\)('
    call WhereFromSrch(a:bang,a:{iarg},'\<fu\%[nction]!\=\s*\(<[sS][iI][dD]>\|[sS]:\)\='.a:{iarg}.'\>')
    let foundit = 1
    let iarg    = iarg + 1
    continue
   else
"    call Decho("not a function")
   endif

   " report if unable to find requested argument
   if !foundit
    echomsg "***WhereFrom*** sorry, am unable to find <".a:{iarg}.">"
   endif

   " update command being searched for
   let iarg= iarg + 1
  endwhile

  " ------------------------------
  " restore registers and settings {{{3
  " ------------------------------
  let @a  = akeep
  let &ei = eikeep
  let &lz = lzkeep
"  call Dret("WhereFrom : foundit=".foundit)
endfun

" ---------------------------------------------------------------------
" WhereFromSrch: {{{2
"   Implements search for a pattern in files in the runtimepath
fun! WhereFromSrch(bang,object,srchstring)
"  call Dfunc("WhereFromSrch(bang=".a:bang." object<".a:object."> srchstring<".a:srchstring.">)")
  " initialize search {{{3
  let foundit       = 0
  let srchstring    = a:srchstring
"  call Decho("keeplastbufnr=".s:keeplastbufnr)

  " set up list of files to be searched {{{3
  let vimfiles=expand("$HOME")."/.vimrc"
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"plugin/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"AsNeeded/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"ftplugin/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"ftplugin/*/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"colors/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"compiler/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"indent/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"syntax/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"syntax/*/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"after/ftplugin/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"after/colors/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"after/compiler/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"after/indent/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"after/plugin/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"after/ftplugin/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"after/ftplugin/*/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"after/syntax/*.vim"),'\n',',',"ge")
  let vimfiles=vimfiles.",".substitute(globpath(&rtp,"after/syntax/*/*.vim"),'\n',',',"ge")
  silent 1new! WhereFromBuffer
  let wfbufnr= bufnr("%")
"  call Decho("wfbufnr=".wfbufnr)
  setlocal buftype=nofile noswapfile noro nobl
  let vimfiles= substitute(vimfiles,',\+',',','ge')
"  call Decho("vimfiles: ".vimfiles)

  " search files {{{3
  while vimfiles != ""
   let vimfile = substitute(vimfiles,',.*$','','e')
   let vimfiles= (vimfiles =~ ",")? substitute(vimfiles,'^[^,]*,\(.*\)$','\1','e') : ""
"   call Decho("..considering file<".vimfile.">")
   if !filereadable(vimfile)
    let vimfile= ""
   	continue
   endif
   silent! %d
   exe "silent 0r ".vimfile
   if bufnr("$") > wfbufnr
"   	call Decho("bwipe read-in buf#".bufnr("$"))
    exe bufnr("$")."bwipe!"
   endif
"   call Decho("srchstring<".srchstring.">")
   let srchresult= search(srchstring)
   if srchresult != 0
    let mapstring = getline(srchresult)
"	call Decho(a:object.": defined in file<".vimfile."> line#".line("."))
    echomsg a:object.": defined in file<".vimfile."> line#".line(".")
    let foundit= 1
	if a:bang == 0
	 break
	endif
   endif
   let vimfile= ""
  endwhile

  " cleanup {{{3
  if wfbufnr > s:keeplastbufnr && bufloaded(wfbufnr)
"   call Decho("bwipe wherefrombuf#".wfbufnr." keeplastbufnr=".s:keeplastbufnr)
   exe wfbufnr."bwipe!"
  endif

  " report a failure to find the object {{{3
  if !foundit
   echomsg a:object.": its defined, but its not on the runtimepath"
  endif
"  call Dret("WhereFromSrch")
endfun

let &cpo= s:keepcpo
unlet s:keepcpo
" ---------------------------------------------------------------------
"  Modelines: {{{1
"  vim: ts=4 fdm=marker
