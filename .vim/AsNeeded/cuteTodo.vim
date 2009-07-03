"=============================================================================
" What Is This:
" File: metatodo.vim
" Author: Vincent Berthoux <twinside@gmail.com>
" Last Change: 2009 june 28
" Version: 1.1
"
" ChangeLog:
"     * 1.1 :- Taking into account "Documents and Settings" folder...
"            - Adding icons source from $VIM or $VIMRUNTIME
"            - Checking the nocompatible option (the only one required)
"     * 1.0 : Original version
if exists("g:__CUTETODO_VIM__")
    finish
endif
let g:__CUTETODO_VIM__ = 1

"======================================================================
"           Configuration checking
"======================================================================
if &compatible
    echom 'cuteTodoList require the nocompatible option, loading aborted'
    echom "To fix it add 'set nocompatible' in your .vimrc file"
    finish
endif

fun! s:GetInstallPath(of) "{{{
    " If the plugin in installed in the vim runtime directory
    if filereadable( expand( '$VIMRUNTIME' ) . a:of )
        return expand( '$VIMRUNTIME' )
    endif

    " If the plugin in installed in the vim directory
    if filereadable( expand( '$VIM' ) . a:of )
        return expand( '$VIM' )
    endif

    if has("win32")
        let vimprofile = 'vimfiles'
    else
        let vimprofile = '.vim'
    endif

    " else in the profile directory
    if filereadable( expand( '~/' . vimprofile ) . a:of )
        return expand('~/' . vimprofile )
    endif

    return ''
endfunction "}}}

if has("win32")
    let s:ext = '.ico'
else
    let s:ext = '.png'
endif

