" File:          screenpaste.vim
" Description:   pastes/inserts current GNU Screen buffer in (almost) any mode
" Version:       5.92
" Mercurial:     $Id: screenpaste.vim,v 41183f681647 2008-01-06 17:29 +0100 blacktrash $
" Author:        Christian Ebert <blacktrash@gmx.net>
" Credits:       Mathieu Clabaut and Guo-Peng Wen for inline doc self-install code
" URL:           http://www.vim.org/script.php?script_id=1512
" Requirements:  GNU Screen must be in $PATH
" Documentation: :help screenpaste
"                self installing to its current version when plugin is loaded
"                to review before install go to last section of this file
"
" GetLatestVimScripts: 1512 1 :AutoInstall: screenpaste.vim

" Init: store 'compatible' settings {{{1
let s:save_cpo = &cpo
set cpo&vim

if !exists("g:loaded_screenpaste")
  " Fast Load: global vars, mappings, commands, doc install
  " load functions only on demand via autocmd
  " at Vim startup only run checks, load global vars, mappings, commands,
  " and install Help if not up to date or not present

  " full path to plugin -- needed for Screen_UpdateDocs and demand load
  let s:plug_path = expand("<sfile>:p")
  " name of plugin w/o extension for messages
  let s:plug_name = fnamemodify(s:plug_path, ":t:r")

  " Global Variables: {{{1
  " g:screen_executable: name of GNU Screen executable
  if !exists("g:screen_executable")
    let g:screen_executable = "screen"
  endif

  " g:screen_clmode: how screenpaste behaves in Vim's command-line
  if !exists("g:screen_clmode")
    let g:screen_clmode = "search"
  elseif g:screen_clmode !~# '^\%(s\%(earch\|ub\)\|noesc\)$'
    echomsg s:plug_name.": `".g:screen_clmode."':"
          \ "invalid value for screen_clmode."
          \ "Reset to 'search' (default)"
    let g:screen_clmode = "search"
  endif

  " g:screen_register: instead of register "0 use this one
  if !exists("g:screen_register")
    let g:screen_register = '"'
  elseif g:screen_register !~ '^["0-9a-zA-Z]$'
    echomsg s:plug_name.": `".g:screen_register."':"
          \ "invalid value for screen_register."
          \ "Reset to '\"' (default)"
    let g:screen_register = '"'
  endif

  if !exists("g:screen_visualselect")
    let g:screen_visualselect = 0
  endif

  " Checks: for system() and Screen executable {{{1
  function! s:Screen_CleanUp(msg)
    echohl WarningMsg
    echomsg s:plug_name.":" a:msg "Plugin not loaded"
    echohl None
    let g:loaded_screenpaste = "no"
    let &cpo = s:save_cpo
    unlet s:save_cpo s:plug_name g:screen_executable g:screen_clmode
  endfunction

  " bail out if system() is not available
  if !exists("*system")
    call <SID>Screen_CleanUp("builtin system() function not available.")
    finish
  endif

  " bail out if GNUscreen is not present
  if !executable(g:screen_executable)
    call <SID>Screen_CleanUp("`".g:screen_executable."' not executable.")
    finish
  endif

  let s:curr_version = "v5.92"

  " Mappings: propose defaults {{{1
  if !hasmapto("<Plug>ScreenpastePut") " nvo
    map  <unique> <Leader>p <Plug>ScreenpastePut
  endif
  if !hasmapto("<Plug>ScreenpasteGPut") " nvo
    map  <unique> <Leader>gp <Plug>ScreenpasteGPut
  endif
  if !hasmapto("<Plug>ScreenpastePutBefore", "n")
    nmap <unique> <Leader>P <Plug>ScreenpastePutBefore
  endif
  if !hasmapto("<Plug>ScreenpasteGPutBefore", "n")
    nmap <unique> <Leader>gP <Plug>ScreenpasteGPutBefore
  endif
  if !hasmapto("<Plug>ScreenpastePut", "ic")
    map! <unique> <Leader>p <Plug>ScreenpastePut
  endif

  " Internal Mappings: {{{1
  nnoremap <script> <silent> <Plug>ScreenpastePut
        \ :call <SID>Screen_NPut("p")<CR>
  nnoremap <script> <silent> <Plug>ScreenpasteGPut
        \ :call <SID>Screen_NPut("gp")<CR>
  nnoremap <script> <silent> <Plug>ScreenpastePutBefore
        \ :call <SID>Screen_NPut("P")<CR>
  nnoremap <script> <silent> <Plug>ScreenpasteGPutBefore
        \ :call <SID>Screen_NPut("gP")<CR>
  vnoremap <script> <silent> <Plug>ScreenpastePut
        \ :<C-U> call <SID>Screen_VPut("")<CR>
  vnoremap <script> <silent> <Plug>ScreenpasteGPut
        \ :<C-U> call <SID>Screen_VPut("g")<CR>
  inoremap <script> <silent> <Plug>ScreenpastePut
        \ <C-R>=<SID>Screen_IPut()<CR><C-R>=<SID>Screen_TwRestore()<CR>
  cnoremap <script>          <Plug>ScreenpastePut
        \ <C-R>=<SID>Screen_CPut()<CR>

  " Commands: {{{1
  " configuration for command-line-mode
  " in v:version >= 700 this works with <SID>
  function! Screen_ClCfgComplete(A, L, P)
    return "search\nsub\nnoesc"
  endfunction
  command -nargs=1 -complete=custom,Screen_ClCfgComplete
        \ ScreenCmdlineConf call <SID>Screen_ClConfig(<f-args>, 1)
  command ScreenCmdlineInfo call <SID>Screen_ClConfig(g:screen_clmode, 1)
  command ScreenSearch      call <SID>Screen_ClConfig("search", 1)
  command ScreenSub         call <SID>Screen_ClConfig("sub", 1)
  command ScreenNoEsc       call <SID>Screen_ClConfig("noesc", 1)
  " yank Screen buffer into register (default: screen_register)
  command -register ScreenYank call <SID>Screen_Yank("<register>")
  " buffer operation
  command -count=0 -bang -register ScreenPut
        \ call <SID>Screen_PutCommand("<count>", "<bang>", "<register>")

  " }}}1
