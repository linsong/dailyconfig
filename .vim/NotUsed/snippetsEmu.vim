"        File: snippetsEmu.vim
"      Author: Felix Ingram
"              ( f.ingram.lists@gmail.com )
" Description: An attempt to implement TextMate style Snippets. Features include
"              automatic cursor placement and command execution.
" Last Change: Monday 23rd October 2006
" Version:     0.6
"
" This file contains some simple functions that attempt to emulate some of the 
" behaviour of 'Snippets' from the OS X editor TextMate, in particular the
" variable bouncing and replacement behaviour.
"
" {{{ USAGE:
"
" Place the file in your plugin directory.
" Define snippets using the Iabbr command which takes similar arguments to the
" built in iabbr command.
" Snippets are best defined in the 'after' subdirectory of your Vim home
" directory ('~/.vim/after' on Unix). Filetype specific snippets can be defined
" in '~/.vim/after/ftplugin/<filetype>_snippets.vim. Using the <buffer> argument will
" restrict the abbreviations to the filetype only.
"
" Example One:
" Iabbr <buffer> fori for <datum> in <data>:<CR><datum>.<>
"
" The above will expand to the following (indenting may differ):
" 
" for <datum> in <data>:
"   <datum>.<>
" 
" The cursor will be placed after the first < in insert mode.
" Pressing <S-Del> will 'tab' to the next place marker (<data>) in
" insert mode.  Adding text between < and > and then hitting <S-Del> will
" remove the angle brackets and replace all markers with a similar identifier.
"
" Example Two:
" With the cursor at the pipe, hitting <S-Del> will replace:
" for <MyVariableName|datum> in <data>:
"   <datum>.<>
"
" with (the pipe shows the cursor placement):
"
" for MyVariableName in <data>:
"   MyVariableName.<>
" 
" Enjoy.
"
" Additional Features:
"
" Commands in tags. Anything after a ':' in a tag will be run with Vim's
" 'execute' command. The value entered by the user (or the tag name if no change
" has been made) is passed in the @z register (the original contents of the
" register are restored once the command has been run).
"
" Named Tags. Naming a tag (the <datum> tag in the example above) and changing
" the value will cause all other tags with the same name to be changed to the
" same value (as illustrated in the above example). Not changing the value and
" hitting <S-Del> will cause the tag's name to be used as the default value.
" 
" TextMate 'compatibility'. New since 0.5. Setting the variable
" 'g:snip_set_textmate_cp' to '1' will change how the plugin operates. Snippets
" will not be expanded automatically, instead the user must hit <Tab>. If the
" previous word was defined as a snippet then it's expanded. If there are still
" active tags then the cursor is moved with replacements and commands being
" performed as usual. If there is no snippet to expand and no active tags then a
" <Tab> is inserted.
" The variable can be set in vimrc with the following command:
" let g:snip_set_textmate_cp = 1
"
" Multi-character start and end tags. Start and end tags can now be more than
" one character in length. The main advantage of this is that a single set of
" tags can be defined which will work on the majority of filetype. For example,
" the default settings of '<' and '>' work for most languages except HTML
" (and Visual Basic: do you know why?). You can now define tags such as '<{' and
" '}>' (which probably break in some random web page template language but you
" get the idea).
"
" Known Bugs:
"
" FIXED If the abbreviation starts with a tag and is inserted at the start of the line
" then the cursor will not be placed in the correct tag.
"
" FIXED Empty tag replacement.  Changing an empty tag will change all remaining
" empty tags
"
" FIXED Short variable names.  Having a single character in the tags will mess up
" the insert point.
"
" FIXED Autoindentation breaks and too much whitespace can be swallowed.
" Caused by using 'i' instead of 'a' in the redefined command.
"
" FIXED Search_str not defined
" Sourcing the script but defining no snippets will generate an error
"
" FIXED Search_str not buffer specific.
" Using different tags in different buffers will break the searching in all but
" the most recently opened (assuming different tags for all buffers)
"
" FIXED Multiple commands on the same line
" Having two tags with commands defined on the same line presents unexpected
" behaviour
"
" FIXED Escape strings for matching in replacements
" Special characters in commands or tag names can cause problems when replacing.
" Infinite loops are very likely.
"
" FIXED Default value function doesn't work for named tags
" Having a named tag will fill @z which in turn will cause the default function
" to fail. One possible fix will be to remove the possibility for tag names to
" act as default values. This may annoy, whoever.
" Fix details: A script variable 's:CHANGED_VAL' is set when a user changes a
" tag's value. The D() function checks for this and returns the appropriate
" response.
"
" FIXED Snippets starting with 's' don't work due to bad regex.
" Many thanks to nfowar for spotting this one.
"
" Test tags for pattern matching:
" The following are examples of valid and invalid tags. Whitespace can only be
" used in a tag name if the name is enclosed in quotes.
"
" Valid tags
" <>
" <tagName>
" <tagName:command>
" <:command>
" <"Tag Name">
" <"Tag Name":command>
" @@
" @tagName@
" @tagName:command@
" @:command@
" @"Tag Name"@
" @"Tag Name":command@
"
" Invalid tags, random text
" <:>
" <Tag Name>
" <Tag Name:command>
" <"Tag Name":>
" <Tag >
" <OpenTag
" @:@
" @Tag Name@
" @Tag Name:command@
" @"Tag Name":@
" @Tag @
" @OpenTag
"
" Here's our magic search term (assumes '<',':' and '>' as our tag delimiters:
" <\([^[:punct:] \t]\{-}\|".\{-}"\)\(:[^>]\{-1,}\)\?>
" }}}

