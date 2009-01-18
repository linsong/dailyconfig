" mypyini.vim -- make configures ready to edit great python files!
" Author: Vincent Wang (linsong dot qizi at gmail dot com)
" Last Change: 
" Created:     
" Requires: foldutil.vim
" Version: 
" Acknowledgements:

" prevent reloading twice for the same buffer
" for buffer related setting, we need to call it every buffer
" buffer related setting includes: 
"     * variables in buffer scope 
"     * buffer abbreviation
"     * buffer map
"     * settings set by setlocal
"
if ! exists("b:mypyini")

    let b:mypyini= 1

    "############################################################################
    "#    PYTHON USEFULL ABBREVIATION
    "############################################################################
    "TODO: is there a way to define abbriviation locally? Answer: Yes, invoke 
    "  help :abbreviate-local for details
    iabbr <buffer> slef self
    " following abbr make more trouble than convenience for me 
    "iabbr <buffer> this self
    "iabbr <buffer> true True
    "iabbr <buffer> false False

    "############################################################################
    "#    FUNCTION TO COMMAND MAPS
    "############################################################################

    "############################################################################
    "#    LOCAL SETTINGS 
    "############################################################################

    setlocal expandtab
    setlocal softtabstop=4
    setlocal textwidth=79

    " set the python module search path 
    " TODO: need to get the path more generally
    if has('unix')
        setlocal path+=/usr/lib/python2.5/site-packages
    endif

    """ This is not needed since python_match.vim defined these already
    "if !exists("b:match_words")
        "let b:match_ignorecase=0
        "let b:match_words = 'if:elif:else,' .
                    "\ 'try:except' .
                    "\ 'from:import' .

    "endif
endif

" prevent reloading twice for the same type of file 
if exists("g:mypyini")
    finish
endif

let g:mypyini = 1
let g:PyInitFold = 1 

"############################################################################
"#    FUNCTIONS 
"############################################################################
" use the foldutil.vim to fold opened python file 
"function! PyFold(fold)
    "if a:fold==1
        "" fold the class and method when we begin to edit source 
        "" and this will let us to view more source in one page
        ":FoldMatching ^\s*\(\<def\>\|\<class\>\) -1 
    "else
        ":FoldEndFolding
    "endif
"endfunction

"############## Python Lint Configuration ###################################
" NOTE: in order to use the pylint or pychecker tool, we must install pylint
" or pychecker tool first, and it seems like these tools are OS independent
" and they can really make life easier :)
" the following function come from http://vim.sourceforge.net/tips/tip.php?tip_id=949 
" Simple function to add pylint and pychecker support to Vim.
function! <SID>PythonGrep(tool)
    set lazyredraw
    " Close any existing cwindows.
    cclose
    let l:grepformat_save = &grepformat
    let l:grepprogram_save = &grepprg
    set grepformat&vim
    set grepformat&vim
    let &grepformat = '%f:%l:%m'
    if a:tool == "pylint"
        let &grepprg = 'pylint --parseable=y --reports=n'
    elseif a:tool == "pychecker"
        " environment variables suitable for my Ubuntu at exoweb
        let &grepprg = 'PYTHONPATH=$PYTHONPATH:/usr/share/python-support/pychecker PYTHONVER=2.3 pychecker --quiet -q'
    else
        echohl WarningMsg
        echo "PythonGrep Error: Unknown Tool"
        echohl none
    endif
    if &readonly == 0 | update | endif
    silent! grep! %
    let &grepformat = l:grepformat_save
    let &grepprg = l:grepprogram_save
    let l:mod_total = 0
    let l:win_count = 1
    " Determine correct window height
    windo let l:win_count =  l:win_count + 1
    if l:win_count <= 2 | let l:win_count = 4 | endif
    windo let l:mod_total = l:mod_total + winheight(0)/l:win_count |
    \ execute 'resize +'.l:mod_total
    " Open cwindow
    execute 'belowright copen '.l:mod_total
    nnoremap <buffer> <silent> c :cclose<CR>
    set nolazyredraw
    redraw!
endfunction

"if ( !hasmapto('<SID>PythonGrep(pychecker)') && (maparg('<F7>') == '') )
    "map  <F7> :call <SID>PythonGrep('pychecker')<CR>
    "map! <F7> :call <SID>PythonGrep('pychecker')<CR>
"else
    "if ( !has("gui_running") || has("win32") )
        "echo "Python Pychecker Error: No Key mapped.\n".
        "\  "<F7> is taken and a replacement was not assigned."
    "endif
"endif

if ( !hasmapto('<SID>PythonGrep(pylint)') && (maparg('<F7>') == '') )
    map  <F7> :call <SID>PythonGrep('pylint')<CR>
    map! <F7> :call <SID>PythonGrep('pylint')<CR>
else
    if ( !has("gui_running") || has("win32") )
        echo "Python Pylint Error: No Key mapped.\n".
        \  "<F7> is taken and a replacement was not assigned."
    endif
endif

command! Pylint :call <SID>PythonGrep('pylint')<CR>
command! Pychecker :call <SID>PythonGrep('pychecker')<CR>

" undo buffer settings view "help undo_ftplugin" for details
let b:undo_ftplugin = "setlocal expandtab< softtabstop< textwidth<"
    \ . "| unlet b:mypyini"