" ===== end of public configuration ==========================================
  " Help Install: automatically when needed {{{1
  " Function: Screen_FlexiMkdir tries to adapt to system {{{2
  function! s:Screen_FlexiMkdir(dir)
    if exists("*mkdir")
      call mkdir(a:dir)
    elseif !exists("+shellslash")
      call system("mkdir -p '".a:dir."'")
    else
      let l:ssl = &shellslash
      try
        set shellslash
        " no single spaces for M$? (untested)
        call system('mkdir "'.a:dir.'"')
      finally
        let &shellslash = l:ssl
      endtry
    endif
  endfunction
  " }}}2

  " and now the doc install itself
  function! s:Screen_UpdateDocs()
    " figure out document path
    let l:vim_doc_dir = fnamemodify(s:plug_path, ":h:h")."/doc"
    if filewritable(l:vim_doc_dir) != 2
      let l:doc_install_intro = s:plug_name." doc install:"
      echomsg l:doc_install_intro "Trying doc path" l:vim_doc_dir
      echomsg "  relative to" s:plug_path
      silent! call <SID>Screen_FlexiMkdir(l:vim_doc_dir)
      if filewritable(l:vim_doc_dir) != 2
        " try first item in 'runtimepath' which is comma-separated list
        let l:vim_doc_dir =
              \ substitute(&runtimepath, '^\([^,]*\).*', '\1/doc', 'e')
        echomsg l:doc_install_intro "Trying doc path" l:vim_doc_dir
        echomsg "  using first item of 'runtimepath'"
        if filewritable(l:vim_doc_dir) != 2
          silent! call <SID>Screen_FlexiMkdir(l:vim_doc_dir)
          if filewritable(l:vim_doc_dir) != 2
            " give a warning
            echomsg l:doc_install_intro "Unable to detect writeable doc directory"
            echomsg "  type `:help add-local-help' for more information"
            return 0
          endif
        endif
      endif
    endif
    " full name of help file
    let l:doc_file = l:vim_doc_dir."/".s:plug_name.".txt"
    " bail out if document file is still up to date
    if filereadable(l:doc_file) &&
          \ getftime(s:plug_path) < getftime(l:doc_file)
      return 0
    endif
    let l:lz = &lazyredraw
    let l:hls = &hlsearch
    set lazyredraw nohlsearch
    " create a new buffer & read in the plugin file
    1 new
    setlocal noswapfile modifiable nomodeline
    if has("folding")
      setlocal nofoldenable
    endif
    silent execute "read" escape(s:plug_path, " ")
    let l:doc_buf = bufnr("%")
    1
    " delete from first line line starting with
    " === START_DOC
    silent 1,/^=\{3,}\s\+START_DOC\C/ delete _
    " delete from line starting with
    " === END_DOC
    " to end of buffer
    silent /^=\{3,}\s\+END_DOC\C/,$ delete _
    " add modeline for help, modeline string mangled intentionally
    " to avoid its being recognized when it is parsed
    call append(line("$"), "")
    call append(line("$"), " v"."im:tw=78:ts=8:ft=help:norl:")
    " replace revision
    silent execute "normal :1s/#version#/ ".s:curr_version."/\<CR>"
    " write file `screenpaste.txt'
    silent execute "wq!" escape(l:doc_file, " ") "| bwipeout" l:doc_buf
    " create help tags
    silent execute "helptags" l:vim_doc_dir
    let &hlsearch = l:hls
    let &lazyredraw = l:lz
    return 1
  endfunction

  if <SID>Screen_UpdateDocs()
    echomsg s:plug_name s:curr_version.": updated documentation"
  endif

  " Demand Load: via autcmd FuncUndefined : {{{1
  " get the current script ID
  function! s:Screen_SID()
    " <sfile> inside a function yields {function-name}
    return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
  endfunction
  " load functions on demand
  execute "autocmd FuncUndefined"
        \ "*".<SID>Screen_SID()."Screen_* source" escape(s:plug_path, " ")

  " Purge Functions: that have done their one-time duty {{{1
  delfunction <SID>Screen_CleanUp
  delfunction <SID>Screen_FlexiMkdir
  delfunction <SID>Screen_UpdateDocs
  delfunction <SID>Screen_SID

  let g:loaded_screenpaste = s:curr_version."_fast_load_done"

  let &cpo = s:save_cpo
  unlet s:save_cpo s:plug_path
  finish