if v:version < 700
  echomsg "snippetsEmu plugin requires Vim version 7 or later"
  finish
endif

let s:debug = 0

function! <SID>Debug(text)
  if exists('s:debug') && s:debug == 1
    echom a:text
  endif
endfunction

if (exists('loaded_snippet') || &cp) && !s:debug
  finish
endif

call <SID>Debug("Started the plugin")

let loaded_snippet=1
" {{{ Set up variables
if !exists("g:snip_start_tag")
    let g:snip_start_tag = "<"
endif

if !exists("g:snip_end_tag")
    let g:snip_end_tag = ">"
endif

if !exists("g:snip_elem_delim")
    let g:snip_elem_delim = ":"
endif

let s:just_expanded = 0

" }}}
" {{{ Map Jumper to the default key if not set already
if ( !hasmapto( '<Plug>Jumper', 'i' ) )
  if exists("g:snip_set_textmate_cp") && g:snip_set_textmate_cp == 1
    imap <unique> <Tab> <Plug>Jumper
  else
    imap <unique> <S-Del> <Plug>Jumper
  endif
endif
if exists("g:snip_set_textmate_cp") && g:snip_set_textmate_cp == 1
  imap <silent> <script> <Plug>Jumper <C-R>=<SID>Jumper()<CR>
else
  imap <silent> <script> <Plug>Jumper <ESC>:call <SID>Jumper()<CR>
endif

call <SID>Debug("Mapped keys")

" }}}
" {{{ CheckForBufferTags() - Checks to see whether buffer specific tags have
" been defined
function! <SID>CheckForBufferTags()
  if exists("b:snip_end_tag") && exists("b:snip_start_tag") && exists("b:snip_elem_delim")
    return 1
  else
    return 0
  endif
endfunction
" }}}
" {{{ SetSearchStrings() - Set the search string. Checks for buffer dependence
function! <SID>SetSearchStrings()
  if <SID>CheckForBufferTags()
    let b:search_str = b:snip_start_tag.'\([^'.
          \b:snip_start_tag.b:snip_end_tag.
          \'[:punct:] \t]\{-}\|".\{-}"\)\('.
          \b:snip_elem_delim.
          \'[^'.b:snip_end_tag.b:snip_start_tag.']\{-1,}\)\?'.b:snip_end_tag
    let b:search_commandVal = "[^".b:snip_elem_delim."]*"
    let b:search_endVal = "[^".b:snip_end_tag."]*"
  else
    let b:search_str = g:snip_start_tag.'\([^'.
          \g:snip_start_tag.g:snip_end_tag.
          \'[:punct:] \t]\{-}\|".\{-}"\)\('.
          \g:snip_elem_delim.
          \'[^'.g:snip_end_tag.g:snip_start_tag.']\{-1,}\)\?'.g:snip_end_tag
    let b:search_commandVal = "[^".g:snip_elem_delim."]*"
    let b:search_endVal = "[^".g:snip_end_tag."]*"
  endif
