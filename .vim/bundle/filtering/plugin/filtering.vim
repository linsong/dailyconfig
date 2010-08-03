"=============================================================================
"    Copyright: Copyright (C) 2009 Niels Aan de Brugh
"               Permission is hereby granted to use and distribute this code,
"               with or without modifications, provided that this copyright
"               notice is copied with it. Like anything else that's free,
"               filtering.vim is provided *as is* and comes with no
"               warranty of any kind, either expressed or implied. In no
"               event will the copyright holder be liable for any damages
"               resulting from the use of this software.
" Name Of File: filtering.vim
"  Description: Quick Filter Plugin Vim Plugin
"   Maintainer: Niels Aan de Brugh (nielsadb+vim at gmail dot com)
" Last Changed: Sunday, 23 Aug 2009
"      Version: See g:filtering_version for version number.
"        Usage: This file should reside in the plugin directory and be
"               automatically sourced.
"=============================================================================

if exists("g:filtering_version") || &cp
    finish
endif
let g:filtering_version = "1.0.4"

"=============================================================================
" Configuration part
"=============================================================================

" The amount of context lines (the grayish lines on the top and bottom of a
" search result) that is initially used. You can change the value inside a
" search window easily (keys c/C by default).
let s:ContextLines = 0

" Set the following to 1 if you want the original buffer to automatically
" follow your selection in the filter window. This setting can be toggled by
" pressing 'a' (default) in a filter window.
let s:AutoFollow = 0

" Key mappings. Some implementation default is showing here. Just pass a
" string to search for as the first argument and 0 as the second.
nmap ,F :call Gather(input("Filter on term: "), 0)<CR>
nmap ,f :call Gather(@/, 0)<CR>:echo<CR>
nmap ,g :call GotoOpenSearchBuffer()<CR>

" This is the highlighting group used for the filter context lines. I picked a
" value that works good with my current color scheme.
hi FilterContext guifg=grey60

" This option emulates the wrapscan setting when using j/k (default bindings)
" in the filter window. For regular search, the global option wrapscan is
" applied (setlocal is not available). 0 = 'nowrapscan', 1 = 'wrapscan'.
let s:filterWindowWrapScan = 0

" This function is called when a new search buffer is created. You can change
" the default key mappings and add more.
function! s:UserDefinedSearchBuffer()
    " GotoLineInOriginal(0 = keep search window open, 1 = close search window)
    nnoremap <buffer> <CR> :call GotoLineInOriginal(0)<CR>:echo<CR>
    nnoremap <buffer> <S-CR> :call GotoLineInOriginal(1)<CR>:echo<CR>
    nnoremap <buffer> <Esc> :bdelete<CR>:echo<CR>
    nnoremap <buffer> r :call Refresh()<CR>:echo<CR>
    nnoremap <buffer> a :call ToggleAutoFollow()<CR>
    nnoremap <buffer> o :call FollowSelectionInOriginal()<CR>
    " Update the number of lines of context showing with some delta.
    nnoremap <buffer> c :call ChangeContextLines(1)<CR>:echo<CR>
    nnoremap <buffer> C :call ChangeContextLines(-1)<CR>:echo<CR>
    " Easily jump through the real results.
    nnoremap <buffer> j :call NextResult()<CR>:echo<CR>
    nnoremap <buffer> k :call PreviousResult()<CR>:echo<CR>

    setlocal nonumber
    setlocal cursorline
endfunction

"=============================================================================
" Implementation part
"=============================================================================
function! s:IsSearchBuffer()
    return exists("b:original")
endfunction

function! s:GotoLine(line)
    let l:pos = getpos(".")
    let l:pos[1] = a:line
    let l:pos[2] = 1
    call setpos(".", l:pos)
endfunction

function! s:GetOriginalBuffer()
    if s:IsSearchBuffer()
        return b:original
    else
        return bufnr("%")
    endif
endfunction

function! s:GetSearchedFromBuffer()
    if s:IsSearchBuffer()
        return b:searched_from
    endif
endfunction

function! s:GetUsedLinePattern()
    if s:IsSearchBuffer()
        return b:line_pattern
    endif
endfunction