endif

if g:loaded_screenpaste != s:curr_version."_fast_load_done"
  let &cpo = s:save_cpo
  unlet s:save_cpo
  finish
endif

let g:loaded_screenpaste = s:curr_version

" }}}1
" ===== end of fast load =====================================================
" Script Vars: characters to be escaped on cmdline {{{1
" static:
" patterns and strings (for user info)
let s:esc_search_ma    = '][/\^$*.~'
let s:esc_search_noma  = ']/\^$'
let s:esc_sub_ma       = '/\~&'
let s:esc_sub_noma     = '/\'
let s:info_search_ma   = "] [ / \\ ^ $ ~ * . (magic)"
let s:info_search_noma = "] / \\ ^ $ (nomagic)"
let s:info_sub_ma      = "/ \\ ~ & (magic)"
let s:info_sub_noma    = "/ \\ (nomagic)"

" dynamic:
" these contain the current values for cmdline conversion, and,
" at startup, are set to the values corresponding to 'noesc'
" because for 'search' and 'sub' Screen_ClConfig is called with
" the current value of screen_clmode everytime Screen_CPut is called
" with the purpose to adapt to current setting of 'magic'
let s:cl_esc = ''
let s:cl_eol = '\\n'

" Function: Screen_BufEscape escapes chars in Screen buffer for cmdline {{{1
function! s:Screen_BufEscape()
  let l:screen_buf = <SID>Screen_Yank()
  if strlen(s:cl_esc)
    let l:screen_buf = escape(l:screen_buf, s:cl_esc)
  endif
  return substitute(l:screen_buf, "\<C-J>", s:cl_eol, 'g')
endfunction

" Function: Screen_ClConfig configures cmdline insertion {{{1
" variables configured here and used by Screen_CPut function:
" global:
" g:screen_clmode     cmdline behaviour
" internal:
" s:cl_eol            eol-conversion
" s:cl_esc            character group pattern to be escaped
" s:esc_info          displays escaped characters
" s:eol_info          displays eol-conversion
function! s:Screen_ClConfig(mod, msg)
  if a:mod !~# '^\%(s\%(earch\|ub\)\|noesc\)$'
    echohl WarningMsg
    echon "`" a:mod "': invalid value for screen_clmode\n"
          \ "use one of: search | sub | noesc"
    echohl None
    return ""
  endif
  let g:screen_clmode = a:mod
  " call version dependent function to assign escapes
  call <SID>Screen_ClEscape()
  if a:msg
    echon "set '" g:screen_clmode "' "
          \ "for Screen buffer insertion in cmdline:\n"
          \ "eol-conversion to literal " s:eol_info "\n"
          \ "escaped characters        " s:esc_info
  endif