endfunction
" }}}
" {{{ SetCom(text) - Set command function
function! <SID>SetCom(text)
  " First we'll set up the tag highlighting using syntax highlighting

  if !exists("g:snip_disable_highlight") || g:snip_disable_highlight == 0
    " We do these commands on each snippet definition to ensure that
    " they are set properly. Supposedly some plugins or options such as
    " spell can cause highlight groups to disappear.
    " Thanks to the multiselect plugin for showing how to do this 
    "hi default SnippetHighlight gui=reverse term=reverse cterm=reverse
    hi default SnippetHighlight term=reverse cterm=bold ctermfg=7 ctermbg=1 guifg=White guibg=Red
    if <SID>CheckForBufferTags()
      let matchPat = b:snip_start_tag.'\([^[:punct:] \t]\{-}\|".\{-}"\)\('.b:snip_elem_delim.'[^'.b:snip_end_tag.']\{-1,}\)\?'.b:snip_end_tag
    else
      let matchPat = g:snip_start_tag.'\([^[:punct:] \t]\{-}\|".\{-}"\)\('.g:snip_elem_delim.'[^'.g:snip_end_tag.']\{-1,}\)\?'.g:snip_end_tag
    endif

    execute "match SnippetHighlight '".matchPat."'"
  endif

  if exists("g:snip_set_textmate_cp") && g:snip_set_textmate_cp == 1
    " When using TextMate compatibility we don't need to worry about calling
    " SetPos() or NextHop() as this will be handled when tab is hit

    let text = substitute(a:text, '<CR>\|<Esc>\|<Tab>\|<BS>\|<Space>\|<C-r>\|<Pipe>\|\"\|\\','\\&',"g")

    let text = substitute(text, "$", "","")
    if match(text,"<buffer>") == 0
      let text = substitute(text, '\s*<buffer>\s*', "","")
      let tokens = split(text, ' ')
      let lhs = tokens[0]
      let rhs = join(tokens[1:])
      call <SID>SetSearchStrings()
      for char in split(lhs, '\zs')
        if char == '@'
          exec 'setlocal iskeyword+=@-@'
        elseif char != '^'
          try
            exec 'setlocal iskeyword+='.char
          catch /474/
          endtry
        endif
      endfor
      let lhs = <SID>Hash(lhs)
      return "let b:snip_".lhs.' = "'.rhs.'"'
    else
      let text = substitute(text, '^\s*', "", "")
      let tokens = split(text, ' ')
      let lhs = tokens[0]
      let rhs = join(tokens[1:])
      call <SID>SetSearchStrings()
      for char in split(lhs, '\zs')
        if char == '@'
          exec 'setlocal iskeyword+=@-@'
        elseif char != '^'
          try
            exec 'setlocal iskeyword+='.char
          catch /474/
          endtry
        endif
      endfor
      let lhs = <SID>Hash(lhs)
      return "let g:snip_".lhs.' = "'.rhs.'"'
    endif
  else
    call <SID>SetSearchStrings()
    if match(a:text,"<buffer>") == 0
      return "iabbr <buffer> ".substitute(strpart(a:text,stridx(a:text,">")+2)," "," <ESC>:call <SID>SetPos()<CR>a","")."<ESC>:call <SID>NextHop()<CR><C-R>=Eatchar('\\s')<CR>"
    else
      return "iabbr ".substitute(a:text," "," <ESC>:call <SID>SetPos()<CR>a","")."<ESC>:call <SID>NextHop()<CR><C-R>=Eatchar('\\s')<CR>"
    endif
  endif
endfunction
" }}}
" {{{ SetPos() - Store the current cursor position
" This function also now sets up the search strings so that autocommands can be
" used to define different tag delimiters for different filetypes
function! <SID>SetPos()
  let b:curCurs = col(".")
  let b:curLine = line(".")
  let s:curCurs = col(".")
  let s:curLine = line(".")
  call <SID>SetSearchStrings()
  let s:just_expanded = 1