function! s:GetGeneration()
    if s:IsSearchBuffer()
        return b:generation
    endif
endfunction

function! s:GetNewGenerationNumber()
    let l:original = s:GetOriginalBuffer()
    let l:lastUsed = getbufvar(l:original, "filterPlugin_LastGenerationId")
    if empty(l:lastUsed)
        let l:newGen = 1
    else
        let l:newGen = l:lastUsed + 1
    endif
    call setbufvar(l:original, "filterPlugin_LastGenerationId", l:newGen)
    return l:newGen
endfunction

function! s:FlipToWindowOrLoadBufferHere(buffer_nr)
    let l:win = bufwinnr(a:buffer_nr)
    if l:win == -1
        execute "buffer " . a:buffer_nr
    else
        execute l:win . "wincmd w"
    endif
endfunction

function! s:GetLineNumber(line)
    let l:linenr = matchstr(a:line, "^[_ ] *[0-9]*:")
    if empty(l:linenr)
        return -1
    endif
    let l:firstdigit = match(l:linenr, "[0-9]")
    let l:linenr = strpart(l:linenr, l:firstdigit, strlen(l:linenr) - l:firstdigit - 1)
    return l:linenr
endfunction

function! GotoLineInOriginal(close_search)
    let l:original = s:GetOriginalBuffer()
    let l:linenr = s:GetLineNumber(getline("."))
    if l:linenr == -1
        call s:FancyEcho("Line in search buffer is @2incorrectly formatted@0.")
        return
    endif
    if a:close_search
        bdelete
    endif
    call s:FlipToWindowOrLoadBufferHere(l:original)
    call s:GotoLine(l:linenr)
    normal! zz
    call s:BlinkColumnAndLine(1, 1, 0)
endfunction

function! FollowSelectionInOriginal()
    let l:res = s:DoFollowSelectionInOriginal(1)
    if l:res == -1
        call s:FancyEcho("Line in search buffer is @2incorrectly formatted@0.")
    elseif l:res == -2
        call s:FancyEcho("Original buffer is currently @2not showing@0.")
    else
        echo
    endif
endfunction

function! s:DoFollowSelectionInOriginal(blink)
    let l:lineNr = s:GetLineNumber(getline("."))
    if l:lineNr == -1
        return -1
    endif
    let l:originalWin = bufwinnr(s:GetOriginalBuffer())
    if l:originalWin == -1
        return -2
    else
        let l:searchWin = winnr()
        execute l:originalWin . "wincmd w"
        call s:GotoLine(l:lineNr)
        normal! zz
        if a:blink
            call s:BlinkColumnAndLine(1, 1, 0)
        endif
        execute l:searchWin . "wincmd w"
        return 0
    endif
endfunction

function! s:AddMatch()
    let l:line = line(".")

    " Determine context ranges on top and bottom.
    let l:top = l:line - s:ContextLines
    if l:top < 1
        let l:top = 1
    endif
    let l:bottom = l:line + s:ContextLines
    if l:bottom > line("$")
        let l:bottom = line("$")
    endif
    
    " Copy the context on the top.
    let l:i = l:top
    while l:i < l:line
        if !has_key(s:Gather, l:i)
            let s:Gather[l:i] = printf("_%5d: %s", l:i, getline(l:i))
        endif
        let l:i = l:i + 1
    endwhile

    " Copy the match itself. Note that we always overwrite existing entries.
    " This is for the case when this match was already included as the bottom
    " context of an earlier match.
    let s:Gather[l:line] = printf(" %5d: %s", l:line, getline(l:line))

    " Copy the context on the top. Note that :g works from top to bottom, so
    " we can be sure that we don't have these lines yet.
    let l:i = l:line + 1
    while l:i <= l:bottom
        let s:Gather[l:i] = printf("_%5d: %s", l:i, getline(l:i))
        let l:i = l:i + 1
    endwhile
endfunction