endfunction
" }}}1
" ============================================================================
" Vim7 Functions: subroutines, Screen_CPut (command detection) {{{1
" ============================================================================
" functions and helpers making use of Vim7 features
if v:version >= 700

  " Function: Screen_ReadBuf returns Screen buffer as text {{{2
  function! s:Screen_ReadBuf(screen_tmpfile)
    try
      return join(readfile(a:screen_tmpfile, "b"), "\n")
    catch /^Vim\%((\a\+)\)\=:E484/
      " Screen buffer empty, no tmpfile created
      return ""
    endtry
  endfunction

  " Function: Screen_ClEscape chars to be escaped in cmdline {{{2
  " initialize dict vars
  let s:cl_esc_dict = {
        \ "search": {0: s:esc_search_noma, 1: s:esc_search_ma},
        \ "sub":    {0: s:esc_sub_noma,    1: s:esc_sub_ma   },
        \ "noesc":  {0: '',                1: ''             }
        \ }
  let s:cl_info_dict = {
        \ "search": {0: s:info_search_noma, 1: s:info_search_ma},
        \ "sub"   : {0: s:info_sub_noma,    1: s:info_sub_ma   },
        \ "noesc" : {0: 'none',             1: 'none'          }
        \ }
  let s:eol_conv_dict =
        \ {"search": '\\n', "sub": '\\r', "noesc": '\\n'}
  let s:eol_info_dict =
        \ {"search": '\n', "sub": '\r', "noesc": '\n'}

  function! s:Screen_ClEscape()
    let s:cl_esc   =   s:cl_esc_dict[g:screen_clmode][&magic]
    let s:esc_info =  s:cl_info_dict[g:screen_clmode][&magic]
    let s:cl_eol   = s:eol_conv_dict[g:screen_clmode]
    let s:eol_info = s:eol_info_dict[g:screen_clmode]
  endfunction

  " Function: Screen_CPut writes converted Screen buffer to cmdline {{{2
  " Screen call needed for :insert and :append commands in Screen_CPut
  " using slowpaste avoids need for manual redraw
  let s:screen_slowpaste =
        \ g:screen_executable." -X slowpaste 10;".
        \ g:screen_executable." -X paste .;".
        \ g:screen_executable." -X slowpaste 0"

  function! s:Screen_CPut()
    " automatically adapt 'screen_clmode' to cmdtype if possible
    " or instant paste in case of :insert or :append
    let l:cmdtype = getcmdtype()
    if l:cmdtype == '-' && exists("$STY")
      " :insert, :append inside Screen session
      call system(s:screen_slowpaste)
      return ""
    endif
    " store current cmdline behaviour
    let l:save_clmode = g:screen_clmode
    " detect cmdtype if not 'noesc'
    if g:screen_clmode != "noesc"
      if l:cmdtype =~ '[/?]'
        " search: always call config to adapt to 'magic'
        call <SID>Screen_ClConfig("search", 0)
      elseif l:cmdtype =~ '[@-]'
        " input() or :insert, :append outside Screen session
        call <SID>Screen_ClConfig("noesc", 0)
      else
        " search, sub: always call config to adapt to 'magic'
        call <SID>Screen_ClConfig(g:screen_clmode, 0)
      endif
    endif
    let l:screen_buf = <SID>Screen_BufEscape()
    " restore global 'screen_clmode' if changed
    if l:save_clmode != g:screen_clmode
      call <SID>Screen_ClConfig(l:save_clmode, 0)
    endif
    return l:screen_buf
  endfunction

" }}}1
" ============================================================================
" Vim6 Functions: subroutines, Screen_CPut (w/o command detection) {{{1
" (see Vim7 for more comments)
else

  " Function: Screen_ReadBuf returns Screen buffer as text {{{2
  function! s:Screen_ReadBuf(screen_tmpfile)
    let l:store_quote = @"
    let l:store_null  = @0
    let l:lz = &lazyredraw
    silent execute "1 sview" a:screen_tmpfile
    silent % yank
    quit!
    let &lazyredraw = l:lz
    " remove closing newline to mimic reading in binary mode
    " otherwise always a linewise register
    let l:screen_buf = substitute(@0, '\n\%$', '', 'e')
    let @" = l:store_quote
    let @0 = l:store_null
    return l:screen_buf
  endfunction

  " Function: Screen_ClEscape assigns chars to be escaped in cmdline {{{2
  function! s:Screen_ClEscape()
    if &magic && g:screen_clmode == "search"
      let s:cl_esc   = s:esc_search_ma
      let s:esc_info = s:info_search_ma
    elseif &magic && g:screen_clmode == "sub"
      let s:cl_esc   = s:esc_sub_ma
      let s:esc_info = s:info_sub_ma
    elseif g:screen_clmode == "search"
      let s:cl_esc   = s:esc_search_noma
      let s:esc_info = s:info_search_noma
    elseif g:screen_clmode == "sub"
      let s:cl_esc   = s:esc_sub_noma
      let s:esc_info = s:info_sub_noma
    else " "noesc"
      let s:cl_esc   = ''
      let s:esc_info = "none"
    endif
    if g:screen_clmode != "sub"
      let s:cl_eol   = '\\n'
      let s:eol_info = '\n'
    else
      let s:cl_eol   = '\\r'
      let s:eol_info = '\r'
    endif
  endfunction

  " Function: Screen_CPut writes converted Screen buffer to cmdline {{{2
  " no detection of cmdtype
  function! s:Screen_CPut()
    if g:screen_clmode != "noesc"
      " catch eventual change of &magic
      call <SID>Screen_ClConfig(g:screen_clmode, 0)
    endif
    return <SID>Screen_BufEscape()
  endfunction