endfunction
" }}}
" {{{ Check for end - Check whether the cursor is at the end of the current line
function! <SID>CheckForEnd()
  " Check to see whether we're at the end of a line so we can decide on
  " how to start inserting
  if <SID>CheckForBufferTags()
    let snip_elem_delim = b:snip_elem_delim
    let snip_start_tag = b:snip_start_tag
    let snip_end_tag = b:snip_end_tag
  else
    let snip_elem_delim = g:snip_elem_delim
    let snip_start_tag = g:snip_start_tag
    let snip_end_tag = g:snip_end_tag
  endif
  if col(".") == strlen(getline("."))
    return 1
  elseif getline(".") =~ '^$'
    return 1
  elseif (getline(".")[col(".")] == snip_elem_delim) &&
      \(getline(".")[col(".") + 1] == snip_end_tag) &&
      \(col(".") + 2 ==strlen(getline(".")))
      return 1
  else
    return 0 
  endif
endfunction
" }}}
" {{{ DeleteEmptyTag 
function! <SID>DeleteEmptyTag()
  if <SID>CheckForBufferTags()
    let snip_elem_delim = b:snip_elem_delim
    let snip_start_tag = b:snip_start_tag
    let snip_end_tag = b:snip_end_tag
  else
    let snip_elem_delim = g:snip_elem_delim
    let snip_start_tag = g:snip_start_tag
    let snip_end_tag = g:snip_end_tag
  endif
  for i in range(strlen(snip_start_tag) + strlen(snip_end_tag))
    normal x
  endfor
endfunction
" }}}
" {{{ NextHop() - Jump to the next tag if one is available
function! <SID>NextHop()
  if <SID>CheckForBufferTags()
    let snip_elem_delim = b:snip_elem_delim
    let snip_start_tag = b:snip_start_tag
    let snip_end_tag = b:snip_end_tag
  else
    let snip_elem_delim = g:snip_elem_delim
    let snip_start_tag = g:snip_start_tag
    let snip_end_tag = g:snip_end_tag
  endif
  if s:just_expanded == 1
    call cursor(s:curLine, 1)
    let s:just_expanded = 0
  else
    call cursor(s:curLine, s:curCurs)
  endif
  " Check to see whether we're sitting on a tag and if not then perform a
  " search
  if match(getline("."), b:search_str,s:curCurs) != 0
    if search(b:search_str) != 0
      " Delete the tag if appropriate
      " First check whether we're sitting on an empty tag
      if (strpart(getline("."), col(".")+strlen(snip_start_tag)-1, strlen(snip_end_tag)) == snip_end_tag)
        " We are so let's check whether the tag is the final text on the
        " line.
        if match(getline("."), snip_start_tag.snip_end_tag.'$') -
              \ (col(".")+strlen(snip_start_tag))+1+strlen(snip_end_tag) == 0
          call <SID>DeleteEmptyTag()
          startinsert!
        else
          " It isn't so we'll delete it and start normally
          call <SID>DeleteEmptyTag()
          startinsert
        endif
      else
        " Not on an empty tag so it must be a normal tag, so we'll just start
        " insert as usual
        for i in range(strlen(snip_start_tag))
          normal l
        endfor
        startinsert
      endif
    else
      " No more matches so we'll jump to the next bit of whitespace
      if <SID>CheckForEnd() == 1 || match(getline("."),'\W',s:curCurs) == -1
        startinsert!
      elseif match(getline("."),'\W',s:curCurs) < match(getline("."),'$',s:curCurs)
        call search('\W')
        startinsert
      else
        startinsert!
      endif
    endif
  else
    " We're sitting on a tag so we'll delete it and start insert
    " Delete the tag as appropriate
     if (strpart(getline("."), col(".")+strlen(snip_start_tag)-1, strlen(snip_end_tag)) == snip_end_tag )
      " We are so let's check whether the tag is the final text on the
      " line.
      if match(getline("."), snip_start_tag.snip_end_tag.'$') -
            \ (col(".")+strlen(snip_start_tag))+1+strlen(snip_end_tag) == 0
        call <SID>DeleteEmptyTag()
        startinsert!
      else
        " It isn't so we'll delete it and start normally
        call <SID>DeleteEmptyTag()
        startinsert
      endif
    else
      " Not on an empty tag so it must be a normal tag, so we'll just start
      " insert as usual
      for i in range(strlen(snip_start_tag))
        normal l
      endfor
      startinsert
    endif
  endif
