"=============================================================================
" File: increment_new.vim
" Author: Ely Schoenfeld (ely at nauta.com.mx)
"         Based on work done by: William Natter (natter at magma.ca)
"                                (vimscript #842)
"         That was based on work done by: Stanislav Sitar (sitar at procaut.sk)
"                                (vimscript #145),
" Creation Date: February 4, 2005
" Last Modified: June 23, 2007
" Version: 1.1
"
" Help:
"- Put increment_new.vim into a plugin directory.
"- Put increment_new.txt into a doc directory.
"
"  (see :set runtimepath)
"
"  For example in *nix OS:
"    - The plugin directory should be: ~/.vim/plugin
"    - The doc directory should be: ~/.vim/doc
" 
"  For example in Windows:
"    - The plugin directory should be: %PROGRAMFILES%\Vim\vimfiles\plugin
"    - The doc directory should be: %PROGRAMFILES%\Vim\vimfiles\doc
"
"    (To extract the files from a tar.gz in windows, I use a great program called 7Zip (http://www.7-zip.org)
"    
"  To be able to do:
"        :help Inc
"  you have to do, for example:
"        :helptags ~/.vim/doc
"  or
"        :helptags C:\Program Files\Vim\vimfiles\doc
"=========================================================================

" Command syntax:
"
"   :[line1,line2]Inc [i<number>] [s<number>] [p<regexp>] [w<number>] [c]
"
"   INCREMENT [i<number>]:  to change the increment between two consecutive matching lines
"
"   STARTING  [s<number>]:  to change the starting value
"
"   PATTERN   [p<regexp>]:  if not using w parameter:
"                               to replace the pattern
"                           if using w parameter: 
"                               to search the line that matches the patern and change a specific word
"
"                           NOTE: The regexp should be escaped. Be careful to:
"                                 a) use \ before spaces
"                                 b) \\ to place a literal \
"                                 c) \< or \> to place a literal < or > (Since Vim 7)
"
"   WORD      [w<number>]:  to replace the <number>th word from the beginning of the line (0 for the beginning)
"
"   CONFIRM   [c]        :  to confirm each substitution.
"
"   NOTE: the default values are: (this can be changed)
"             i: 1
"             s: 0
"             p: @
"             w: not active
"             c: not active
"
"   EXAMPLE:
"       For examples see increment.txt
"

let g:IncIncr = 1
let g:IncStartVal = 0
let g:IncMatchPat = "@"
let g:WordToChange = "-1"
let g:DoConfirm = "-1"

function! Increment(...) range

    " Arguments to the function:
    "   range with firstline and lastline
    "   [i<number>] to change the increment between two consecutive matching lines
    "   [s<number>] to change the starting value
    "   [p<regexp>] to change the pattern

    " save line numbers
    let lfirst = a:firstline
    let llast = a:lastline

    " Defaults
    let incr = g:IncIncr
    let startingValue = g:IncStartVal
    let pattern = g:IncMatchPat
    let word = g:WordToChange
    let confirm = g:DoConfirm

    " Get arguments
    " Change letter with a command setting the appropriate value
    let nargs = 1
    while nargs <= a:0
        let toex = ""
        if a:{nargs} =~? "^i"
            let toex = substitute(a:{nargs},"^i","let incr = ","")
        elseif a:{nargs} =~? "^s"
            let toex = substitute(a:{nargs},"^s","let startingValue = ","")
        elseif a:{nargs} =~? "^p"
            let toex = substitute(a:{nargs},"^p","let pattern = \"","")
            let toex = substitute(toex,"$","\"","")
        elseif a:{nargs} =~? "^w"
            let toex = substitute(a:{nargs},"^w","let word = ","")
        elseif a:{nargs} =~? "^c"
            let toex = "let confirm = 1"
        else
            " Ignore
            let toex = ""
        endif
        execute toex
        let nargs = nargs + 1
    endwhile

    let val = startingValue
    silent! execute lfirst
    let lineNb = line(".")
    while search(pattern, "W")
        let lineNb = line(".")
        if lineNb > llast
            break
        endif

        if confirm > -1
            echo "---------------------------------------"
            "let CurrentLine= getline(lineNb)
            let st=""
            "let st=st . "---> " . CurrentLine . "\n"
            echo "---> " . getline(lineNb)
            if word > -1
                let st=st . "Will press \"w\" ".word." times from the beginning before replace the word (\"cw\")\n"
            endif
            let st=st . "Pattern: \"" . pattern . "\"\n"
            let st=st . "Replace with ".val."?"
            let choice = confirm(st, "&Yes\nNo\nAll\nQuit")
            if choice == 1
                "do nothing
            elseif choice == 2
                continue
            elseif choice == 3
                let confirm = -1
            elseif choice == 4
                break
            endif
        endif

        if word < 0
            silent! execute lineNb."s/".pattern."/".val."/"
        elseif word == 0
            silent! execute lineNb."g/^/normal!cw".val
            execute "normal! $"
        else
            silent! execute lineNb."g/^/normal!".word."wcw".val
            execute "normal! $"
        endif

        let val = val + incr

        if confirm > -1 
            if choice == 1
                "let CurrentLine= getline(lineNb)
                let st=""
                "let st=st . "---> " . CurrentLine . "\n"
                echo "---> " . getline(lineNb)
                let st=st . "Replace Ok?"
                let choice = confirm(st, "Yes\nYes &All\nQuit")
                if choice == 1
                    "do nothing
                elseif choice == 2
                    let confirm = -1
                elseif choice == 3
                    break
                endif
            endif
        endif

    endwhile

endfunction

command! -n=* -range Inc2 :<line1>,<line2>call Increment(<f-args>)