endif

" }}}1
" ============================================================================
" Function: Screen_Yank snatches current Screen buffer {{{1
function! s:Screen_Yank(...)
  let l:screen_tmpfile = tempname()
  call system(g:screen_executable." -X writebuf ".l:screen_tmpfile)
  if !a:0
    return <SID>Screen_ReadBuf(l:screen_tmpfile)
  else
    let l:screen_buf = <SID>Screen_ReadBuf(l:screen_tmpfile)
    if strlen(l:screen_buf)
      if strlen(a:1)
        call setreg(a:1, l:screen_buf)
      else
        call setreg(g:screen_register, l:screen_buf)
      endif
      return 1
    elseif g:screen_register =~ '\u'
      " do nothing
      return 1
    else
      echohl WarningMsg
      echo "Screen buffer is empty"
      echohl None
      return 0
    endif
  endif
endfunction

" Function: Screen_NPut pastes in normal mode {{{1
function! s:Screen_NPut(p)
  if <SID>Screen_Yank(g:screen_register)
    execute 'normal! "'.g:screen_register.a:p
  endif
endfunction

" Function: Screen_IPut pastes in insert mode {{{1
" Function: Screen_TwRestore restores 'paste' {{{2
" helper function, only called right after Screen_IPut
" because Screen_IPut must return result before
" being able to restore paste its previous value
function! s:Screen_TwRestore()
  let &paste = s:curr_paste
  return ""
endfunction
" }}}2
function! s:Screen_IPut()
  let s:curr_paste = &paste
  let &paste = 1
  let l:screen_buf = <SID>Screen_Yank()
  return l:screen_buf
endfunction

" Function: Screen_VPut pastes in visual mode {{{1
function! s:Screen_VPut(go)
  if <SID>Screen_Yank(g:screen_register)
    if g:screen_register =~ '["@]'
      " we have to use another register because
      " visual selection is deleted into unnamed register
      let l:store_reg = @z
      let @z = @"
      let g:screen_register = "z"
    endif
    execute 'normal! gv"'.g:screen_register.a:go.'p'
    if g:screen_visualselect
      execute "normal! `[".visualmode()."`]"
    endif
    if exists("l:store_reg")
      let g:screen_register = '"'
      let @0 = @z
      let @z = l:store_reg
    endif
  else
    " reset visual after showing message for 3 secs
    sleep 3
    execute "normal! gv"
  endif
endfunction

" Function: Screen_PutCommand is called from :ScreenPut {{{1
function! s:Screen_PutCommand(line, bang, reg)
  if !strlen(a:reg)
    let l:reg = g:screen_register
  else
    let l:reg = a:reg
  endif
  if <SID>Screen_Yank(l:reg)
    if a:line
      execute a:line "put".a:bang l:reg
    else
      execute "put".a:bang l:reg
    endif
  endif
endfunction

" Finale: restore 'compatible' settings {{{1
let &cpo = s:save_cpo
unlet s:save_cpo

finish
" }}}1
" ============================================================================
" Section: inline documentation (self-installing) {{{1
" to read the docs from this file with proper syntax coloring, type
" :set ft=help

=== START_DOC
*screenpaste.txt* Paste/insert GNU Screen buffer in (almost) any mode #version#

Author:	Christian Ebert <blacktrash@gmx.net>


		SCREENPASTE REFERENCE MANUAL~

*screenpaste* *screenpaste.vim*

==============================================================================

1. Contents						*screenpaste-toc*

	Screen Paste Plugin				|screenpaste-intro|
	Activation					|screenpaste-activate|
	Usage						|screenpaste-usage|
	Options						|screenpaste-options|
	Changing Mappings				|screenpaste-mappings|
	Commands					|screenpaste-commands|
	Bugs and Limitations				|screenpaste-bugs|
	Credits						|screenpaste-credits|

==============================================================================

2. Screen Paste Plugin					*screenpaste-intro*

The terminal window manager Screen http://www.gnu.org/software/screen
offers the capability to copy and paste between windows.

In principle you can just do "C-a ]" (default) to paste the current Screen
buffer into a vim buffer. However this gives unexpected results when 'paste'
is not set or in Vim's command-line.

This script provides mappings and commands to get correct results.

As an additional feature the current Screen buffer is available in any Vim
instance, even those /outside/ the current Screen session.