" For other search windows, the line is already formatted. Don't copy
" any context. We could copy context if s:ContextLines is currently less or
" equal to the s:ContextLines that was used to generate the first search
" buffer. A Refresh() can ensure this, but that can be an expensive operation.
" For now, no context.
" We don't include matches in the context. This is because we want a search
" inside another search buffer to have proper AND-semantics, i.e. the results
" in the final buffer should include both search terms, and not just the last
" because it tagged along as context in the first search.
function! s:AddMatchFromSearchBuffer()
    let l:linec = getline(".")
    " If the match was found in the context, don't include it in the results.
    if strpart(l:linec, 0, 1) == " "
        let s:Gather[line(".")] = l:linec
    endif
endfunction

" The big function that does the actual gathering, as well as creating new
" search buffers.
function! Gather(line_pattern, search_buffer)
    if empty(a:line_pattern)
        return
    endif

    " Determine the original filter: in case of another search window, inherit
    " the value.
    let l:original = s:GetOriginalBuffer()
    let l:generation = s:GetNewGenerationNumber()
    let l:searched_from = bufnr("%")

    " Fill gather list, return if there are no results
    let l:orig_ft = &ft
    let l:orig = getpos(".")
    let s:Gather = {}
    if s:IsSearchBuffer()
        silent execute "g/" . a:line_pattern . "/call s:AddMatchFromSearchBuffer()"
    else
        silent execute "g/" . a:line_pattern . "/call s:AddMatch()"
    endif
    call setpos(".", l:orig)
    if empty(s:Gather)
        call s:FancyEcho("The search for @1" . a:line_pattern . "@0 has yielded @2no results@0.")
        unlet s:Gather
        return
    endif

    if a:search_buffer == 0
        " Create new scratch buffer
        new
        setlocal buftype=nofile
        setlocal bufhidden=hide
        setlocal noswapfile
        " Store original link locally to allow jumping to the original buffer.
        " The searched_from and line_pattern values are needed for refresh.
        let b:original = l:original
        let b:searched_from = l:searched_from
        let b:line_pattern = a:line_pattern
        " Generation 1 = first window opened, 2 = opened from gen 1, etc.
        let b:generation = l:generation
        " Install auto command for moving the cursor to handle auto-follow.
        au CursorMoved <buffer> call s:CursorMoved()
        " Auto command to clean-up the generation counter in the original.
        execute "au BufDelete <buffer> call s:BufferClosed(" . l:original . ")"
        " Inherit the file type of the original. Syntax highlighting may be lost
        " because of missing brackets etc.
        execute "setlocal filetype=".l:orig_ft
        " Add a syntax match for context lines.
        syntax match FilterContext "^_ *\d\+: .*$"
        " Now call the user defined function to include mappings etc.
        call s:UserDefinedSearchBuffer()
    else
        " Clear an existing buffer.
        call s:FlipToWindowOrLoadBufferHere(a:search_buffer)
        set modifiable
        silent! normal! gg"_dG
    endif

    " Copy all results in the new scratch buffer. Sort decending first.
    function! Cmp(a, b)
        let l:a = str2nr(a:a)
        let l:b = str2nr(a:b)
        return l:a == l:b ? 0 : l:a > l:b ? -1 : 1
    endfunction
    for linenr in sort(keys(s:Gather), "Cmp")
        call append(0, s:Gather[linenr])
    endfor
    normal! ddgg
    setlocal nomodifiable

    unlet s:Gather
endfunction

function! Refresh()
    " See if the buffer we started the last search from still exists.
    if !bufexists(b:searched_from)
        if s:GetOriginalBuffer() == s:GetSearchedFromBuffer()
            call s:FancyEcho("The buffer from which the last search was started @2no longer exists@0.")
        else
            call s:FancyEcho("The filter window from which the search for this window was started @2no longer exists@0.")
        endif
        return
    endif

    " Store buffer variables from the search buffer.
    let l:search_buffer = bufnr("%")
    let l:line_pattern = b:line_pattern

    " Store the line number currently selected in the hope that we can find it
    " after the refresh.
    let l:refresh_from_line = s:GetLineNumber(getline("."))

    " Re-gather results.
    call s:FlipToWindowOrLoadBufferHere(b:searched_from)
    call Gather(l:line_pattern, l:search_buffer)

    " Try to get back to the line where the user pressed Refresh.
    if l:refresh_from_line != -1
        if search("^ *" . l:refresh_from_line . ":") != 0
            normal! zz
        endif
    endif