endfunction
" }}}
" {{{ RunCommand() - Execute commands stored in tags
function! <SID>RunCommand(command, z)
  " Escape backslashes for the matching.  Not sure what other escaping is
  " needed here
  if <SID>CheckForBufferTags()
    let snip_elem_delim = b:snip_elem_delim
    let snip_start_tag = b:snip_start_tag
    let snip_end_tag = b:snip_end_tag
  else
    let snip_elem_delim = g:snip_elem_delim
    let snip_start_tag = g:snip_start_tag
    let snip_end_tag = g:snip_end_tag
  endif
  let command = a:command
  let s:snip_temp = substitute(command, "\\", "\\\\\\\\","g")
  " Save current value of 'z'
  let s:snip_save = @z
  let @z=a:z
  " Call the command
  execute 'let @z = '. a:command
  " Replace the value
  let ret = @z
  let @z = s:snip_save
  return ret
  call setline(line("."),substitute(getline("."),snip_start_tag.s:replaceVal.s:matchVal.snip_elem_delim.s:snip_temp.snip_end_tag, @z, "g"))
endfunction
" }}}
" {{{ MakeChanges() - Search the document making all the changes required
" This function has been factored out to allow the addition of commands in tags

function! <SID>MakeChanges()
  " Make all the changes
  " Change all the tags with the same name and no commands defined
  if <SID>CheckForBufferTags()
    let snip_elem_delim = b:snip_elem_delim
    let snip_start_tag = b:snip_start_tag
    let snip_end_tag = b:snip_end_tag
  else
    let snip_elem_delim = g:snip_elem_delim
    let snip_start_tag = g:snip_start_tag
    let snip_end_tag = g:snip_end_tag
  endif

  if s:matchVal == ""
    return
  endif
  call <SID>Debug("Matching on this value: ".s:matchVal)
  call <SID>Debug("Replacing with this value: ".s:replaceVal)
  while search(snip_start_tag.s:matchVal.snip_end_tag,"w") > 0
    call setline(line("."),substitute(getline("."), snip_start_tag.s:matchVal.snip_end_tag, s:replaceVal,"g"))
  endwhile
  " Change all the tags with the same name and a command defined.
  " I.e. start tag, tag name (matchVal), element delimiter, characters not
  " whitespace and then end tag
  call <SID>Debug("Searching for this string: ".snip_start_tag.s:matchVal.snip_elem_delim)
  while search(snip_start_tag.s:matchVal.snip_elem_delim,"w") > 0
    " Grab the command
    " We need to search from the cursor position to avoid problems when the
    " snip_delimiter is on the line
    let commandText = matchstr(getline("."),snip_elem_delim.".\\{-}".snip_end_tag, col("."))
    call <SID>Debug("Found this command text: ".commandText)
    let commandToRun = strpart(commandText,1,strlen(commandText)-strlen(snip_end_tag)-1)
    call <SID>Debug("Running this command: ".commandToRun)
    let s:snip_temp = substitute(commandToRun, "\\", "\\\\\\\\","g")
    let commandResult = <SID>RunCommand(commandToRun, s:replaceVal)
    call <SID>Debug("Got this result: ".commandResult)
    let tagmatch = '\V'.snip_start_tag.s:matchVal.snip_elem_delim.s:snip_temp.snip_end_tag
    let lines = split(substitute(getline("."), tagmatch, commandResult, "g"),'\n')
    if len(lines) > 1
      call setline(".", lines[0])
      call append(".", lines[1:])
    else
      call setline(".", lines)
    endif
  endwhile
endfunction

