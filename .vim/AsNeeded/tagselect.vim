" tagselect.vim: Provides a better :tselect command.
" Author: Hari Krishna (hari_vim at yahoo dot com)
" Last Change: 09-Jun-2005 @ 15:08
" Created:     18-May-2004
" Requires:    Vim-6.3, genutils.vim(1.12)
" Version:     1.2.0
" Licence: This program is free software; you can redistribute it and/or
"          modify it under the terms of the GNU General Public License.
"          See http://www.gnu.org/copyleft/gpl.txt 
" Acknowledgements:
" Download From:
"     http://www.vim.org//script.php?script_id=1282
" Description:
"   If you don't like the more prompt that comes up when there are too many
"   hits to the :tselect and the related commands, then try this plugin.
"   Useful even with finding help topics in a help window (see :help {subject}
"   and see the tip on the usage below).
"
"     Use :Tselect command instead of :tselect to bring up the :tselect output
"     in a vim window. You can then search and press enter on the line(s) of
"     the tag which you would like to select. If you don't want to select any
"     tag you can quit by pressing "q". You can also start typing the number
"     of the tag instead of moving the cursor to the line and pressing enter.
"
"     To select another tag index for the same tag, you can use :Tselect
"     without arguments or just use :tselect itself.
"
"     You can also use :Stselect, :Tjump and :Stjump commands to execute
"     :stselect, :tjump and :stjump commands respectively.
"
"     The normal mode commands, "g]" and "g^]" (g] and g_CTRL-]) and their
"     corresponding visual mode commands (v_g] and v_g_CTRL-]) and window
"     split commands (CTRL-W_g] and CTRL-W_g-CTRL-]) will be remapped to use
"     the plugin. To disable these maps, set g:no_tagselect_maps in your
"     vimrc.
"
"     You can also use :Tags command to show the output of :tags command in
"     a vim window. You can then search and press enter on the line of the tag
"     which you would like to jump to. The plugin executes the appropriate
"     command (:tag or :pop) with the right index.
"
"     Use g:tagselectWinSize to set the preferred size of the window. The
"     default is -1, which is to take just as much as required (up to the
"     maximum), but you can set it to empty string to make the window as high
"     as possible, or any +ve number to limit its size.
"
"     Use g:tagselectExpandCurWord to configure if <cword> and <cWORD> tokens
"     will be expanded or not.
"   Tips:
"     - You can intermix the usage of the plugin commands with that of
"       built-in commands (ie., :tn, :tp followed by a :Tselect)
"     - You can use :Ts instead of the full :Tselect, as long as there are no
"       other commands which could confuse the usage. The same applies to
"       :Tjump (:Tj) and other commands.
"     - The [Tag Select] buffer is set to to "tagselect" filetype, so this
"       allows you to customize the look & feel (colors, maps etc.) by
"       creating syntax/tagselect.vim and ftplugin/tagselect.vim files in your
"       runtime.
"     - In a help window, you can use the :Tselect /<pattern> command to do
"       very powerful and handy lookup of the help topics. Using this
"       technique to find the help topic you want is fun and easy and you are
"       sure to bump into features that you are not aware of (both in Vim and
"       in plugins that you installed). E.g., to find all the topics that have
"       "shell" in its name,
"           :h
"           :Tselect /shell
"   Limitations:
"     - Executes tag commands (:tselect :stselect) twice, once to show the
"       list, and once to jump to the selected tag. This means, if the tag
"       search takes considerable time, then the time could potentially be
"       doubled (which is usually not a problem because Vim seems to cache the
"       last tag results). This could probably be fixed in Vim7 using the new
"       tag functions.
" TODO:
"   - A setting to dictate the positioning of the window.
"   - When quitting the window the cursor always goes to the below window,
"     there should be a way to go back to the originating window.
"   - Better way to select the tag. Use vim7 features if available.
"   - Sometimes I get terse output (is it constrained by the width?), how
"     do I avoid this?
"   - Why isn't noreadonly working, I still see the warning first time.

if exists('loaded_tagselect')
  finish
endif
if v:version < 603
  echomsg 'tagselect: You need Vim 6.3 or higher'
  finish
endif


if !exists('loaded_genutils')
  runtime plugin/genutils.vim