When pasting into command-line in Vim7 many commands are autodetected and the
behaviour adapts automatically (|getcmdtype()|).

The underlying mechanism of screenpaste consists in getting hold of the
current Screen buffer via calling to Screen to write it to a temporary file.
At this point Vim takes over, reads the contents of the file, and puts them to
use either directly (in Insert, Replace or Command-line mode) or, in Normal
and Visual mode, by writing to a register and, most often, putting the
contents of the register into the Vim buffer.  Which is why the default
keybindings mimic |p|, |P|, |gp|, |gP|, with the |mapleader| prepended, as
well as |:ScreenPut| and |:ScreenYank| behave almost like |:put| and |:yank|
respectively.

==============================================================================

3. Activation						*screenpaste-activate*

Either copy screenpaste.vim to your plugin directory (|add-global-plugin|),
or to your macros directory and source it (manually or from |vimrc|): >
	:runtime macros/screenpaste.vim
or >
	:source $HOME/.vim/macros/screenpaste.vim

The Vim Help documentation installs itself when you restart Vim.

The GNU Screen executable has to be in $PATH. Otherwise screenpaste bails out
giving an error message.

==============================================================================

4. Usage						*screenpaste-usage*

Think of the current Screen buffer as of a register at your disposal via the
|screenpaste| mappings and commands.

							*screenpaste-put*
When you type the plugin's Ex command
>
	:ScreenPut

this works like executing |:put| with the current Screen buffer as register.
It puts the text after the current line.  Like |:put| it accepts a prepended
number as parameter designating the target line as well as an appended bang
to put the text before the indicated line and an optional register argument
which defaults to |screen_register| when omitted.

|:ScreenPut| differs from |:put| as the register is not only written into the
buffer but filled with the current Screen buffer beforehand.

							*screenpaste-yank*
If you want to just get hold of the current Screen buffer for further
processing, type
>
	:ScreenYank
>
and the Screen buffer is at your disposal in the |screen_register|.  Similar
to |:yank| you can also execute the command with an explicit register
argument.

Note: Screen's copy mechanism discards spaces at the end and the beginning of
a selection in case there are printable characters in the same line.  In Vim
terms one could consider this like selecting 'exclusive', and to get a
|linewise| "yank" the selection has to span visually more than one line, the
newline at the end of a visually selected single line is not included.


All other commands configure the treatment of the current Screen buffer when
it is pasted into the command-line.  Please refer to |screen_clmode| and
|screenpaste-commands| for further information.


Mappings:~

In |Insert|, |Replace|, and |Command-line| modes (by default) simply type: >
	\p
to paste the current Screen buffer.  In these modes the |screen_register| is
not changed.

Note: mappings are ignored in Insert mode while |'paste'| is set. But in that
case Screen's "paste" command (bound to "C-a]" by default) works just fine and
there's no need to work around this via |'pastetoggle'|.


The plugin's mappings for |Normal| and |Visual| mode emulate the non-Ex
commands |p|, |P|, |gp|, and |gP|:  They put the text of the current Screen
buffer after or before the cursor, or replace the visual selection with it,
just as if the unnamed register would contain the current Screen buffer (see
|screen_register|).

If the Screen buffer is empty they do nothing, the registers stay untouched,
and only a corresponding message is displayed in the menu.

Note however that the optional initial [count] argument to the original non-Ex
commands will not work with these mappings (|screenpaste-bugs|).

In their default state the |Normal| and |Visual| mode mappings consist of the
same letters as the corresponding non-Ex commands with the |mapleader|
prepended: >

	<Leader>p
	<Leader>P	(not in Visual)
	<Leader>gp
	<Leader>gP	(not in Visual)

For simplicity we use the default |screenpaste-mappings| and the default
|<Leader>| "\" in the following description.

							*screenpaste-p*
\p			Put current Screen buffer after the cursor.

							*screenpaste-P*
\P			Put current Screen buffer before the cursor.
			Not available in Visual mode.

							*screenpaste-gp*
\gp			Like "\p" but leave the cursor after the pasted text.

							*screenpaste-gP*
\gP			Like "\P" but leave the cursor after the pasted text.
			Not available in Visual mode.

In |Visual| mode we do not need "\P" and "\gP" as "\p" and "\P" have the same
effect of replacing the Visual selected text with the current Screen buffer.