" }}}
" {{{ ChangeVals() - Rewrite of ChangedVal and NoChangedVal avoiding code
" duplication
function! <SID>ChangeVals(changed)
  if a:changed == 1
    let s:CHANGED_VAL = 1
  else
    let s:CHANGED_VAL = 0
  endif
  if <SID>CheckForBufferTags()
    let snip_elem_delim = b:snip_elem_delim
    let snip_start_tag = b:snip_start_tag
    let snip_end_tag = b:snip_end_tag
  else
    let snip_elem_delim = g:snip_elem_delim
    let snip_start_tag = g:snip_start_tag
    let snip_end_tag = g:snip_end_tag
  endif
  let elem_match = match(s:line, snip_elem_delim, s:curCurs)
  let tagstart = strridx(getline("."), snip_start_tag,s:curCurs)+strlen(snip_start_tag)
  if elem_match != -1 && elem_match < match(s:line, snip_end_tag, s:curCurs)
    " We've got snip_elem_delim  before snip_end_tag so we have a command to
    " run. There are no longer default values for a tag, the name is used
    " instead.
    " Grab the command to run
    let commandText = matchstr(s:line, b:search_endVal, match(s:line, snip_elem_delim, s:curCurs))
    let commandToRun = strpart(commandText,1,strlen(commandText)-strlen(snip_end_tag)+1)
    let commandMatch = substitute(commandToRun, '\', '\\\\', "g")
    " matchVal is the same regardless of whether we changed the value or not.
    " It's always from the cursor to b:search_commandVal (since we've got a
    " command to run)
    let s:matchVal = matchstr(s:line, b:search_commandVal, s:curCurs)
    " replaceVal is the only thing that will differ.
    if s:CHANGED_VAL
      " The value has changed so we need to grab our current position back
      " to the start of the tag
      let replaceVal = strpart(getline("."), tagstart,s:curCurs-tagstart)
      call <SID>Debug("User entered this value: ".replaceVal)
      let tagmatch = snip_start_tag.replaceVal.s:matchVal.snip_elem_delim.commandMatch.snip_end_tag
    else
      " The value hasn't changed so it's just the matchVal (the tag name)
      " without any quotes that are around it
      let replaceVal = substitute(s:matchVal, '^\"\(.*\)\"$', "\1", "")
      call <SID>Debug("User did not enter a value. Replacing with this value: ".replaceVal)
      let tagmatch = snip_start_tag.s:matchVal.snip_elem_delim.commandMatch.snip_end_tag
    endif
    call <SID>Debug("Matching on this string: ".tagmatch)
    let tagsubsitution = <SID>RunCommand(commandToRun, replaceVal)
    let lines = split(substitute(getline("."), tagmatch, tagsubsitution, "g"),'\n')
    if len(lines) > 1
      call setline(".", lines[0])
      call append(".", lines[1:])
    else
      call setline(".", lines)
    endif
    "let s:replaceVal = tagsubsitution
    " We use replaceVal instead of tagsubsitution as otherwise the command
    " result will be passed to subsequent tags
    let s:replaceVal = replaceVal
    call <SID>MakeChanges()
  else
    " There's no command to run
    let s:matchVal = matchstr(s:line, b:search_endVal, s:curCurs)
    let firstBit = strpart(s:line,0, tagstart - strlen(snip_start_tag))
    if s:CHANGED_VAL
      " This is the value the user typed in. We pull it out as the
      " line up to the cursor less the 'firstBit' above. We also
      " chop off the start_tag as well.
      let middleBit = strpart(strpart(getline("."), strlen(firstBit), s:curCurs-strlen(firstBit)), strlen(snip_start_tag))
      let s:replaceVal = strpart(strpart(s:line, tagstart-1, s:curCurs - (tagstart - 1)), 1)
    else
      if s:matchVal[0] == '"' 
        " We have a quotes around our tag name so let's remove them
        let s:replaceVal = strpart(s:matchVal,1,strlen(s:matchVal)-2)
        let middleBit = strpart(s:line,s:curCurs+1, match(s:line, snip_end_tag, s:curCurs)-s:curCurs-2)
      else
        let s:replaceVal = strpart(s:matchVal,0,strlen(s:matchVal))
        let middleBit = strpart(s:line,s:curCurs,match(s:line,snip_end_tag,s:curCurs)-s:curCurs)
      endif
      let firstBit = strpart(s:line,0,s:curCurs - strlen(snip_start_tag))
    endif
    let lastBit = strpart(strpart(s:line,match(s:line,snip_end_tag,s:curCurs)),strlen(snip_end_tag))
    call setline(line("."),firstBit.middleBit.lastBit)
    if s:matchVal != ""
      call <SID>MakeChanges()
    endif
  endif
  unlet s:CHANGED_VAL
  call <SID>NextHop()
endfunction
" }}}
"{{{ SID() - Get the SID for the current script
function! s:SID()
  return matchstr(expand('<sfile>'), '<SNR>\zs\d\+\ze_SID$')
endfun
"}}}
"{{{ CheckForInTag() - Check whether we're in a tag
function! <SID>CheckForInTag()
  if <SID>CheckForBufferTags()
    let snip_elem_delim = b:snip_elem_delim
    let snip_start_tag = b:snip_start_tag
    let snip_end_tag = b:snip_end_tag
  else
    let snip_elem_delim = g:snip_elem_delim
    let snip_start_tag = g:snip_start_tag
    let snip_end_tag = g:snip_end_tag
  endif
  if snip_start_tag != snip_end_tag
    " The tags are different so we can check to see whether the
    " end tag comes before a start tag
    let s:endMatch = match(s:line, snip_end_tag, s:curCurs)
    let s:startMatch = match(s:line, snip_start_tag, s:curCurs)
    let s:whiteSpace = match(s:line, '\s', s:curCurs)

    if s:endMatch != -1 && ((s:endMatch < s:startMatch) || s:startMatch == -1)
      " End has come before start so we're in a tag.
      return 1
    else
      return 0
    endif
  else
    " Start and end tags are the same so we need do tag counting to see
    " whether we're in a tag.
    let s:count = 0
    let s:curSkip = s:curCurs
    while match(strpart(s:line,s:curSkip),snip_start_tag) != -1 
      if match(strpart(s:line,s:curSkip),snip_start_tag) == 0
        let s:curSkip = s:curSkip + 1
      else
        let s:curSkip = s:curSkip + 1 + match(strpart(s:line,s:curSkip),snip_start_tag)
      endif
      let s:count = s:count + 1
    endwhile
    if (s:count % 2) == 1
      " Odd number of tags implies we're inside a tag.
      return 1
    else
      " We're not inside a tag.
      return 0
    endif
  endif
endfunction
"}}}
" {{{ Jumper()
" We need to rewrite this function to reflect the new behaviour. Every jump
" will now delete the markers so we need to allow for the following conditions
" 1. Empty tags e.g. "<>".  When we land inside then we delete the tags.
"  "<:>" is now an invalid tag (use "<>" instead) so we don't need to check for
"  this
" 2. Tag with variable name.  Save the variable name for the next jump.
" 3. Tag with command. Tags no longer have default values. Everything after the
" centre delimiter until the end tag is assumed to be a command.
" 
" Jumper is performed when we want to perform a jump.  If we've landed in a
" 1. style tag then we'll be in free form text and just want to jump to the
" next tag.  If we're in a 2. or 3. style tag then we need to look for whether
" the value has changed and make all the replacements.   If we're in a 3.
" style tag then we need to replace all the occurrences with their command
" modified values.
" 
function! <SID>Jumper()
  " Set up some useful variables
  if <SID>CheckForBufferTags()
    let snip_elem_delim = b:snip_elem_delim
    let snip_start_tag = b:snip_start_tag
    let snip_end_tag = b:snip_end_tag
  else
    let snip_elem_delim = g:snip_elem_delim
    let snip_start_tag = g:snip_start_tag
    let snip_end_tag = g:snip_end_tag
  endif
  if !exists('b:search_str')
    return "\<Tab>"
  endif
  if exists('g:snip_set_textmate_cp') && g:snip_set_textmate_cp == 1
    let s:curCurs = col(".") - 1
  else
    let s:curCurs = col(".")
  endif
  let s:curLine = line(".")
  let s:line = getline(".")
  let s:matchVal = ""
  let s:replaceVal = ""
  " Check to see whether we're at the start of a tag.  
  " start then we should be assuming that we've got a 'default' value or a
  " command to run.  Otherwise the user will have pressed the jump key
  " without changing the value.
  " First we need to check that we're inside a tag i.e. the previous
  " jump didn't land us in a 1. style tag.
   
  if exists("g:snip_set_textmate_cp") && g:snip_set_textmate_cp == 1
    " First we'll check that the user hasn't just typed a snippet to expand
    "
    let origword = matchstr(strpart(getline("."), 0, s:curCurs), '\k\{-}$')
    let word = <SID>Hash(origword)
"    " The following code is lifted wholesale from the imaps.vim script - Many
"    " thanks for the inspiration to add the TextMate compatibility
"    " Unless we are at the very end of the word, we need to go back in order
"    " to find the last word typed.
    let rhs = ''
    " We don't use the FT specific variable names so we'll avoid that check. We
    " do need to check for buffer specific expansions, however (which is how we
    " achieve the same thing).
    if exists('b:snip_'.word)
      exe 'let rhs = b:snip_'.word
    elseif exists('g:snip_'.word)
    " also check for global definitions
      exe 'let rhs = g:snip_'.word
    end

    if rhs != ''
      " if this is a mapping, then erase the previous part of the map
      " by also returning a number of backspaces.
      let bkspc = substitute(origword, '.', "\<bs>", "g")

      let s:curCurs = s:curCurs - strlen(expand('<cword>')) - 1
      let s:just_expanded = 1
      return bkspc.rhs."\<Esc>:call cursor(".s:curLine.", ".s:curCurs.")\<CR>:call <SNR>".s:SID()."_NextHop()\<CR>"
    else
      " No definition so let's check to see whether we're in a tag
      if <SID>CheckForInTag()
        " We're in a tag so we need to do processing
        if strpart(s:line, s:curCurs - strlen(snip_start_tag), strlen(snip_start_tag)) == snip_start_tag
          call <SID>ChangeVals(0)
          return ''
        else
          call <SID>ChangeVals(1)
          return ''
        endif
      else
        " We're not in a tag so we'll see whether there are more tags
        if search(b:search_str, "n")
          " More tags so let's perform nexthop
          let s:replaceVal = ""
          call <SID>NextHop()
          return ''
        else
          " No more tags so let's return a Tab
          return "\<Tab>"
        endif
      endif
    end
  endif
  " We're not using TextMate style jumping so let's use the old school method

  if <SID>CheckForInTag()
    if strpart(s:line, s:curCurs - strlen(snip_start_tag), strlen(snip_start_tag)) == snip_start_tag
      call <SID>ChangeVals(0)
    else
      call <SID>ChangeVals(1)
    endif
  else
    " Not in a tag so let's jump to the next tag
    let s:replaceVal = ""
    call <SID>NextHop()
  endif
endfunction
" }}}
" {{{ Set up the 'Iabbr' and 'Snippet' commands
command! -nargs=+ Iabbr execute <SID>SetCom(<q-args>)
command! -nargs=+ Snippet execute <SID>SetCom("<buffer> ".<q-args>)
"}}}
" {{{ Utility functions
" The following two functions are from Benji Fisher's foo.vim - a very helpful file
" The built-in getchar() function returns a Number for an 8-bit character, and
" a String for any other character.  This version always returns a String.
fun! Getchar()
  let c = getchar()
  if c != 0
    let c = nr2char(c)
  endif
  return c
endfun

fun! Eatchar(pat)
   let c = Getchar()
   return (c =~ a:pat) ? '' : c
endfun

" This function will just return what's passed to it. 
" We use string() so that numbers can be passed more naturally
fun! D(text)
  if exists('s:CHANGED_VAL') && s:CHANGED_VAL == 1
    return @z
  else
    return a:text
  endif
endfun

" <SID>Hash allows the use of special characters in snippets when textmate mode
" is used.
" This function is lifted straight from the imaps.vim plugin. Please let me know
" if this is against licensing.
function! <SID>Hash(text)
	return substitute(a:text, '\([^[:alnum:]]\)',
				\ '\="_".char2nr(submatch(1))."_"', 'g')
endfunction

" }}}
" Abbreviations are set up as usual but using the Iabbr command rather
" than iabbr.  Formatting needs to be done as usual, hence the '<<'s and
" similar.  Not sure how well @ works as a delimiter but it can be changed
" BEST PRACTICE RECOMMENDATION: Store your abbeviation definitions in
" '.vim/after/plugin/' so they will get sourced once the plugin has been loaded
" vim: set tw=80 sw=2 sts=2 et foldmethod=marker :