endfunction

" Add 'step' to the s:ContextLines value and update the search buffer.
function! ChangeContextLines(step)
    let s:ContextLines = s:ContextLines + a:step
    if s:ContextLines < 0
        let s:ContextLines = 0
    endif
    call Refresh()
    call s:FancyEcho("Now showing @1" . s:ContextLines . "@0 lines of context around matches.")
endfunction

function! ToggleAutoFollow()
    let s:AutoFollow = !s:AutoFollow
    if s:AutoFollow
        call s:FancyEcho("Original buffer will @1follow@0 your selection in the filter window.")
    else
        call s:FancyEcho("Original buffer will @1not follow@0 your selection in the filter window.")
    endif
endfunction

function! s:CursorMoved()
    if s:AutoFollow && (!exists("b:line_before_last_move") || b:line_before_last_move != line("."))
        call s:DoFollowSelectionInOriginal(0)
        let b:line_before_last_move = line(".")
    endif
endfunction

function! s:BufferClosed(original)
    if bufexists(a:original) && !empty(getbufvar(a:original, "filterPlugin_LastGenerationId"))
        let l:newestGen = 0
        for buf in tabpagebuflist()
            if buflisted(buf) && getbufvar(buf, "original") == a:original
                let l:thisgen = getbufvar(buf, "generation")
                if l:thisgen > l:newestGen
                    let l:newestGen = l:thisgen
                endif
            endif
        endfor
        call setbufvar(a:original, "filterPlugin_LastGenerationId", l:newestGen)
    endif
endfunction

function! NextResult()
    if s:filterWindowWrapScan
        call search("^ ", "w")
    else
        call search("^ ", "W")
    endif
endfunction

function! PreviousResult()
    normal! 0
    if s:filterWindowWrapScan
        call search("^ ", "bw")
    else
        call search("^ ", "bW")
    endif
endfunction

function! GotoOpenSearchBuffer()
    " Find the newest search buffer that is still older than the current one.
    " If the current window is an original buffer, than simply find the newest
    " search buffer, full stop.
    function! InWin(vars)
        if s:IsSearchBuffer() && s:GetOriginalBuffer() == a:vars.original
           let l:generation = s:GetGeneration()
           if l:generation < a:vars.olderThan && l:generation > a:vars.newestGen
               let a:vars.newestGen = b:generation
               let a:vars.newestWin = winnr()
           endif
       endif
    endfunction
    let l:startWin = winnr()
    let l:olderThan = s:GetGeneration()
    if l:olderThan == 0
        let l:olderThan = 99999
    endif
    let l:vars = {"original": s:GetOriginalBuffer(), "olderThan": l:olderThan, "newestGen":-1, "newestWin":-1}
    windo call InWin(l:vars)
    if l:vars.newestWin != -1
        execute l:vars.newestWin . "wincmd w"
        call s:FancyEcho("Now in @1newest@0 filter window. Press ,g @1again@0 to skip to an older one.")
    else
        execute l:startWin . "wincmd w"
        if s:IsSearchBuffer()
            call s:FancyEcho("@2No @1older@2 open filter window found@0 than the current one.")
        else
            call s:FancyEcho("@2No open filter window found@0 for current buffer.")
        endif
    endif
endfunction

"=============================================================================
" Scripting Support
"=============================================================================

function! s:FancyEcho(text)
    let l:i = 0
    while l:i < len(a:text)
        if a:text[l:i] == "@"
            let l:i = l:i + 1
            if a:text[l:i] == "0"
                echohl None
            elseif a:text[l:i] == "1"
                echohl Directory
            elseif a:text[l:i] == "2"
                echohl WarningMsg
            elseif a:text[l:i] == "@"
                echon "@"
            endif
        else
            echon a:text[l:i]
        endif
        let l:i = l:i + 1
    endwhile
    echohl None
endfunction

function! s:BlinkColumnAndLine(times, dorow, docol)
    let l:i = 0
    while l:i < 2*a:times
        let l:i = l:i + 1
        if a:dorow
            set invcursorline
        end
        if a:docol
            set invcursorcolumn
        end
        redraw
        sleep 100m
    endwhile
endfunction