endif
if !exists('loaded_genutils') || loaded_genutils < 112
  echomsg 'tagselect: You need a newer version of genutils.vim plugin'
  finish
endif
let loaded_tagselect=100

" Make sure line-continuations won't cause any problem. This will be restored
"   at the end
let s:save_cpo = &cpo
set cpo&vim

if !exists('g:tagselectWinSize')
  let g:tagselectWinSize = -1
endif

if !exists('g:tagselectExpandCurWord')
  let g:tagselectExpandCurWord = 1
endif


if !exists('s:myBufNum')
let s:myBufNum = -1
let s:title = '[Tag Select]'
let s:curTagName = ''
endif
let s:nextTagPat = '^\s\{0,2}\d\+'

command! -nargs=? -complete=tag Tselect :call <SID>TagSelectMain('tselect',
      \ <f-args>)
command! -nargs=? -complete=tag Stselect :call <SID>TagSelectMain('stselect',
      \ <f-args>)
command! -nargs=? -complete=tag Tjump :call <SID>TagSelectMain('tjump',
      \ <f-args>)
command! -nargs=? -complete=tag Stjump :call <SID>TagSelectMain('stjump',
      \ <f-args>)
command! -nargs=0 Tags :call <SID>TagSelectMain('tags')

if (! exists("no_plugin_maps") || ! no_plugin_maps) &&
      \ (! exists("no_tagselect_maps") || ! no_tagselect_maps)
  nnoremap <silent> g] :Tselect <cword><CR>
  vnoremap <silent> g] :<C-U>call <SID>TagSelectVisual('tselect')<CR>
  nnoremap <silent> <C-W>g] :Stselect <cword><CR>
  vnoremap <silent> <C-W>g] :<C-U>call <SID>TagSelectVisual('stselect')<CR>
  nnoremap <silent> g<C-]> :Tjump <cword><CR>
  vnoremap <silent> g<C-]> :<C-U>call <SID>TagSelectVisual('tjump')<CR>
  nnoremap <silent> <C-W>g<C-]> :Stjump <cword><CR>
  vnoremap <silent> <C-W>g<C-]> :<C-U>call <SID>TagSelectVisual('stjump')<CR>
endif