To summarize, supposing the default |<Leader>| "\" and the default
|screenpaste-mappings| you can type:
>
	\p  in Normal mode to put Screen buffer after cursor
	\gp in Normal mode to put Screen buffer after cursor and leave cursor
		after the end of new text
	\P  in Normal mode to put Screen buffer before cursor
	\gP in Normal mode to put Screen buffer before cursor and leave cursor
		after the end of new text
	\p  in Visual mode to replace visual selection with Screen buffer
	\gp in Visual mode to put Screen buffer after cursor and leave cursor
		after the end of new text
	\p  in Insert and Replace mode to paste Screen buffer
	\p  in Command-line-mode to put Screen buffer in command line

==============================================================================

5. Options						*screenpaste-options*

g:loaded_screenpaste					*loaded_screenpaste*

	This option normally is set by screenpaste to avoid loading the script
	more than once. But you can use it to get the current script version: >
		:echo loaded_screenpaste
<
	If you want to disable screenpaste, put the following line in your
	|vimrc|: >
		let g:loaded_screenpaste = 1

g:screen_executable					*screen_executable*

Type		String
Default Value	'screen'

	Set this option if the name of your GNU Screen executable differs from
	"screen", or if you like to specify it's full path: >
		let g:screen_executable = "/usr/local/bin/screen"

g:screen_visualselect					*screen_visualselect*
Type		Boolean
Default Value	0

        If set to 1 and in Visual mode the text from the Screen buffer is
        visually selected after the put operation.

g:screen_register					*screen_register*

Type		String
Valid Values	"a-z0-9A-Z
Default Value	'"'

	The non-Ex put "commands" (mappings) act in a twofold operation when
	executed in Normal or Visual mode: they yank the Screen buffer into a
	register in the background, and then put the register into the buffer
	or command-line.  This variable controls the register that is used for
	the first part of the operation.  It defaults to the unnamed register
	"" (|quotequote|).

	Normally you should be fine with the default setting.  But if you
	prefer to reserve a register of your choice for the Screen buffer you
	can do so with this option.  Besides the default "", you may choose
	any named (|quote_alpha|) or numbered (|quote_number|) register.
	Consult |registers| about their behaviour.

	For a one time operation with a special register the use of
	|ScreenPut| ex-command and its register argument is recommended.

	Note: Due to the mechanics of the script even a numbered register has
	to be passed as string, ie. it has to quoted when you set it; eg. >
		:let g:screen_register = "8"
<	Note as well that specifying an uppercase letter means that the
	contents of the Screen buffer will be appended to the register named
	with the corresponding lowercase character (|quote_alpha|).

g:screen_clmode						*screen_clmode*

Type		String
Valid Values	'search', 'sub', 'noesc'
Default Value   'search'

	This setting controls how the Screen buffer is treated when pasted in
	the command line.

	You can change the setting at startup in your |vimrc|: >
		let g:screen_clmode = "sub"
<
	To change its value in a vim session you might want to use one of the
	|:ScreenCmdlineConf|, |:ScreenSearch|, |:ScreenSub|, |:ScreenNoEsc|
	commands as they also give a short informative message on how the mode
	of your choice will act, and prevent you from setting an invalid value.

	Information on the current value and the resulting behaviour is also
	available via the |:ScreenCmdlineInfo| command.

Modes and their behaviour:
							*screenpaste-search*
'search' ~
	Converts end-of-line to literal '\n'.
	Escapes characters according to the current setting of 'magic':
	magic:    [ ] / \ ^ * . ~ $
	nomagic:    ] / \ ^       $

	Use this mode to search for occurrences of current Screen buffer.
	Example as typed using default mapleader: >
		:ScreenSearch
		:%s/\p/repl/g
<	If the current Screen buffer is `[hello world.]' and 'magic' is set,
	the above becomes: >
		:%s/\[hello world\.\]/repl/g
<							*screenpaste-sub*
'sub' ~
	Converts end-of-line to literal '\r'.
	Escapes characters according to the current setting of 'magic':
	magic:    /  \  ~  &
	nomagic:  /  \

	Use this mode to substitute a pattern with current Screen buffer.
	Example as typed using default mapleader: >
		:ScreenSub
		:%s/pattern/\p/g
<	If the current Screen buffer is `http://www.vim.org', the above
	becomes: >
		:%s/pattern/http:\/\/www.vim.org/g
<							*screenpaste-noesc*
'noesc' ~
	Converts end-of-line to literal '\n'.

	Use this mode to paste current Screen buffer literally into command
	line.

Vim7:
	|/|, |?|, |input()|, |:insert|, and |:append| commands are
	autodetected when not in 'noesc' |screen_clmode|. This means that even
	when you are in 'sub' mode you can type: >
		/\p
<	and this becomes (using above example for 'search'): >
		/\[hello world\.\]
<
	Note: If you paste a Screen buffer containing newlines while in an
	|:insert| or |:append| but outside a running Screen session the
	newlines are escaped because we cannot call Screen's paste mechanism
	without clobbering a parallel Screen session, and Vim would insert
	<Nul> characters instead (see |NL-used-for-Nul|).