let s:path = escape( s:GetInstallPath( '/signs/priol1' . s:ext ), ' \' )
if s:path == ''
    echom "Cute Todo list can't find icons, plugin not loaded."
    finish
else
    let s:path = s:path . '/signs/'
endif
"======================================================================
"           General Options
"======================================================================
if !exists("g:todo_list_buff_name")
    let g:todo_list_buff_name = 'Todo\ List'
endif

if !exists("g:todo_generate_auto")
    let g:todo_generate_auto = 1
endif

if !exists("g:todo_list_filename")
    let g:todo_list_filename = '.todo.txt'
endif

if !exists("g:todo_list_globfilename")
    let g:todo_list_globfilename = '.global.todo.txt'
endif

"======================================================================
"           Plugin data
"======================================================================
" The todo list is stored with the following type (haskell
" notation) :
" DisplayName, Filename, Text :: String
" Priority :: Int
" SortKind :: Int
" s:todo_list :: [(DisplayName, Filename, SortKind, [(Priority, Text)])]
" But as viml doesn't provide tuples, they are implemented
" as lists.
let s:todo_list = []
" When only part of data is needed, prefer accessing it
" using following indices, to prevent breaking if data structure
" change.
let s:todo_sort_index = 2   " Index of the SortKind thingy
let s:todo_list_index = 3   " Index of the [(Prio, Text)] thingy

let s:signId = 99000
let s:signCount = 0
let s:todoMinPrio = 0
let s:todoMaxPrio = 4
let s:default_priority = 2
let s:defaultSortKind = 0

exec 'sign define todopriop2 text=!! icon=' . s:path . 'priop2' . s:ext
exec 'sign define todopriop1 text=!1 icon=' . s:path . 'priop1' . s:ext
exec 'sign define todopriol1 text=_1 icon=' . s:path . 'priol1' . s:ext
exec 'sign define todopriol2 text=__ icon=' . s:path . 'priol2' . s:ext

let s:todo_inner_help_appeal = ['" Press <F1> for help'
                              \,' '
                              \]
let s:todo_inner_help_text = [
    \ '" Help : <F1> to close'
    \,'"  +   : Increase task priority.'
    \,'"  -   : Decrease task priority.'
    \,'"  ^   : Move the task up.'
    \,'"  v   : Move the task down.'
    \,'"  m   : Modify the task.'
    \,'"  s   : Sort the todos.'
    \,'"  u   : Update todo from buffers.'
    \,'"  o   : Jump to generated todo.'
    \,'"<S-D> : Delete a task.'
    \,' '
    \]

"=============================================================================
"                Buffer support functions
"=============================================================================
fun! s:TodoRedraw( editLine ) "{{{
    " Remove everything
    setl modifiable
    call s:TodoRemoveSign()
    normal ggVG"zd
    " re-render
    call s:TodoWriteFile( s:todo_list )
    " Goto previous line in previous buffer...
    " faking a non-moving cursor
    execute 'normal ' . a:editLine . 'gg'
    " Hmm, resize test, not that good :-/
    "execute 'resize ' . line( '$' )
    call s:SaveTodoFile()
endfunction "}}}

fun! s:ComputeIndices() "{{{
    let editLine = line( '.' )
    let j = 0

    if b:todo_inner_help == 0
        " -1 for title
        " -1 for help line
        let linenb = editLine - 1 - len( s:todo_inner_help_appeal )
    else
        let linenb = editLine - 1 - len( s:todo_inner_help_text )
    endif

    for [disp, f, sortKind, todos] in s:todo_list
        if linenb <= len( todos )
            let index = linenb - 1
            return [editLine, j, index]
        endif
        let linenb = linenb - len( todos ) - 2
        let j = j + 1
    endfor
    return [editLine, -1, -1]
endfunction "}}}

" return -1 if no windows was open
"        >= 0 if cursor is now in the window
fun! s:TodoGotoWin() "{{{
    let bufnum = bufnr( g:todo_list_buff_name )
    if bufnum >= 0
        let win_num = bufwinnr( bufnum )
        " We must get a real window number, or
        " else the buffer would have been deleted
        " already
        exe win_num . "wincmd w"
        return 0
    endif
    return -1
endfunction "}}}

" Remove all the priority mark on the side of the buffer.
fun! s:TodoRemoveSign() "{{{
    let s:signCount = s:signCount - 1
    while s:signCount >= 0
        let unplacer = 'sign unplace ' . (s:signCount + s:signId)
        exec unplacer
        let s:signCount = s:signCount - 1
    endwhile
endfunction "}}}

" Save the local and global todos.
fun! s:SaveTodoFile() "{{{
    for [disp, filename, sortKind, todoList] in s:todo_list
        " The generated todolist has no filename.
        if filename == ''
            return
        endif

        let toWrite = []

        for [prio,line] in todoList
            call add( toWrite, prio . ':' . line )
        endfor

        call writefile( toWrite , filename )
    endfor
endfunction "}}}

let s:classNames = ['todopriol2', 'todopriol1', '', 'todopriop1', 'todopriop2']
fun! s:AttribSign( buffId, prio, line) "{{{
    let prioClass = get( s:classNames, a:prio )

    if prioClass != ''
        let id = s:signId + s:signCount
        let s:signCount = s:signCount + 1
        let toPlace = 'sign place ' . id
                    \ . ' line=' . a:line
                    \ . ' name=' . prioClass
                    \ . ' buffer=' . a:buffId
        execute toPlace
    endif
endfunction "}}}

fun! s:TodoWriteFile( todol ) "{{{
    let i = 0
    " Prefixes used to highlight differently one task on two
    let prefixes = [' ', "\t"]
    let buffId = bufnr( '%' )
    setlocal modifiable

    if b:todo_inner_help == 0
        call append( i, s:todo_inner_help_appeal )
        let i = i + len( s:todo_inner_help_appeal )
    else
        call append( i, s:todo_inner_help_text )
        let i = i + len( s:todo_inner_help_text )
    endif

    for [disp, file, sortKind, todos] in a:todol
        let partBegin = i
        call append( i, '====  ' . disp )
        let i = i + 1

        for [prio,text] in todos
            call append( i, prefixes[i % 2] . text )
            let i = i + 1
            call s:AttribSign( buffId, prio, i )
        endfor

        " We create a fold manually here
        if partBegin > 0
            let partBegin = partBegin + 1
        endif

        exec partBegin . ',' . i . 'fold'
        call append( i, ' ' )
        let i = i + 1
    endfor

    " Remove last two lines
    normal G"zdd"zdd
    " Open all the folds
    normal zR
    setlocal nomodifiable
endfunction "}}}

fun! s:TodoParseTodo(txt) "{{{
    if a:txt =~ '^\d:.*'
        let prio = substitute( a:txt, '^\(\d\):.*', '\1', '' )
        let text = substitute( a:txt, '^\d:\(.*\)', '\1', '' )
        return [prio, text]
    elseif a:txt =~ '^\d\+\s\+.*'
        let prio = substitute( a:txt, '^\(\d\+\).*', '\1', '' )
        let text = substitute( a:txt, '^\d\+\s\+\(.*\)', '\1', '' )
        return [prio, ' ' . text]
    else
        return [s:default_priority, a:txt]
    endif
endfunction "}}}

" Used by TodoGatherInFiles to store result in a list :]
fun! s:TodoGathering() "{{{
    let text = substitute( getline('.'), '.*TODO\s\+\(.*\)', '\1', '' )
    let [prio, txt] = s:TodoParseTodo( text )
    call add( s:spareTodos, [prio, expand('%') . '|' . line('.') . '|' .txt ] )
endfunction "}}}

fun! s:TodoGatherInFiles() "{{{
    if !g:todo_generate_auto 
        return
    endif

    let curBuf = bufnr( '%' )
    " avoid buffer deletion during bufdo
    setlocal bufhidden=hide
    " Ok we remove all we have, to avoid
    " getting a feedback loop and getting todos
    " from the todo window...
    setlocal modifiable
    normal ggVG"zd

    let s:spareTodos = []
    " Big regexp to catch TODO and avoid it in words
    bufdo 1,$g/^TODO\|\ATODO\A\|\ATODO$/call s:TodoGathering()
    execute 'buffer ' . curBuf
    setlocal bufhidden=wipe
    if len(s:todo_list) < 3
        call add( s:todo_list, ['Generated', '', s:defaultSortKind, s:spareTodos])
    else
        let s:todo_list[2] = ['Generated', '', s:defaultSortKind, s:spareTodos]
    endif
endfunction "}}}

fun! LoadTodoFile( displayName, fileName ) "{{{
    if !filereadable( a:fileName )
        return [a:displayName, a:fileName, s:defaultSortKind, []]
    endif
    let retLst = []

    for line in readfile( a:fileName )
        call add( retLst, s:TodoParseTodo( line ) )
    endfor
    return [a:displayName, a:fileName, s:defaultSortKind, retLst]
endfunction "}}}

"=============================================================================
"                Buffer definition
"=============================================================================
" Set all the option for the todo buffer, avoid
" modification and put hooks to manage it.
function! s:PrepareTodoBuffer()
    set ft=NONE
    mapclear <buffer>
    setlocal buftype=nofile
    " make sure buffer is deleted when view is closed
    setlocal bufhidden=wipe
    setlocal noswapfile
    setlocal nobuflisted
    setlocal nonumber
    setlocal linebreak
    setlocal foldcolumn=1
    setlocal foldmethod=manual
    setlocal noexpandtab
    setlocal softtabstop
    setlocal tabstop=1
    
    exe 'file ' . g:todo_list_buff_name
    setlocal statusline=%F
    nnoremap <silent> <buffer> + :call <SID>TodoAddToPriority(1)<CR>
    nnoremap <silent> <buffer> - :call <SID>TodoAddToPriority(-1)<CR>
    nnoremap <silent> <buffer> ^ :call <SID>TodoSwap(-1)<CR>
    nnoremap <silent> <buffer> v :call <SID>TodoSwap(1)<CR>
    nnoremap <silent> <buffer> s :call <SID>TodoSort()<CR>
    nnoremap <silent> <buffer> m :call <SID>TodoModify()<CR>
    nnoremap <silent> <buffer> u :call <SID>UpdateTodos()<CR>
    nnoremap <silent> <buffer> o :call <SID>TodoJumpTo()<CR>
    nnoremap <silent> <buffer> <S-D> :call <SID>TodoRemoveTask()<CR>
    nnoremap <silent> <buffer> <F1> :call <SID>TodoToggleHelp()<CR>

    syntax match Title /^===.*/
    syntax match DiffChange /^\t.*/
    syntax match Comment /^".*/

    let b:todo_inner_help = 0
endfunction

fun! s:TodoToggleHelp() "{{{
    if b:todo_inner_help != 0
        let b:todo_inner_help = 0
    else
        let b:todo_inner_help = 1
    endif
    let editLine = line('.')
    call s:TodoRedraw( editLine )
endfunction "}}}

"=============================================================================
"                Sorting functions
"=============================================================================
fun! s:TodoCompareByPrio(obj1, obj2) "{{{
    let [i1, ignoredText1] = a:obj1
    let [i2, ignoredText2] = a:obj2
    return i1 == i2 ? 0 : i1 > i2 ? 1 : -1
endfunction "}}}

fun! s:TodoCompareByInvPrio(o1, o2) "{{{
    return - s:TodoCompareByPrio(a:o1, a:o2)
endfunction "}}}

fun! s:TodoCompareByText(obj1, obj2) "{{{
    let [ignoredPrio1, i1] = a:obj1
    let [ignoredPrio2, i2] = a:obj2
    return i1 == i2 ? 0 : i1 > i2 ? 1 : -1
endfunction "}}}

fun! s:TodoCompareByInvText(o1, o2) "{{{
    return - s:TodoCompareByText( a:o1, a:o2 )
endfunction "}}}

let s:sortFunctions = ["<SID>TodoCompareByPrio"
                     \,"<SID>TodoCompareByInvPrio"
                     \,"<SID>TodoCompareByText"
                     \,"<SID>TodoCompareByInvText"
                     \]
fun! s:TodoSort() "{{{
    let [editLine, fileNumber, index] = s:ComputeIndices()
    if fileNumber != -1
        let sortIdx = (s:todo_list[fileNumber][s:todo_sort_index] + 1) % len( s:sortFunctions )
        call sort( s:todo_list[fileNumber][s:todo_list_index], s:sortFunctions[sortIdx] )
        let s:todo_list[fileNumber][s:todo_sort_index] = sortIdx
        call s:TodoRedraw( editLine )
    endif
endfunction "}}}

"=============================================================================
"                Buffer actions
"=============================================================================
" Function called to trigger the todo gathering in files
fun! s:UpdateTodos() "{{{
    let editLine = line('.')
    let s:spareTodos = []
    call s:TodoLoadFiles()
    call s:TodoGatherInFiles()
    call s:PrepareTodoBuffer()
    call s:TodoRedraw( editLine )
endfunction "}}}

fun! s:TodoRemoveTask() "{{{
    let [editLine, fileNumber, index] = s:ComputeIndices()

    if fileNumber != -1
        let todos = s:todo_list[fileNumber][s:todo_list_index]
        call remove( todos, index )
        call s:TodoRedraw( editLine )
    endif
endfunction "}}}

" Swap two tasks, to simulate a move up or move down
" in function of the a:swapRel variable.
fun! s:TodoSwap(swapRel) "{{{
    let [editLine, fileNumber, index] = s:ComputeIndices()

    if fileNumber != -1
        let todos = s:todo_list[fileNumber][s:todo_list_index]
        let atIndex = get( todos, index )

        " Avoid swapping out of bounds todos
        if (a:swapRel < 0 && index == 0) || (a:swapRel > 0 && index == len(todos) - 1)
            return
        endif

        call remove( todos, index )
        call insert( todos, atIndex, index + a:swapRel )
        if a:swapRel > 0
            let editLine = editLine + 1
        elseif a:swapRel < 0
            let editLine = editLine - 1
        endif

        call s:TodoRedraw( editLine )
    endif
endfunction "}}}

" Add count to the priority
fun! s:TodoAddToPriority( count ) "{{{
    let [editLine, fileNumber, index] = s:ComputeIndices()

    if fileNumber != -1
        let todos = s:todo_list[fileNumber][s:todo_list_index]
        let [prio, text] = todos[index]
        let newprio = prio + a:count

        if newprio < s:todoMinPrio || newprio > s:todoMaxPrio
            return
        endif

        call insert( todos, [newprio, text], index )
        call remove( todos, index + 1 )

        call s:TodoRedraw( editLine )
    endif
endfunction "}}}

fun! s:TodoModify() "{{{
    let [editLine, fileNumber, index] = s:ComputeIndices()

    if fileNumber != -1
        let [dispName, filename, sortKind, todos] = s:todo_list[fileNumber]
        " Can't modify the generated
        if filename == ''
            return
        endif

        let newText = input( 'Todo> ', todos[index][1] )
        let todos[index][1] = newText

        call s:TodoRedraw( editLine )
    endif
endfunction "}}}

fun! s:TodoJumpTo() "{{{
    let [editLine, fileNumber, index] = s:ComputeIndices()

    if fileNumber != 2
        return
    endif

    let txt = s:todo_list[fileNumber][s:todo_list_index][index][1]
    let filename = substitute( txt, '^\([^|]\+\).*', '\1', '' )
    let lineNum = substitute( txt, '^[^|]\+|\(\d\+\).*', '\1', '')

    let bufnum = bufnr( filename )
    if bufnum >= 0
        let win_num = bufwinnr( bufnum )
        " If it's already shown
        if win_num > 0
            " We must get a real window number, or
            " else the buffer would have been deleted
            " already
            exe win_num . "wincmd w"
        else " Heuristic... go left and change the buffer...
            wincmd l
            execute 'buffer ' . bufnum
        endif

        exe 'normal ' . lineNum . 'gg'
    endif
endfunction "}}}

"=============================================================================
"                Ex Commands implementation
"=============================================================================
fun! TodoCloseWindow() "{{{
    let last_buffer = bufnr("%")
    if s:TodoGotoWin() >= 0
        close
    endif
    let win_num = bufwinnr( last_buffer )
    " We must get a real window number, or
    " else the buffer would have been deleted
    " already
    exe win_num . "wincmd w"
endfunction "}}}

fun! TodoWindowOpen() "{{{
    " Ok, previous buffer to jump to it at final
    let last_buffer = bufnr("%")

    if s:TodoGotoWin() < 0
        new
        call s:PrepareTodoBuffer()
        setl modifiable
    else
        call s:TodoRemoveSign()
        setl modifiable
        normal ggVGd<ESC>
    endif

    call s:TodoWriteFile( s:todo_list )

    let win_num = bufwinnr( last_buffer )
    " We must get a real window number, or
    " else the buffer would have been deleted
    " already
    exe win_num . "wincmd w"
endfunction "}}}

fun! TodoAdd(level) "{{{
    let text = input( 'Todo> ' )
    let prio = s:default_priority

    " If the text begin by digits
    if text =~ '^\d\+\s\+.*'
        " then extract the said digit and transform it to int
        let mayPrio = substitute(text,'^\(\d\+\)\s\+.*','\1', '') + 0
        " If it's in priority bounds...
        if s:todoMinPrio <= mayPrio && mayPrio <= s:todoMaxPrio
            " Take it as task priority...
            let text = substitute( text, '^\d\+\s\+\(.*\)', '\1', '' )
            let prio = mayPrio
        endif
    endif

    " Now add it to the good level... (local or global)
    for [disp, f, sortKind, todos] in s:todo_list
        if disp == a:level
            call add( todos, [prio, text] )
        endif
    endfor

    call TodoWindowOpen()
    call s:SaveTodoFile()
endfunction "}}}

fun! s:TodoLoadFiles() "{{{
    let currDir = expand( '$PWD' )
    let globDir = expand( '$HOME' )

    let s:todo_list = [ LoadTodoFile( 'Global', globDir . '/' . g:todo_list_globfilename )
                    \ , LoadTodoFile( 'Local', g:todo_list_filename )
                    \ ]
endfunction "}}}

command! TodoClose call TodoCloseWindow()
command! TodoOpen call TodoWindowOpen()
command! Todo call TodoAdd( 'Local' )
command! Todog call TodoAdd( 'Global' )

let s:spareTodos = []
call s:TodoLoadFiles()