function! s:TagSelectMain(cmd, ...) " {{{
  let tagName = a:0 ? a:1 : ''
  if g:tagselectExpandCurWord
    " Expand <cword> and <cWORD> in arguments.
    let tagName = substitute(tagName, '<cword>\|<cWORD>',
          \ '\=expand(submatch(0))', 'g')
  endif
  let results = GetVimCmdOutput(a:cmd.' '.tagName)
  if v:errmsg != '' && results =~ '^\_s*$'
    redraw | echohl ErrorMsg | echomsg v:errmsg | echohl NONE
    return 1
  endif
  " This means, there was only one hit, and Vim must have already jumped to
  " the jump. Don't do anything else.
  if a:cmd =~ 'jump' && results =~ '^\_s*$'
    return 0
  endif

  let _isf = &isfname
  let _splitbelow = &splitbelow
  set splitbelow
  try
    call SaveWindowSettings2('TagSelect', 1)
    if s:myBufNum == -1
      " Temporarily modify isfname to avoid treating the name as a pattern.
      set isfname-=\
      set isfname-=[
      if exists('+shellslash')
        call OpenWinNoEa("sp \\\\". escape(s:title, ' '))
      else
        call OpenWinNoEa("sp \\". escape(s:title, ' '))
      endif
      exec "normal i\<C-G>u\<Esc>"
      let s:myBufNum = bufnr('%')
    else
      let buffer_win = bufwinnr(s:myBufNum)
      if buffer_win == -1
        exec 'sb '. s:myBufNum
      else
        exec buffer_win . 'wincmd w'
      endif
    endif
  finally
    let &isfname = _isf
    let &splitbelow = _splitbelow
  endtry
  call s:SetupBuf()

  let s:curTagName = tagName
  let lastLine = line('$')
  silent! $put =results
  " Remove the prompt.
  if search('^Enter nr of choice', 'w')
    silent! delete _
  endif
  silent! exec '1,' . (lastLine + 1) . 'delete _'
  call append(0, a:cmd.':'.(s:curTagName == '' ? '' : (' ' . s:curTagName)))
  " Position the cursor at the next tag.
  if search('^> ', 'w') == 0
    0
  endif
  call search(s:nextTagPat, 'W')
  normal! zz

  " Resize only if this is not the only window vertically.
  if !IsOnlyVerticalWindow()
    let targetSize = g:tagselectWinSize
    if targetSize == -1
      let targetSize = line('$')
    endif
    exec 'resize ' targetSize
  endif

  return 0
endfunction " }}}

" Function to use the current visual selection as the tag. Should be called
" only from the visual mode.
function! s:TagSelectVisual(tagCmd) " {{{
  let invalid = 0
  if line("'<") != line("'>")
    let invalid = 1
  endif

  let selected = ''
  if !invalid
    if line('.') >= line("'<") && line('.') <= line("'>")
        let selected = strpart(getline('.'), col("'<") - 1,
              \ (col("'>") - col("'<") + 1))
    endif
    let invalid = s:TagSelectMain(a:tagCmd, selected)
  endif
  if invalid
    " Beep and reselect the selection, just like the built-in command.
    exec "normal \<Esc>gv"
  endif
endfunction " }}}

function! s:GetTagIndxUnderCursor() " {{{
  let tagIndex = 0
  if line('.') > 2
    if strpart(getline('.'), 0, 3) !~ s:nextTagPat && getline(1) !~ '^tags:'
      " We prefer to find the previous tag, but if there is none, then select
      " the current one again.
      if !search(s:nextTagPat, 'bW')
        call search('^>', 'bW')
      endif
    endif
    let tagIndex = substitute(getline('.'), '^>\?\s*\(\d\+\).*', '\1', '')
          \ + 0
  endif
  return tagIndex
endfunction

function! s:SelectTagUnderCursor(bang)
  call s:SelectTagCount(s:GetTagIndxUnderCursor(), a:bang)
endfunction

function! s:SelectTagCount(tagCount, bang)
  let tagCmd = ''
  let tagCount = a:tagCount
  if getline(1) =~ '^tselect:'
    let tagCmd = 'tselect'
  elseif getline(1) =~ '^stselect:'
    let tagCmd = 'stselect'
  elseif getline(1) =~ '^tjump:'
    let tagCmd = 'tselect'
  elseif getline(1) =~ '^stjump:'
    let tagCmd = 'stselect'
  elseif getline(1) =~ '^tags:'
    let selectedTag = tagCount
    if selectedTag != 0
      " Find the current tag index.
      if search('^>', 'w')
        -
        let currentTag = s:GetTagIndxUnderCursor()
        if currentTag > 0
          if selectedTag > currentTag " we need to push.
            let tagCount = selectedTag-currentTag
            let tagCmd = 'tag'
          elseif selectedTag < currentTag " we need to pop.
            let tagCount = currentTag-selectedTag
            let tagCmd = 'pop'
          else
            let tagCount = 0
          endif
        endif
      endif
    endif
  endif
  call s:SelectTag(tagCmd, tagCount, a:bang)
endfunction

function! s:SelectTag(cmd, tagCount, bang)
  let tagCount = a:tagCount
  if tagCount != 0
    let tagSelWin = winnr()
    wincmd p
    let _cscopetag = &cscopetag
    set nocscopetag
    let _more = &more
    set nomore
    " FIXME: Why is lazyredraw not having any effect?
    let _lazyredraw = &lazyredraw
    set lazyredraw
    let tagWindowOpen = 1
    try
      if a:cmd != 'tag' && a:cmd != 'pop'
        if a:cmd == 'stselect'
          call CloseWindow(tagSelWin, 1)
          call RestoreWindowSettings2('TagSelect')
          let tagWindowOpen = 0
        endif

        " FIXME: Need to find a more direct way of jumping to selected tag.
        exec 'nnoremap <Plug>TagSelectTS :'.a:cmd.a:bang.' '.s:curTagName.
              \ '<CR>'.tagCount.'<CR>'
        exec "normal \<Plug>TagSelectTS"
        " WORKAROUND: Avoid Hit ENTER prompt.
        redraw
        nunmap <Plug>TagSelectTS
      else
        exec tagCount.a:cmd
      endif
      "let v:errmsg = ''
      "silent exec 'tag ' . curTagPat
      "if v:errmsg == ''
      "  exec tagCount.'tnext'
      "endif
    catch
      "call confirm(v:exception, '&OK', 1, 'Error')
      redraw | echohl ErrorMsg |
            \ echomsg substitute(v:exception, '^[^:]\+:', '', '') | echohl NONE
    finally
      if tagWindowOpen
        call CloseWindow(tagSelWin, 1)
        call RestoreWindowSettings2('TagSelect')
      endif
      let &lazyredraw = _lazyredraw
      let &more = _more
      let &cscopetag = _cscopetag
    endtry
  endif
endfunction " }}}

function! s:SetupBuf() " {{{
  call SetupScratchBuffer()
  setlocal nowrap
  setlocal bufhidden=delete

  setlocal winfixheight

  nnoremap <silent> <buffer> q :TSQuit<CR>
  nnoremap <silent> <buffer> <CR> :TSSelect<CR>
  nnoremap <silent> <buffer> <2-LeftMouse> :TSSelect<CR>

  " When user types numbers in the browser window, input the tag index
  " directly.
  let chars = "123456789"
  let i = 0
  let max = strlen(chars)
  while i < max
    exec 'noremap <buffer>' chars[i] ':call <SID>InputTagIndex()<CR>'.
          \ chars[i]
    let i = i + 1
  endwhile

  command! -buffer TSQuit :call <SID>Quit()
  command! -buffer -bang TSSelect :call <SID>SelectTagUnderCursor('<bang>')

  syn clear
  set ft=tagselect
  syn match TagSelectTagHeader "^\s*# .*"
  syn match TagSelectCurTagLine "^>.*"
  syn match TagSelectTagLine "^\s*\d\+\s.*" contains=TagSelectTagName,TagSelectTagFile
  syn match TagSelectTagName "^\s*\d\+\s[a-zA-Z ]\{3} [a-zA-Z ]\s\+\zs\S\+\ze" contained
  syn match TagSelectTagFile "\S\+$" contained
  syn match TagSelectTagDetails "^\s\{9,}.*" contains=TagSelectTagType
  syn match TagSelectTagType "\w\+\ze:" contained

  hi! def link TagSelectTagHeader Title
  hi! def link TagSelectCurTagLine WildMenu
  hi! def link TagSelectTagFile Directory
  hi! def link TagSelectTagName Title
  hi! def link TagSelectTagType ModeMsg
endfunction " }}}

" From selectbuf.vim {{{
function! s:InputTagIndex()
  " Generate a line with spaces to clear the previous message.
  let i = 1
  let clearLine = "\r"
  while i < &columns
    let clearLine = clearLine . ' '
    let i = i + 1
  endwhile

  let tagIndex = ''
  let abort = 0
  call s:Prompt(tagIndex)
  let breakLoop = 0
  while !breakLoop
    try
      let char = getchar()
    catch /^Vim:Interrupt$/
      let char = "\<Esc>"
    endtry
    "exec BPBreakIf(cnt == 1, 2)
    if char == '^\d\+$' || type(char) == 0
      let char = nr2char(char)
    endif " It is the ascii code.
    if char == "\<BS>"
      let tagIndex = strpart(tagIndex, 0, strlen(tagIndex) - 1)
    elseif char == "\<Esc>"
      let breakLoop = 1
      let abort = 1
    elseif char == "\<CR>"
      let breakLoop = 1
    else
      let tagIndex = tagIndex . char
    endif
    echon clearLine
    call s:Prompt(tagIndex)
  endwhile
  if !abort && tagIndex != ''
    call s:SelectTagCount(tagIndex, '')
  endif
endfunction

function! s:Prompt(bufNr)
  echon "\rTag Index: " . a:bufNr
endfunction
" }}}

function! s:Quit()
  if NumberOfWindows() == 1
    redraw | echohl WarningMsg | echo "Can't quit the last window" |
          \ echohl NONE
  else
    quit
    call RestoreWindowSettings2('TagSelect')
  endif
endfunction

" Restore cpo.
let &cpo = s:save_cpo
unlet s:save_cpo

" vim6:fdm=marker et sw=2