Vim6:
	For |:insert| and |:append| commands use Screen's "C-a ]"

==============================================================================

6. Changing Mappings					*screenpaste-mappings*
							*ScreenpastePut*
							*ScreenpasteGPut*
							*ScreenpastePutBefore*
							*ScreenpasteGPutBefore*

The right-hand-side |{rhs}| mappings provided by this plugin and the modes in
which to apply them are: >

	<Plug>ScreenpastePut		Normal, Visual, Insert, Command-line
	<Plug>ScreenpasteGPut		Normal, Visual
	<Plug>ScreenpastePutBefore	Normal
	<Plug>ScreenpasteGPutBefore	Normal
<
Use these to customize the default mappings <Leader>p, <Leader>gp, <Leader>P,
and <Leader>gP to your taste (see |using-<Plug>| and |:map-modes|).

The default mappings would look like this in a |vimrc|:

map  <Leader>p  <Plug>ScreenpastePut		" Normal, Visual mode
map! <Leader>p  <Plug>ScreenpastePut		" Insert, Command-line mode
map  <Leader>gp <Plug>ScreenpasteGPut		" Normal, Visual mode
nmap <Leader>P  <Plug>ScreenpastePutBefore	" Normal mode
nmap <Leader>gP <Plug>ScreenpasteGPutBefore	" Normal mode

You can tweak them by changing their left-hand-side |{lhs}|.

Normal (put after cursor) and Visual mode:
							default
:map	{lhs}	<Plug>ScreenpastePut			  \p
:map	{lhs}	<Plug>ScreenpasteGPut			  \gp

	Vimrc example: >
		map  <Leader>P <Plug>ScreenpastePut

Normal mode (put before cursor):

:nmap	{lhs}	<Plug>ScreenpastePutBefore		  \P
:nmap	{lhs}	<Plug>ScreenpasteGPutBefore		  \gP

	Vimrc example: >
		nmap <Leader>I <Plug>ScreenpastePutBefore

Insert and Command-line mode:

:map!	{lhs}	<Plug>ScreenpastePut			  \p

	Vimrc example, to avoid character mappings when inserting: >
		map! <F7> <Plug>ScreenpastePut

==============================================================================

7. Commands						*screenpaste-commands*

							*:ScreenYank*
:ScreenYank [x]		Yank current Screen buffer into register [x] (default
			|screen_register|).

							*:ScreenPut*
:[line]ScreenPut [x]	Put the text from current Screen buffer after [line]
			(default current line) using register [x] (default
			|screen_register|).

	You can use this command for instance to append the contents of the
	Screen buffer to a named register and then paste in one go: >
		:3 ScreenPut A
<	puts the contents of register "a and the Screen buffer after line 3.

:[line]ScreenPut! [x]	Put the text from current Screen buffer before [line]
			(default current line) using register [x] (default
			|screen_register|).

							*:ScreenCmdlineConf*
:ScreenCmdlineConf {mode}
			Tell screenpaste to convert the current Screen
			buffer in command-line-mode according to {mode}.
			Takes one argument of: "search", "sub", "noesc" (w/o
			quotes).
			Changes |screen_clmode| accordingly.
	Example: >
		:ScreenCmdlineConf noesc
<
							*:ScreenCmdlineInfo*
:ScreenComdlineInfo	Display information on current command-line-mode
			behaviour, ie. current |screen_clmode| and what it
			does.

							*:ScreenSearch*
:ScreenSearch		Set |screen_clmode| to 'search'.
	Equivalent to: >
		:ScreenCmdlineConf search
<
							*:ScreenSub*
:ScreenSub		Set |screen_clmode| to 'sub'.
	Equivalent to: >
		:ScreenCmdlineConf sub
<
							*:ScreenNoEsc*
:ScreenNoEsc		Set |screen_clmode| to 'noesc'.
	Equivalent to: >
		:ScreenCmdlineConf noesc

==============================================================================

8. Bugs and Limitations					*screenpaste-bugs*

Found no way (yet?) to make optional initial [count] argument work with
(Normal mode) mappings.

Screen's copy mechanism treats spaces (including newlines) at the beginning or
the end of a selection in a different manner than Vim's visual yank does.

Screen expands tabs, expect incorrect results if the Screen buffer contains
tabs.

==============================================================================

Credits							*screenpaste-credits*

Mathieu Clabaut, Guo-Peng Wen	let me steal and tweak the inline
				self-install code for this Help document.

==============================================================================
=== END_DOC

" EOF vim600: set foldmethod=marker:
